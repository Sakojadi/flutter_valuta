import 'package:flutter/material.dart';
import 'api_service.dart';

class KassaPage extends StatefulWidget {
  @override
  Kassa createState() => Kassa();
}

class Kassa extends State<KassaPage> {
  int? selectedRowId;
  List<Map<String, dynamic>> transactionData = [];
  List<Map<String, dynamic>> _valutaList = [];
  int? _sortedColumnIndex;  // Tracks which column is sorted
  bool _isAscending = true; 
  bool _isLoading = true;  // Tracks the sorting order (ascending or descending)


  @override
  void initState() {
    super.initState();
    fetchTransactionsAndValutas(); // Call fetchTransactions when the widget is initialized
  }

 Future<void> fetchTransactionsAndValutas() async {
  try {
    // Fetch data from API for transactions
    final transactionData = await ApiService.fetchTransactions();
    final valutas = await ApiService.fetchValutas();

    if (mounted) { // Check if the widget is still mounted before calling setState
      setState(() {
        this.transactionData = transactionData;
        _valutaList = valutas;
        _isLoading = false; // Mark loading as complete
      });
    }
  } catch (e) {
    if (mounted) { // Check if the widget is still mounted before calling setState
      setState(() {
        _isLoading = false; // Mark loading as complete even if there's an error
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
    }
  }
}


Future<void> fetchValutas() async {
  try {
    final valutas = await ApiService.fetchValutas();
    setState(() {
      _valutaList = valutas;
    });
  } catch (e) {
    print('Error fetching valutas: $e');
  }
}

List<Map<String, dynamic>> calculateTransactionData() {
  Map<String, Map<String, dynamic>> groupedData = {};

  // Initialize grouped data for all valutas (even those with no transactions)
  for (var valuta in _valutaList) {
    final currency = valuta['valuta']; // Assuming valuta contains a 'valuta' field
    groupedData[currency] = {
      'pokupka_total': 0.0,  // Sum of quantities bought
      'pokupka_value': 0.0,  // Sum of total values for buy transactions
      'sold_total': 0.0,     // Sum of quantities sold
      'sold_value': 0.0,     // Sum of total values for sell transactions
    };
  }

  // Group transactions by valuta (currency)
  for (var transaction in transactionData) {
    final currency = transaction['currency'];
    final quantity = double.tryParse(transaction['quantity'].toString()) ?? 0.0;
    final total = double.tryParse(transaction['total'].toString()) ?? 0.0;

    if (transaction['transaction_type'] == 'buy') {
      groupedData[currency]!['pokupka_total'] += quantity; // Sum of quantities bought
      groupedData[currency]!['pokupka_value'] += total;   // Sum of total values for buy transactions
    } else if (transaction['transaction_type'] == 'sell') {
      groupedData[currency]!['sold_total'] += quantity;    // Sum of quantities sold
      groupedData[currency]!['sold_value'] += total;      // Sum of total values for sell transactions
    }
  }

  // Calculate averages and profit for each currency
  List<Map<String, dynamic>> formattedData = [];

  groupedData.forEach((currency, data) {
    final pokupka_avg = data['pokupka_total'] > 0
        ? data['pokupka_value'] / data['pokupka_total'] // Average = total value / total quantity
        : 0.0;
    final sold_avg = data['sold_total'] > 0
        ? data['sold_value'] / data['sold_total']
        : 0.0;
    final profit = sold_avg > pokupka_avg
        ? (sold_avg - pokupka_avg) * data['sold_total'] // Profit = (sell avg - buy avg) * sold quantity
        : 0.0;

    formattedData.add({
      'valuta': currency,
      'pokupka_total': data['pokupka_total'],
      'pokupka_avg': pokupka_avg,
      'sold_total': data['sold_total'],
      'sold_avg': sold_avg,
      'profit': profit,
    });
  });

  return formattedData;
}

@override
Widget build(BuildContext context) {
  if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Center(child: Text('KASSA')),
        ),
        body: Center(
          child: CircularProgressIndicator(), // Show loading spinner
        ),
      );
    }
  final filteredTransactionData = calculateTransactionData();
  
  double totalProfit = 0.0;
  for (var item in filteredTransactionData) {
    totalProfit += item['profit'] ?? 0.0; // Sum the profit values
  }
  String totalcutoff = totalProfit.toStringAsFixed(2);

  // Sort the data based on the selected column and sort order
  if (_sortedColumnIndex != null) {
    filteredTransactionData.sort((a, b) {
      var valueA, valueB;

      // Determine which column to compare based on _sortedColumnIndex
      switch (_sortedColumnIndex) {
        case 0: // 'Valuta'
          valueA = a['valuta'];
          valueB = b['valuta'];
          break;
        case 1: // 'Pokupka Total'
          valueA = a['pokupka_total'];
          valueB = b['pokupka_total'];
          break;
        case 2: // 'Pokupka Average'
          valueA = a['pokupka_avg'];
          valueB = b['pokupka_avg'];
          break;
        case 3: // 'Sold Total'
          valueA = a['sold_total'];
          valueB = b['sold_total'];
          break;
        case 4: // 'Sold Average'
          valueA = a['sold_avg'];
          valueB = b['sold_avg'];
          break;
        case 5: // 'Profit'
          valueA = a['profit'];
          valueB = b['profit'];
          break;
        default:
          return 0;
      }

      // Handle numerical sorting (if both are numbers)
      if (valueA is num && valueB is num) {
        return _isAscending ? valueA.compareTo(valueB) : valueB.compareTo(valueA);
      }
      // Handle alphabetical sorting (if both are strings)
      else if (valueA is String && valueB is String) {
        return _isAscending ? valueA.compareTo(valueB) : valueB.compareTo(valueA);
      }
      return 0;
    });
  }

  return Scaffold(
   appBar: AppBar(
        title: Center(child: Text('KASSA')),
      ),
    body: Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateColor.resolveWith((states) => Theme.of(context).colorScheme.secondary),
                border: TableBorder.all(color: Colors.black),
                columns: [
                  DataColumn(
                    label: Text('Valuta'),
                    onSort: (columnIndex, _) => _sort(columnIndex),
                  ),
                  DataColumn(
                    label: Text('Pokupka Total'),
                    onSort: (columnIndex, _) => _sort(columnIndex),
                  ),
                  DataColumn(
                    label: Text('Pokupka Average'),
                    onSort: (columnIndex, _) => _sort(columnIndex),
                  ),
                  DataColumn(
                    label: Text('Sold Total'),
                    onSort: (columnIndex, _) => _sort(columnIndex),
                  ),
                  DataColumn(
                    label: Text('Sold Average'),
                    onSort: (columnIndex, _) => _sort(columnIndex),
                  ),
                  DataColumn(
                    label: Text('Profit'),
                    onSort: (columnIndex, _) => _sort(columnIndex),
                  ),
                ],
                rows: List.generate(filteredTransactionData.length, (index) {
                  final item = filteredTransactionData[index];
                  final isSelected = selectedRowId == index;
                  return DataRow(
                    color: MaterialStateColor.resolveWith(
                      (states) => isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
                    ),
                    cells: [
                      DataCell(Text(item['valuta'] ?? ''), onTap: () => _selectRow(index)),
                      DataCell(Text(item['pokupka_total'].toString()), onTap: () => _selectRow(index)),
                      DataCell(Text(item['pokupka_avg'].toStringAsFixed(2)), onTap: () => _selectRow(index)),
                      DataCell(Text(item['sold_total'].toString()), onTap: () => _selectRow(index)),
                      DataCell(Text(item['sold_avg'].toStringAsFixed(2)), onTap: () => _selectRow(index)),
                      DataCell(Text(item['profit'].toStringAsFixed(2)), onTap: () => _selectRow(index)),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
        Container(
          // width: MediaQuery.of(context).size.width / 2, // Takes half of the screen width
          padding: EdgeInsets.all(16.0),
          color: Colors.grey[900],
          // alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Total Profit: ',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                totalcutoff,
                style: TextStyle(color: Colors.teal, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Sort function for columns
void _sort(int columnIndex) {
  setState(() {
    if (_sortedColumnIndex == columnIndex) {
      // If same column clicked, toggle the sort order
      _isAscending = !_isAscending;
    } else {
      // If new column clicked, set to ascending order
      _isAscending = true;
    }
    _sortedColumnIndex = columnIndex;
  });
}

  // Helper to select a row by index
  void _selectRow(int index) {
    setState(() {
      selectedRowId = selectedRowId == index ? null : index; // Set selectedRowId to the index of the selected row
    });
  }
}
