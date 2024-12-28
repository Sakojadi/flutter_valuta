import 'package:flutter/material.dart';
import 'api_service.dart';

class TransactionsPage extends StatefulWidget {
  @override
  TransactionsPageState createState() => TransactionsPageState();
}

class TransactionsPageState extends State<TransactionsPage> {
  List<Map<String, dynamic>> transactionData = [];
  List<Map<String, dynamic>> filteredTransactionData = [];
  List<Map<String, dynamic>> valutaList = [];
  List<Map<String, dynamic>> userData = [];
  String selectedValutaFilter = "-";
  String selectedUserFilter = "-";
  String? selectedTransactionTypeFilter; 
  int? selectedRowId;

  Future<void> fetchTransactions() async {
    try {
      final data = await ApiService.fetchTransactions();
      setState(() {
        transactionData = data;
        _applyFilter();
      });
    } catch (e) {
      _showError('Error fetching transactions: $e');
    }
  }

  Future<void> fetchValutas() async {
  try {
    // Fetch valutas from the API
    final fetchedValutas = await ApiService.fetchValutas();

    // Convert to List<Map<String, String>> and add the blank option
    final formattedValutas = fetchedValutas.map<Map<String, String>>((valuta) {
      return valuta.map((key, value) => MapEntry(key, value.toString()));
    }).toList();

    setState(() {
      // Add the blank option at the beginning
      valutaList = [{'valuta': '-'}] + formattedValutas;
    });
  } catch (e) {
    _showError('Error fetching valutas: $e');
  }
}

 Future<void> fetchUsers() async {
  try {
    // Fetch users from the API
    final fetchedUsers = await ApiService.fetchUsers();

    setState(() {
      userData = [{'user': '-'}] + fetchedUsers.map<Map<String, String>>((user) {
        return {'user': user['username']?.toString() ?? ''};
      }).toList();
    });
    print(userData);
  } catch (e) {
    _showError('Error fetching users: $e');
  }
}




  void _applyFilter() {
  setState(() {
    filteredTransactionData = transactionData.where((transaction) {
      final matchesUser = selectedUserFilter == "-" || transaction['user'] == selectedUserFilter;
      final matchesValuta = selectedValutaFilter == "-" || transaction['currency'] == selectedValutaFilter;
      final matchesType = selectedTransactionTypeFilter == null || transaction['transaction_type'] == selectedTransactionTypeFilter;
      return matchesValuta && matchesType && matchesUser;
    }).toList();
  });
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
          _applyFilter();
          selectedRowId = null;
        });
      } catch (e) {
        _showError('Error deleting transaction: $e');
      }
    }
  }

  Future<void> editSelectedTransaction() async {
    final selectedTransaction = transactionData.firstWhere(
      (transaction) => transaction['id'] == selectedRowId,
      orElse: () => {},
    );

    if (selectedTransaction.isNotEmpty) {
      final updatedTransaction = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => EditTransactionDialog(transaction: selectedTransaction),
      );

      if (updatedTransaction != null) {
        setState(() {
          final index = transactionData.indexWhere((transaction) => transaction['id'] == selectedRowId);
          if (index != -1) {
            transactionData[index] = updatedTransaction;
          }
          _applyFilter();
        });

        try {
          final transactionId = updatedTransaction['id'] as int;
          await ApiService.updateTransaction(transactionId, updatedTransaction);
        } catch (e) {
          _showError('Error updating transaction: $e');
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTransactions();
    fetchUsers();
    fetchValutas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: filteredTransactionData.isEmpty
                  ? const Center(child: Text('No transactions available'))
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
                        rows: filteredTransactionData.map((item) {
                          final isSelected = selectedRowId == item['id'];
                          return DataRow(
                            color: MaterialStateColor.resolveWith(
                              (states) => isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
                            ),
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
          ),
        ],
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
          const SizedBox(width: 10),
          if (selectedRowId != null)
            FloatingActionButton(
              onPressed: editSelectedTransaction,
              child: const Icon(Icons.edit),
              backgroundColor: Colors.blue,
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

  void _showFilterDialog() {
  showDialog(
    context: context,
    builder: (context) {
      String tempSelectedUser = selectedUserFilter;
      String tempSelectedValuta = selectedValutaFilter;
      String? tempSelectedTransactionType = selectedTransactionTypeFilter;

      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Filter Transactions'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Filter by User:', style: TextStyle(fontSize: 16)),
                DropdownButton<String>(
                  isExpanded: true,
                  value: tempSelectedUser,
                  items: userData.map((user) {
                    return DropdownMenuItem<String>(
                      value: user['user'],
                      child: Text(user['user']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      tempSelectedUser = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 10),
                const Text('Filter by Valuta:', style: TextStyle(fontSize: 16)),
                DropdownButton<String>(
                  isExpanded: true,
                  value: tempSelectedValuta,
                  items: valutaList.map((valuta) {
                    return DropdownMenuItem<String>(
                      value: valuta['valuta'],
                      child: Text(valuta['valuta']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      tempSelectedValuta = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                const Text('Filter by Type:', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          tempSelectedTransactionType =
                              tempSelectedTransactionType == "buy" ? null : "buy";
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: tempSelectedTransactionType == "buy"
                              ? Colors.blueGrey
                              : Colors.transparent,
                          border: Border.all(color: Colors.blueGrey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_upward,
                          color: tempSelectedTransactionType == "buy"
                              ? Colors.white
                              : Colors.black,
                          size: 36.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          tempSelectedTransactionType =
                              tempSelectedTransactionType == "sell" ? null : "sell";
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: tempSelectedTransactionType == "sell"
                              ? Colors.blueGrey
                              : Colors.transparent,
                          border: Border.all(color: Colors.blueGrey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_downward,
                          color: tempSelectedTransactionType == "sell"
                              ? Colors.white
                              : Colors.black,
                          size: 36.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedValutaFilter = tempSelectedValuta;
                    selectedTransactionTypeFilter = tempSelectedTransactionType;
                    selectedUserFilter = tempSelectedUser;
                    _applyFilter();
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      );
    },
  );
}

}

class EditTransactionDialog extends StatefulWidget {
  final Map<String, dynamic> transaction;

  EditTransactionDialog({required this.transaction});

  @override
  _EditTransactionDialogState createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<EditTransactionDialog> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  List<Map<String, dynamic>> _valutaList = [];
  List<Map<String, dynamic>> _userData = [];

  String? _selectedValuta;
  String? _selectedUser;
  String? _transactionType;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with transaction data
    _quantityController.text = widget.transaction['quantity'] ?? '';
    _rateController.text = widget.transaction['rate'] ?? '';
    _totalController.text = widget.transaction['total'] ?? '';
    _selectedValuta = widget.transaction['currency'];
    _selectedUser = widget.transaction['user'];
    _transactionType = widget.transaction['transaction_type'];

    // Fetch available valutas
    fetchValutas();
    fetchUsers();
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

  Future<void> fetchUsers() async {
    try {
      final data = await ApiService.fetchUsers();
      setState(() {
        _userData = data;
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _rateController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  void _updateTotal() {
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    final rate = double.tryParse(_rateController.text) ?? 0.0;
    final total = quantity * rate;
    _totalController.text = total.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Transaction'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _transactionType = "buy";
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _transactionType == 'buy' ? Colors.blueGrey : Colors.transparent,
                      border: Border.all(color: Colors.blueGrey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.arrow_upward,
                      color: _transactionType == 'buy' ? Colors.white : Colors.black,
                      size: 36.0,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _transactionType = 'sell';
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _transactionType == 'sell' ? Colors.blueGrey : Colors.transparent,
                      border: Border.all(color: Colors.blueGrey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.arrow_downward,
                      color: _transactionType == 'sell' ? Colors.white : Colors.black,
                      size: 36.0,
                    ),
                  ),
                ),
              ],
            ),
              DropdownButton<String>(
              value: _selectedUser,
              isExpanded: true,
              hint: Text('Select Currency'),
              items: _userData.map<DropdownMenuItem<String>>((user) {
                return DropdownMenuItem<String>(
                  value: user['username'],
                  child: Text(user['username']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUser = value;
                });
              },
            ),
            // Dropdown for Valutas
            DropdownButton<String>(
              value: _selectedValuta,
              isExpanded: true,
              hint: Text('Select Currency'),
              items: _valutaList.map<DropdownMenuItem<String>>((valuta) {
                return DropdownMenuItem<String>(
                  value: valuta['valuta'],
                  child: Text(valuta['valuta']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedValuta = value;
                });
              },
            ),
            SizedBox(height: 10),
            // Quantity Field
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Quantity'),
              onChanged: (_) => _updateTotal(),
            ),
            SizedBox(height: 10),
            // Rate Field
            TextField(
              controller: _rateController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Rate'),
              onChanged: (_) => _updateTotal(),
            ),
            SizedBox(height: 10),
            // Total Field (readonly)
            TextField(
              controller: _totalController,
              readOnly: true,
              decoration: InputDecoration(labelText: 'Total'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedTransaction = {
              'id': widget.transaction['id'],
              'date': widget.transaction['date'],
              'transaction_type': _transactionType,
              'user':_selectedUser,
              'currency': _selectedValuta,
              'quantity': _quantityController.text,
              'rate': _rateController.text,
              'total': _totalController.text,
            };
            Navigator.of(context).pop(updatedTransaction);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

