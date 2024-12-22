import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = "http://10.0.2.2:8000/api/"; // Change for iOS or physical device

  // Fetch all Valutas
  static Future<List<Map<String, dynamic>>> fetchValutas() async {
    final response = await http.get(Uri.parse('${_baseUrl}valutas/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => {
            'id': item['id'].toString(),
            'valuta': item['valuta'],
          }).toList();
    } else {
      throw Exception('Failed to load valutas');
    }
  }

  // Add new Valuta
  static Future<void> addNewValuta(String name) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}valutas/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'valuta': name}),
    );

    if (response.statusCode != 201) {
      throw Exception(
          'Failed to create valuta. Status code: ${response.statusCode}');
    }
  }

  // Delete a Valuta
  static Future<void> deleteValuta(int id) async {
    final response = await http.delete(
      Uri.parse('${_baseUrl}valutas/$id/'),
    );

    if (response.statusCode != 204) {
      throw Exception(
          'Failed to delete valuta. Status code: ${response.statusCode}');
    }
  }

static Future<List<Map<String, dynamic>>> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('${_baseUrl}users/'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Add a new user
  static Future<void> addNewUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add user');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete a user
  static Future<void> deleteUser(int userId) async {
    try {
      final response = await http.delete(Uri.parse('${_baseUrl}users/$userId/'));

      if (response.statusCode != 204) {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      rethrow;
    }
  }




  //fetchUsers
  // static Future<List<Map<String, dynamic>>> fetchUsers() async {
  //   final response = await http.get(Uri.parse('${_baseUrl}users/'));

  //   if (response.statusCode == 200) {
  //     List<dynamic> data = json.decode(response.body);
  //     return data.map((item) => {
  //           'id': item['id'].toString(),
  //           'username': item['username'],
  //           'password': item['password'],
  //         }).toList();
  //   } else {
  //     throw Exception('Failed to load users');
  //   }
  // }


  // // Add new User
  // static Future<void> addNewUser(String name, String password) async {
  //   final response = await http.post(
  //     Uri.parse('${_baseUrl}users/'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode({'username': name, 'password': password}),
  //   );

  //   if (response.statusCode != 201) {
  //     throw Exception(
  //         'Failed to create user. Status code: ${response.statusCode}');
  //   }
  // }

  // // Delete a User
  // static Future<void> deleteUser(int id) async {
  //   final response = await http.delete(
  //     Uri.parse('${_baseUrl}users/$id/'),
  //   );

  //   if (response.statusCode != 204) {
  //     throw Exception(
  //         'Failed to delete user. Status code: ${response.statusCode}');
  //   }
  // }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}login/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Invalid credentials'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error during login: $e'};
    }
  }

}
