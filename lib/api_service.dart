import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = "https://Sakojadi2.pythonanywhere.com/api/"; // Change for iOS or physical device

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

  static Future<bool> addTransaction(String user, String transactionType, String currency, String quantity, String rate, String total) async {
  try {
    final response = await http.post(
      Uri.parse('${_baseUrl}transactions/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'user': user,
        'transaction_type': transactionType,
        'currency': currency,
        'quantity': quantity,
        'rate': rate,
        'total': total,
      }),
    );

    if (response.statusCode == 201) {
      return true;  // Success
    } else {
      print('Failed to add transaction: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print("Error: $e");
    return false;
  }
}
static Future<List<Map<String, dynamic>>> fetchTransactions() async {
  try {
    final response = await http.get(
      Uri.parse('${_baseUrl}transactions/'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Parse the JSON response as a map, then extract the 'transactions' list
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> transactions = data['transactions']; // Get the list of transactions
      return transactions.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  } catch (e) {
    throw Exception('Error fetching transactions: $e');
  }
}

static Future<void> deleteTransaction(int id) async {
  try {
    final response = await http.delete(
      Uri.parse('${_baseUrl}transactions/$id/'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete transaction');
    }
  } catch (e) {
    throw Exception('Error deleting transaction: $e');
  }
}

static Future<bool> updateTransaction(int id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('${_baseUrl}transactions/$id/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedData),
    );

    return response.statusCode == 200;
  }

 static Future<bool> deleteAllData() async {
    try {
      final response1 = await http.delete(Uri.parse('${_baseUrl}delete/transactions/'));
      final response2 = await http.delete(Uri.parse('${_baseUrl}delete/valutas/'));

      if (response1.statusCode == 200 && response2.statusCode == 200) {
        return true;
      } else {
        print('Failed to delete data');
        return false;
      }
    } catch (e) {
      print('Error deleting data: $e');
      return false;
    }
  }

}
