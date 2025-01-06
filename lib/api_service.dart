import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = "https://Sakojadi2.pythonanywhere.com/api/"; // Change for iOS or physical device
// https://Sakojadi2.pythonanywhere.com/
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
  static Future<void> addNewUser(String username, String password, String email) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          'email':email,
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

  static Future<bool> addTransaction(String transactionType, String currency, String quantity, String rate, String total) async {
  try {
    final response = await http.post(
      Uri.parse('${_baseUrl}transactions/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        // 'user': user,
        'transaction_type': transactionType,
        'currency': currency,
        'quantity': quantity,
        'rate': rate,
        'total': total,
      }),
    );
    if (response.statusCode == 403) {
  print('Error details: ${response.body}');
}

    if (response.statusCode == 201) {
      return true;  // Success
    }
     else {
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
      // final response2 = await http.delete(Uri.parse('${_baseUrl}delete/valutas/'));

      if (response1.statusCode == 200) {  //&& response2.statusCode == 200
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

static Future<void> updateUserPassword(int id, String newPassword) async {
  final response = await http.put(
    Uri.parse('${_baseUrl}userss/$id/'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'password': newPassword}),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update password');
  }
}

static Future<double?> fetchLatestRateFromTransactions(String? valuta, String transactionType) async {
  try {
    if(transactionType == "up"){
      transactionType = "buy";
    }
    else{
      transactionType = "sell";
    }
    final transactions = await fetchTransactions();
    print(' transactions: $transactions');
    print('valuta: $valuta, transactionType: $transactionType');


    // Filter transactions based on both valuta and transaction type
    final filteredTransactions = transactions
        .where((transaction) => transaction['currency'] == valuta && transaction['transaction_type'] == transactionType)
        .toList();

    print('Filtered transactions: $filteredTransactions');
    if (filteredTransactions.isEmpty) {
      return null;  // Return null if no transactions match the criteria
    }

    // Find the latest transaction based on the date
    final latestTransaction = filteredTransactions.reduce((a, b) {
      return DateTime.parse(a['date']).isAfter(DateTime.parse(b['date'])) ? a : b;
    });

    // Return the latest rate (Курс) for the selected transaction type
    return double.tryParse(latestTransaction['rate'].toString());
  } catch (e) {
    throw Exception('Error fetching latest rate from transactions: $e');
  }
}
static Future<Map<String, double>> fetchCurrencyRates(String token) async {
  final response = await http.get(
    Uri.parse('https://data.fx.kg/api/v1/central'),
    headers: {
      'Authorization': 'Bearer $token', // Provide the token for authentication
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    // Parse the currency rates from the response with safe handling
    return {
      'usd': _parseRate(data['usd']),
      'eur': _parseRate(data['eur']),
      'kzt': _parseRate(data['kzt']),
      'rub': _parseRate(data['rub']),
      'gbp': _parseRate(data['gbp']),
      'dkk': _parseRate(data['dkk']),
      'inr': _parseRate(data['inr']),
      'cad': _parseRate(data['cad']),
      'cny': _parseRate(data['cny']),
      'krw': _parseRate(data['krw']),
      'nok': _parseRate(data['nok']),
      'xdr': _parseRate(data['xdr']),
      'sek': _parseRate(data['sek']),
      'chf': _parseRate(data['chf']),
      'jpy': _parseRate(data['jpy']),
      'amd': _parseRate(data['amd']),
      'byr': _parseRate(data['byr']),
      'mdl': _parseRate(data['mdl']),
      'tjs': _parseRate(data['tjs']),
      'uzs': _parseRate(data['uzs']),
      'uah': _parseRate(data['uah']),
      'kwd': _parseRate(data['kwd']),
      'huf': _parseRate(data['huf']),
      'czk': _parseRate(data['czk']),
      'nzd': _parseRate(data['nzd']),
      'pkr': _parseRate(data['pkr']),
      'aud': _parseRate(data['aud']),
      'try': _parseRate(data['try']),
      'azn': _parseRate(data['azn']),
      'sgd': _parseRate(data['sgd']),
      'afn': _parseRate(data['afn']),
      'bgn': _parseRate(data['bgn']),
      'brl': _parseRate(data['brl']),
      'gel': _parseRate(data['gel']),
      'aed': _parseRate(data['aed']),
      'irr': _parseRate(data['irr']),
      'myr': _parseRate(data['myr']),
      'mnt': _parseRate(data['mnt']),
      'twd': _parseRate(data['twd']),
      'tmt': _parseRate(data['tmt']),
      'pln': _parseRate(data['pln']),
      'sar': _parseRate(data['sar']),
      'byn': _parseRate(data['byn']),
    };
  } else {
    throw Exception('Failed to load currency rates');
  }
}

// Helper method to parse the currency rates safely
static double _parseRate(String? rate) {
  try {
    return rate != null && rate.isNotEmpty ? double.parse(rate) : 0.0;
  } catch (e) {
    return 0.0; // Return 0.0 if the value is not a valid double
  }
}

static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse('${_baseUrl}password-reset/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': jsonDecode(response.body)['message']};
      }
      else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['error'] ?? 'An error occurred'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to connect to the server'};
    }
  }



}
