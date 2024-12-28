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
    // Fetched and calculated data is stored in filteredTransactionData
    final filteredTransactionData = calculateTransactionData();

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
                  columns: const [
                    DataColumn(label: Text('Valuta')),
                    DataColumn(label: Text('Pokupka Total')),
                    DataColumn(label: Text('Pokupka Average')),
                    DataColumn(label: Text('Sold Total')),
                    DataColumn(label: Text('Sold Average')),
                    DataColumn(label: Text('Profit')),
                  ],
                  rows: List.generate(filteredTransactionData.length, (index) {
                    final item = filteredTransactionData[index];
                    final isSelected = selectedRowId == index; // Compare with index
                    return DataRow(
                      color: MaterialStateColor.resolveWith(
                        (states) =>
                            isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
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

  // Helper to select a row by index
  void _selectRow(int index) {
    setState(() {
      selectedRowId = selectedRowId == index ? null : index; // Set selectedRowId to the index of the selected row
    });
  }
}
