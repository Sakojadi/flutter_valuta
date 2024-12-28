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
  bool _isAscending = true;  // Tracks the sorting order (ascending or descending)



Future<void> fetchTransactionsAndValutas() async {
  try {
    // Fetch data from API for transactions
    final transactionData = await ApiService.fetchTransactions();
    setState(() {
      this.transactionData = transactionData;
    });

    // Fetch valutas separately
    await fetchValutas(); // This is your separate method for fetching valutas
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
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


  // Group transactions by currency (valuta) and calculate totals/averages/profit
  List<Map<String, dynamic>> calculateTransactionData() {
  Map<String, Map<String, dynamic>> groupedData = {};

  // Initialize grouped data for all valutas (even those with no transactions)
  for (var valuta in _valutaList) {
    final currency = valuta['valuta'];  // Assuming valuta is a Map<String, dynamic> and contains a 'currency' field
    groupedData[currency] = {
      'pokupka_total': 0.0,
      'pokupka_count': 0,
      'sold_total': 0.0,
      'sold_count': 0,
    };
  }

  // Group transactions by valuta (currency)
  for (var transaction in transactionData) {
    final currency = transaction['currency'];

    // Safely parse the total field as a double
    double total = double.tryParse(transaction['total'].toString()) ?? 0.0;

    // Calculate totals and counts for buy and sell transactions
    if (transaction['transaction_type'] == 'buy') {
      groupedData[currency]!['pokupka_total'] += total;
      groupedData[currency]!['pokupka_count']++;
    } else if (transaction['transaction_type'] == 'sell') {
      groupedData[currency]!['sold_total'] += total;
      groupedData[currency]!['sold_count']++;
    }
  }

  // Calculate averages and profit for each currency
  List<Map<String, dynamic>> formattedData = [];
  groupedData.forEach((currency, data) {
    final pokupka_avg = data['pokupka_count'] > 0
        ? data['pokupka_total'] / data['pokupka_count']
        : 0.0;
    final sold_avg = data['sold_count'] > 0
        ? data['sold_total'] / data['sold_count']
        : 0.0;
    final profit = sold_avg > pokupka_avg
        ? (sold_avg - pokupka_avg) * data['sold_total']
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
  void initState() {
    super.initState();
    fetchTransactionsAndValutas(); // Call fetchTransactions when the widget is initialized
  }

@override
Widget build(BuildContext context) {
  final filteredTransactionData = calculateTransactionData();

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
      title: Text('Kassa Window'),
    ),
    body: Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[300]!),
                border: TableBorder.all(color: Colors.grey),
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
