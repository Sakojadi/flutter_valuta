import 'package:flutter/material.dart';
import 'api_service.dart';
import 'dart:async'; // For using Timer
import 'app_localizations.dart';

class Valuta extends StatefulWidget {
  @override
  ValutaState createState() => ValutaState();
}

class ValutaState extends State<Valuta> {
  List<Map<String, dynamic>> valutaData = []; // To store the fetched data
  Map<String, double> currencyRates = {}; // To store currency rates
  int? selectedRowId; // To track the selected row ID
  final TextEditingController _valutaController = TextEditingController();
  Timer? _timer; // Timer for updating the data every 5 seconds

  // Fetch all valutas from the API
  Future<void> fetchValutas() async {
    try {
      final data = await ApiService.fetchValutas();
      setState(() {
        valutaData = data;
      });
    } catch (e) {
      _showError('Error fetching valutas: $e');
    }
  }

  // Fetch real-time exchange rates for currencies
  Future<void> fetchCurrencyRates() async {
    try {
      final response = await ApiService.fetchCurrencyRates('4D1QhBl3DxM9Df5QU0IixHWazbDCCjxYTtGfkhei4fa4313b');
      setState(() {
        currencyRates = response; // Update currency rates
      });
    } catch (e) {
      _showError('Error fetching currency rates: $e');
    }
  }

  // Set up a Timer to fetch data every 0 seconds
  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      fetchCurrencyRates(); // Fetch the currency rates every 10 seconds
    });
  }

  // Add a new valuta through ApiService
  Future<void> addNewValuta(String name) async {
    try {
      await ApiService.addNewValuta(name);
      _valutaController.clear();
      fetchValutas(); // Refresh data after adding
    } catch (e) {
      _showError('Error adding valuta: $e');
    }
  }

  // Delete a valuta through ApiService
  Future<void> deleteValuta() async {
    if (selectedRowId == null) return;
    try {
      await ApiService.deleteValuta(selectedRowId!);
      setState(() {
        selectedRowId = null; // Reset selection
      });
      fetchValutas(); // Refresh data after deletion
    } catch (e) {
      _showError('Error deleting valuta: $e');
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
    fetchValutas();
    fetchCurrencyRates(); // Fetch the currency rates initially
    startTimer(); // Start the timer for periodic updates
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context, 'currency')),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
            setState(() {
              selectedRowId = null;
            });
          },
        ),
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
      children: valutaData.map<TableRow>((item) {
        String currency = item['valuta'] ?? '';
        double rate = currencyRates[currency.toLowerCase()] ?? 0.0;  // Convert currency code to lowercase here

        return TableRow(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (selectedRowId == int.parse(item['id']!)) {
                    selectedRowId = null;
                  } else {
                    selectedRowId = int.parse(item['id']!);
                  }
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: selectedRowId == int.parse(item['id']!)
                      ? Theme.of(context).colorScheme.secondary.withOpacity(0.6)
                      : Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6.0,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      currency,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${AppLocalizations.of(context, 'rate')}: ${rate.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    ),
  ),
)

          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (selectedRowId != null) ...[
            FloatingActionButton(
              onPressed: deleteValuta,
              child: Icon(Icons.delete),
              backgroundColor: Colors.red,
            ),
            SizedBox(width: 10),
          ],
          FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            onPressed: () {
              // Open dialog to add new valuta
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context, 'add')),
                    content: TextField(
                      controller: _valutaController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context, 'enterVal'),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context, 'cancel')),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_valutaController.text.isNotEmpty) {
                            addNewValuta(_valutaController.text);
                          }
                          Navigator.pop(context);
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
}
