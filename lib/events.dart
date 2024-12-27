import 'package:flutter/material.dart';
import 'api_service.dart';

class TransactionsPage extends StatefulWidget {
  @override
  TransactionsPageState createState() => TransactionsPageState();
}

class TransactionsPageState extends State<TransactionsPage> {
  List<Map<String, dynamic>> transactionData = [];
  int? selectedRowId;

  Future<void> fetchTransactions() async {
    try {
      final data = await ApiService.fetchTransactions();
      setState(() {
        transactionData = data;
      });
    } catch (e) {
      _showError('Error fetching transactions: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> deleteSelectedTransaction() async {
    if (selectedRowId != null) {
      try {
        await ApiService.deleteTransaction(selectedRowId!);
        setState(() {
          transactionData.removeWhere((transaction) => transaction['id'] == selectedRowId);
          selectedRowId = null;
        });
      } catch (e) {
        _showError('Error deleting transaction: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(6.0),
        child: transactionData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[300]!),
                  border: TableBorder.all(color: Colors.grey),
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('sell/buy')),
                    DataColumn(label: Text('User')),
                    DataColumn(label: Text('Currency')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Rate')),
                    DataColumn(label: Text('Total')),
                  ],
                  rows: transactionData.map((item) {
                    final isSelected = selectedRowId == item['id'];
                    return DataRow(
                      color: MaterialStateColor.resolveWith(
                          (states) => isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent),
                      cells: [
                        DataCell(Text(item['date'] ?? ''), onTap: () => _selectRow(item['id'])),
                        DataCell(Text(item['transaction_type'] ?? ''), onTap: () => _selectRow(item['id'])),
                        DataCell(Text(item['user'] ?? ''), onTap: () => _selectRow(item['id'])),
                        DataCell(Text(item['currency'] ?? ''), onTap: () => _selectRow(item['id'])),
                        DataCell(Text(item['quantity']?.toString() ?? ''), onTap: () => _selectRow(item['id'])),
                        DataCell(Text(item['rate']?.toString() ?? ''), onTap: () => _selectRow(item['id'])),
                        DataCell(Text(item['total']?.toString() ?? ''), onTap: () => _selectRow(item['id'])),
                      ],
                    );
                  }).toList(),
                ),
              ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (selectedRowId != null)
            FloatingActionButton(
              onPressed: deleteSelectedTransaction,
              child: const Icon(Icons.delete),
              backgroundColor: Colors.red,
            ),
        ],
      ),
    );
  }

  void _selectRow(int? id) {
    setState(() {
      selectedRowId = selectedRowId == id ? null : id;
    });
  }
}
