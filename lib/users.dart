import 'package:flutter/material.dart';
import 'api_service.dart';
import 'app_localizations.dart';

class Users extends StatefulWidget {
  final String username;
  Users({required this.username});
  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<Users> {
  List<Map<String, dynamic>> userData = [];
  int? selectedRowId;
  String selectedRowText = '';
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> addNewUser(String username, String password, String email) async {
    try {
      await ApiService.addNewUser(username, password, email);
      _usernameController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _emailController.clear();
      fetchUsers();
    } catch (e) {
      _showError('Error adding user: $e');
    }
  }

  Future<void> fetchUsers() async {
    try {
      final data = await ApiService.fetchUsers();
      setState(() {
        userData = data;
      });
    } catch (e) {
      _showError('Error fetching users: $e');
    }
  }

  Future<void> deleteUser() async {
    if (selectedRowId == null) return;
    try {
      await ApiService.deleteUser(selectedRowId!);
      setState(() {
        selectedRowId = null;
      });
      fetchUsers();
    } catch (e) {
      _showError('Error deleting user: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    if (selectedRowId != null) {
      var selectedRow = userData.firstWhere(
        (item) => item['id'] == selectedRowId,
      );
      selectedRowText = selectedRow['username'] ?? '';
    }
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              selectedRowId = null;
            });
          },
        ),
        title: Text(AppLocalizations.of(context, 'users')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: Theme.of(context).colorScheme.surface,
                      width: 4,
                    ),
                    verticalInside: BorderSide.none,
                  ),
                  children: userData.map<TableRow>((item) {
                    return TableRow(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selectedRowId == item['id']) {
                                selectedRowId = null;
                              } else {
                                selectedRowId = item['id'];
                              }
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              color: selectedRowId == item['id']
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                            alignment: Alignment.center,
                            child: Text(
                              item['username'] ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (selectedRowId != null) ...[
            FloatingActionButton(
              onPressed: deleteUser,
              child: Icon(Icons.delete),
              backgroundColor: Colors.red,
            ),
            SizedBox(width: 10),
            if (selectedRowText == widget.username) ...[
              FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Change Password'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context, 'newPass'),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context, 'passrep'),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(AppLocalizations.of(context, 'cancel')),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_passwordController.text.isNotEmpty &&
                                  _confirmPasswordController.text.isNotEmpty &&
                                  _passwordController.text == _confirmPasswordController.text) {
                                updatePassword(_passwordController.text);
                                Navigator.pop(context);
                              } else {
                                _showError('Passwords do not match or fields are empty');
                              }
                            },
                            child: Text(AppLocalizations.of(context, 'change')),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Icon(Icons.edit),
                backgroundColor: Colors.teal,
              ),
            ],
            SizedBox(width: 10),
          ],
          FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            onPressed: () {
              showDialog(
  context: context,
  builder: (context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context, 'add')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context, 'username'),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context, 'password'),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context, 'passrep'),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context, 'cancel')),
        ),
        ElevatedButton(
          onPressed: () {
            if (_usernameController.text.isNotEmpty &&
                _emailController.text.isNotEmpty &&
                _passwordController.text.isNotEmpty &&
                _passwordController.text == _confirmPasswordController.text) {
              addNewUser(_usernameController.text, _passwordController.text, _emailController.text);
              Navigator.pop(context);
            } else {
              _showError('Passwords do not match or fields are empty');
            }
          },
          child: Text(AppLocalizations.of(context, 'add')),
        ),
      ],
    );
  },
);

            },
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Future<void> updatePassword(String newPassword) async {
    if (selectedRowId != null) {
      try {
        await ApiService.updateUserPassword(selectedRowId!, newPassword);
        _passwordController.clear();
        _confirmPasswordController.clear();
        fetchUsers();
        _showError('Succesfully updated password for $selectedRowText');
      } catch (e) {
        _showError('Error updating password: $e');
      }
    }
  }
}
