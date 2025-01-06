import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:intl/intl.dart';
import 'app_localizations.dart';

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

   if (mounted) {
  setState(() {
    valutaList = [{'valuta': '-'}] + formattedValutas;
  });
}

  } catch (e) {
    _showError('Error fetching valutas: $e');
  }
}

 Future<void> fetchUsers() async {
  try {
    // Fetch users from the API
    final fetchedUsers = await ApiService.fetchUsers();
if (mounted) {
  setState(() {
    userData = [{'user': '-'}] + fetchedUsers.map<Map<String, String>>((user) {
      return {'user': user['username']?.toString() ?? ''};
    }).toList();
  });
}

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
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
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
        if (mounted) {
  setState(() {
    final index = transactionData.indexWhere((transaction) => transaction['id'] == selectedRowId);
    if (index != -1) {
      transactionData[index] = updatedTransaction;
    }
    _applyFilter();
  });
}


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

  String formatDate(String dateString) {
  // Parse the original date string into a DateTime object
  final DateTime dateTime = DateTime.parse(dateString);
  final DateFormat formatter = DateFormat('dd/MM/yy');
  
  return formatter.format(dateTime);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context, 'trans')),
        leading: IconButton(
      icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
            setState(() {
      selectedRowId = null;
    });},
        ),
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
                      child:SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith((states) =>Theme.of(context).colorScheme.secondary),
                        border: TableBorder.all(color: Colors.black),
                        columns: [
                          DataColumn(label: Text(AppLocalizations.of(context, 'date'))),
                          DataColumn(label: Text(AppLocalizations.of(context, 'type'))),
                          // DataColumn(label: Text(AppLocalizations.of(context, 'users'))),
                          DataColumn(label: Text(AppLocalizations.of(context, 'currency'))),
                          DataColumn(label: Text(AppLocalizations.of(context, 'quantity'))),
                          DataColumn(label: Text(AppLocalizations.of(context, 'rate'))),
                          DataColumn(label: Text(AppLocalizations.of(context, 'total'))),
                        ],
                        rows: filteredTransactionData.map((item) {
                          final isSelected = selectedRowId == item['id'];
                          return DataRow(
                            color: MaterialStateColor.resolveWith(
                              (states) => isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
                            ),
                            cells: [
                              DataCell(Text(formatDate(item['date'] ?? '')), onTap: () => _selectRow(item['id'])),
                              DataCell(Text(item['transaction_type'] ?? ''), onTap: () => _selectRow(item['id'])),
                              // DataCell(Text(item['user'] ?? ''), onTap: () => _selectRow(item['id'])),
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
            title: Text(AppLocalizations.of(context, 'filter')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            // Container(
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(4),
            //   border: Border.all(
            //       color: Theme.of(context).primaryColor,
            //     ),),
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add inner padding
            //   child: DropdownButtonHideUnderline( // Remove the default underline
            //     child: DropdownButton<String>(
            //       value: tempSelectedUser,
            //       isExpanded: true,
            //       items: userData.map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
            //         return DropdownMenuItem<String>(
            //           value: item['user'], // Use valuta name as value
            //           child: Text(item['user'],),
            //         );  
            //       }).toList(),
            //       onChanged: (String? value) {
            //         setDialogState(() {
            //           tempSelectedUser = value!; // Save the selected valuta name
            //         });
            //       },
            //     ),
            //   ),
            // ),
                const SizedBox(height: 20),
                const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: Theme.of(context).primaryColor,
                ),),
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add inner padding
              child: DropdownButtonHideUnderline( // Remove the default underline
                child: DropdownButton<String>(
                  value: tempSelectedValuta,
                  isExpanded: true,
                  items: valutaList.map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
                    return DropdownMenuItem<String>(
                      value: item['valuta'], // Use valuta name as value
                      child: Text(item['valuta'],),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setDialogState(() {
                      tempSelectedValuta = value!; // Save the selected valuta name
                    });
                  },
                ),
              ),
            ),
                const SizedBox(height: 20),
                Text(AppLocalizations.of(context, 'filterType'), style: TextStyle(fontSize: 16)),
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
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          border: Border.all(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_upward,
                          color:
                               Colors.white,
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
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          border: Border.all(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_downward,
                          color:
                               Colors.white,
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
                child: Text(AppLocalizations.of(context, 'cancel')),
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
                child: Text(AppLocalizations.of(context, 'apply')),
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

  // Fetch available valutas and users
  fetchValutas();
  // fetchUsers();
}

Future<void> fetchValutas() async {
  try {
    final valutas = await ApiService.fetchValutas();
    setState(() {
      _valutaList = valutas;

      // If selectedValuta is not found in the list, select the first one
      if (_selectedValuta == null || !_valutaList.any((valuta) => valuta['valuta'] == _selectedValuta)) {
        _selectedValuta = _valutaList.isNotEmpty ? _valutaList[0]['valuta'] : null;  // Default to the first valuta
      }
    });
  } catch (e) {
    print('Error fetching valutas: $e');
  }
}

// Future<void> fetchUsers() async {
//   try {
//     final data = await ApiService.fetchUsers();
//     setState(() {
//       _userData = data;

//       // If selectedUser is not found in the list, select the first one
//       if (_selectedUser == null || !_userData.any((user) => user['username'] == _selectedUser)) {
//         _selectedUser = _userData.isNotEmpty ? _userData[0]['username'] : null;  // Default to the first user
//       }
//     });
//   } catch (e) {
//     print('Error fetching users: $e');
//   }
// }

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
      title: Text(AppLocalizations.of(context, 'edit')),
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
                      color: _transactionType == 'buy' ? Theme.of(context).primaryColor: Colors.transparent,
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
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
                      color: _transactionType == 'sell' ? Theme.of(context).primaryColor : Colors.transparent,
                      border: Border.all(color:Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.arrow_downward,
                      color: Colors.white,
                      size: 36.0,
                    ),
                  ),
                ),
              ],
            ),
            //   DropdownButton<String>(
            //   value: _selectedUser,
            //   isExpanded: true,
            //   hint: Text(AppLocalizations.of(context, 'select')),
            //   items: _userData.map<DropdownMenuItem<String>>((user) {
            //     return DropdownMenuItem<String>(
            //       value: user['username'],
            //       child: Text(user['username']),
            //     );
            //   }).toList(),
            //   onChanged: (value) {
            //     setState(() {
            //       _selectedUser = value;
            //     });
            //   },
            // ),
            // Dropdown for Valutas
            DropdownButton<String>(
              value: _selectedValuta,
              isExpanded: true,
              hint: Text(AppLocalizations.of(context, 'select')),
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
              decoration: InputDecoration(labelText: AppLocalizations.of(context, 'quantity')),
              onChanged: (_) => _updateTotal(),
            ),
            SizedBox(height: 10),
            // Rate Field
            TextField(
              controller: _rateController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: AppLocalizations.of(context, 'rate')),
              onChanged: (_) => _updateTotal(),
            ),
            SizedBox(height: 10),
            // Total Field (readonly)
            TextField(
              controller: _totalController,
              readOnly: true,
              decoration: InputDecoration(labelText: AppLocalizations.of(context, 'total')),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context, 'cancel')),
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
          child: Text(AppLocalizations.of(context, 'save')),
        ),
      ],
    );
  }
}

