import 'package:flutter/material.dart';
import 'api_service.dart';

class Users extends StatefulWidget {
  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<Users> {
  List<Map<String, dynamic>> userData = []; // To store the fetched data
  int? selectedRowId; // To track the selected row ID
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: userData.length,
                itemBuilder: (context, index) {
  var item = userData[index];
  return GestureDetector(
    onTap: () {
      setState(() {
        if (selectedRowId == item['id']) {  // Use item['id'] directly without int.parse
          selectedRowId = null; // Deselect if already selected
        } else {
          selectedRowId = item['id'];  // Use item['id'] directly without int.parse
        }
      });
    },
    child: Container(
      color: selectedRowId == item['id']  // Use item['id'] directly without int.parse
          ? Colors.yellow.withOpacity(0.2) // Selected row color
          : Colors.transparent,
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: ListTile(
        title: Text(item['username'] ?? ''), // Only show username
      ),
    ),
  );
}
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
          ],
          FloatingActionButton(
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
}
