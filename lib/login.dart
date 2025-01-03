import 'package:flutter/material.dart';
import 'api_service.dart';
import 'main.dart';
import 'package:http/http.dart' as http;


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

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
        MaterialPageRoute(builder: (context) => MainPage(username: _usernameController.text)),
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

  
// void _showForgotPasswordDialog() {
//   final TextEditingController _emailController = TextEditingController();

//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: Text('Forgot Your Password?'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: InputDecoration(labelText: 'Email'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context); // Close the dialog
//             },
//             child: Text('Cancel'),
//           ),
//           TextButton(
//   onPressed: () async {
//     print("Submitting forgot password request...");
//     final result = await ApiService.forgotPassword(
//       _emailController.text,
//     );
//     print(result); // Check the response

//     // Show success or error message based on result
//     String message = result['message'];
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(result['success'] ? 'Success' : 'Error'),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//     Navigator.pop(context); // Close the Forgot Password dialog
//   },
//   child: Text('Submit'),
// ),

//         ],
//       );
    // },
  // );



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Login')),
      ),
      body: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
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
                    child: Text('Login'),
                  ),
            // SizedBox(height: 10),
            // // Forgot Password link
            // TextButton(
            //   onPressed: _showForgotPasswordDialog,
            //   child: Text('Forgot your password?', style: TextStyle(color: Colors.blue)),
            // ),
          ],
        ),
      ),
    );
  }
}
