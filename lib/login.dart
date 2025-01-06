import 'package:flutter/material.dart';
import 'api_service.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'falling_dollars.dart';
import 'app_localizations.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
    final Function(String) changeLanguage;
    LoginPage({required this.changeLanguage});

}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmailEnabled = false;  

  // Call the login API
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Call ApiService to login
    final result = await ApiService.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (result['success'] == true) {
      // Navigate to the main page after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage(username: _usernameController.text, changeLanguage: widget.changeLanguage)),
      );
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

 void _showForgotPasswordDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context, 'forgot')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ask for the email only
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text(AppLocalizations.of(context, 'cancel')),
          ),
          TextButton(
            onPressed: () async {
              final email = _emailController.text;

              if (email.isEmpty) {
                // Show an error if email is empty
                return;
              }

              // Call the password reset API with the provided email
              final result = await ApiService.forgotPassword(email);
              final message = result['message'];

              // Close the Forgot Password dialog
              Navigator.pop(context);

              // Show success or error message in a dialog
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(result['success'] ? 'Success' : 'Error'),
                    content: Text(message),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the success/error dialog
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );

              _emailController.clear(); // Clear the text field after submitting
            },
            child: Text(AppLocalizations.of(context, 'submit')),
          ),
        ],
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(AppLocalizations.of(context, 'login'))),
      ),
      body: 
        Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context, 'username'),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context, 'password'),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _login,
                    child: Text(AppLocalizations.of(context, 'login')),
                  ),
            SizedBox(height: 10),
            // Forgot Password link
            TextButton(
              onPressed: _showForgotPasswordDialog,
              child: Text(AppLocalizations.of(context, 'forgot'), style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}
