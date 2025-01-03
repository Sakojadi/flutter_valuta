import 'package:flutter/material.dart';
import 'api_service.dart';

class Users extends StatefulWidget {
  final String username;
  Users({required this.username});
  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<Users> {
  List<Map<String, dynamic>> userData = []; // To store the fetched data
  int? selectedRowId; // To track the selected row ID
  String selectedRowText = '';
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Fetch all users from the API
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

  // Add a new user through ApiService
  Future<void> addNewUser(String username, String password) async {
    try {
      await ApiService.addNewUser(username, password);
      _usernameController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      fetchUsers(); // Refresh data after adding
    } catch (e) {
      _showError('Error adding user: $e');
    }
  }

  // Delete a user through ApiService
  Future<void> deleteUser() async {
    if (selectedRowId == null) return;
    try {
      await ApiService.deleteUser(selectedRowId!);
      setState(() {
        selectedRowId = null; // Reset selection
      });
      fetchUsers(); // Refresh data after deletion
    } catch (e) {
      _showError('Error deleting user: $e');
    }
  }

  // Display error messages
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
        title: Center(child: Text('USERS')),
    leading: IconButton(
      icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
            setState(() {
      selectedRowId = null;
    });},
        ),
      ),
      body: Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(height: 20),
      Expanded(
        child:SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Table(
           border: TableBorder(
            horizontalInside: BorderSide(
              color: Theme.of(context).colorScheme.surface, // Color of the horizontal border
              width: 4, // Thickness of the border
            ),
            verticalInside: BorderSide.none, // Remove vertical borders if needed
          ),
          children: userData.map<TableRow>((item) {
            return TableRow(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selectedRowId == item['id']) {  
                        selectedRowId = null; // Deselect if already selected
                      } else {
                        selectedRowId = item['id']; // Select the current row
                      }
                    });
                  },
                  child: Container(
                    color: selectedRowId == item['id'] // Highlight selected row
                        ? Theme.of(context).colorScheme.secondary.withOpacity(0.6)
                        : Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
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
                          labelText: 'New Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), // Close dialog
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_passwordController.text.isNotEmpty &&
                            _confirmPasswordController.text.isNotEmpty &&
                            _passwordController.text == _confirmPasswordController.text) {
                          updatePassword(_passwordController.text);
                          Navigator.pop(context); // Close dialog after updating
                        } else {
                          _showError('Passwords do not match or fields are empty');
                        }
                      },
                      child: Text('Change Password'),
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
              // Open dialog to add new user
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Add User'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), // Close dialog
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_usernameController.text.isNotEmpty &&
                              _passwordController.text.isNotEmpty &&
                              _passwordController.text == _confirmPasswordController.text) {
                            addNewUser(_usernameController.text, _passwordController.text);
                            Navigator.pop(context); // Close dialog after adding
                          } else {
                            _showError('Passwords do not match or fields are empty');
                          }
                        },
                        child: Text('Add'),
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
  // Update password for the user
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
