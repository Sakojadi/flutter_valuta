import 'package:flutter/material.dart';
import 'api_service.dart';

class Valuta extends StatefulWidget {
  @override
  ValutaState createState() => ValutaState();
}

class ValutaState extends State<Valuta> {
  List<Map<String, dynamic>> valutaData = []; // To store the fetched data
  int? selectedRowId; // To track the selected row ID
  final TextEditingController _valutaController = TextEditingController();

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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    fetchValutas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Valuta Window'),
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
      child: Table(
        border: TableBorder(
          horizontalInside: BorderSide(
            color: Theme.of(context).colorScheme.surface, // Color of the horizontal border
            width: 4, // Thickness of the border
          ),
          verticalInside: BorderSide.none, // Remove vertical borders if needed
        ),
        children: valutaData.map<TableRow>((item) {
          return TableRow(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (selectedRowId == int.parse(item['id']!)) {
                      selectedRowId = null; // Deselect if already selected
                    } else {
                      selectedRowId = int.parse(item['id']!); // Select the current row
                    }
                  });
                },
                child: Container(
                  color: selectedRowId == int.parse(item['id']!)
                      ? Theme.of(context).colorScheme.secondary.withOpacity(0.6) // Highlighted row
                      : Theme.of(context).primaryColor, // Regular row color
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  alignment: Alignment.center,
                  child: Text(
                    item['valuta'] ?? '',
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
  ],
),

        // child: Column(
        //   crossAxisAlignment: CrossAxisAlignment.stretch,
        //   children: [
        //     SizedBox(height: 20),
        //     Expanded(
        //       child: ListView.builder(
        //         itemCount: valutaData.length,
        //         itemBuilder: (context, index) {
        //           var item = valutaData[index];
        //           return GestureDetector(
        //             onTap: () {
        //               setState(() {
        //                 if (selectedRowId == int.parse(item['id']!)) {
        //                   selectedRowId = null; // Deselect if already selected
        //                 } else {
        //                   selectedRowId = int.parse(item['id']!);
        //                 }
        //               });
        //             },
        //             child: Container(
        //               color: selectedRowId == int.parse(item['id']!)
        //                   ? Colors.yellow.withOpacity(0.2) // Selected row color
        //                   : Colors.transparent,
        //               padding: EdgeInsets.symmetric(vertical: 16.0),
        //               child: ListTile(
        //                 title: Text(item['valuta'] ?? ''),
        //               ),
        //             ),
        //           );
        //         },
        //       ),
        //     ),
        //   ],
        // ),
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
            onPressed: () {
              // Open dialog to add new valuta
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Add Valuta'),
                    content: TextField(
                      controller: _valutaController,
                      decoration: InputDecoration(
                        labelText: 'Enter Valuta',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), // Close dialog
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_valutaController.text.isNotEmpty) {
                            addNewValuta(_valutaController.text);
                          }
                          Navigator.pop(context); // Close dialog after adding
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
