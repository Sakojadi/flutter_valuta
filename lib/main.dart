import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'events.dart';
import 'valuta.dart';
import 'reports.dart';
import 'kassa.dart';
import 'users.dart';
import 'api_service.dart'; 
import 'login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valuta',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey)
      ),
      home: LoginPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  final String username;

  MainPage({required this.username});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  bool _isRailOpen = false;
  int _selectedIndex = 0;
  String? _selectedItem;
  String? _selectedButton;
  final TextEditingController _kolichestvoController = TextEditingController();
  final TextEditingController _kursController = TextEditingController();
  final TextEditingController _obshiyController = TextEditingController();
  List<Map<String, dynamic>> _valutaList = [];

  bool _isKolichestvoValid = true;
  bool _isKursValid = true;
  bool _isValutaValid = true;
  bool _isArrowSelected = true;

  Future<void> fetchValutas() async {
    try {
      final valutas = await ApiService.fetchValutas();
      setState(() {
        _valutaList = valutas;
      });
    } catch (e) {
      print('Error fetching valutas: $e');
    }
  }
  Future<void> addTransaction() async {
  _validateFields();
  if (_isKolichestvoValid && _isKursValid && _isValutaValid && _isArrowSelected) {
    final transactionType = _selectedButton == 'up' ? 'buy' : 'sell';

    // Pass the selected valuta name (text) for the transaction
    final result = await ApiService.addTransaction(
      widget.username,
      transactionType,
      _selectedItem ?? '',  // Pass the valuta name (text)
      _kolichestvoController.text,
      _kursController.text,
      _obshiyController.text,
    );

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction added successfully')),
      );

      // Clear fields
      setState(() {
        _kolichestvoController.clear();
        _kursController.clear();
        _obshiyController.clear();
        _selectedItem = null;
        _selectedButton = null;
      });
    }else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add the transaction")));
    }
  }
}


  @override
  void initState() {
    super.initState();
    _kolichestvoController.addListener(_calculateResult);
    _kursController.addListener(_calculateResult);
    fetchValutas();
  }

  @override
  void dispose() {
    _kolichestvoController.dispose();
    _kursController.dispose();
    _obshiyController.dispose();
    super.dispose();
  }

  void _calculateResult() {
    final kolichestvo = double.tryParse(_kolichestvoController.text) ?? 0.0;
    final kurs = double.tryParse(_kursController.text) ?? 0.0;
    final result = kolichestvo * kurs;

    _obshiyController.text = result.toStringAsFixed(2);
  }

  // Validate all fields
  void _validateFields() {
    setState(() {
      // Check if fields are empty
      _isKolichestvoValid = _kolichestvoController.text.isNotEmpty;
      _isKursValid = _kursController.text.isNotEmpty;
      _isValutaValid = _selectedItem != null;
      _isArrowSelected = _selectedButton != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Главная'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _isRailOpen = !_isRailOpen; // Toggle the NavigationRail
            });
          },
        ),
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Up and Down Arrows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedButton = 'up';
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedButton == 'up' ? Colors.blueGrey : Colors.transparent,
                            border: Border.all(
                              color: !_isArrowSelected ? Colors.red : Colors.blueGrey,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.arrow_upward,
                            color: _selectedButton == 'up' ? Colors.white : Colors.black,
                            size: 36.0,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedButton = 'down';
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedButton == 'down' ? Colors.blueGrey : Colors.transparent,
                            border: Border.all(
                              color: !_isArrowSelected ? Colors.red : Colors.blueGrey,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.arrow_downward,
                            color: _selectedButton == 'down' ? Colors.white : Colors.black,
                            size: 36.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  
                  // Dropdown
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: !_isValutaValid ? Colors.red : Colors.blueGrey,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButton<String>(
                    value: _selectedItem, // Keep the selected valuta name
                    hint: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Select an option'),
                    ),
                    isExpanded: true,
                    items: _valutaList.map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
                      return DropdownMenuItem<String>(
                        value: item['valuta'],  // Use valuta name as value
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(item['valuta'] ?? ''),  // Display the valuta name
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedItem = newValue; // Save the selected valuta name
                      });
                    },
                  )

                  ),
                  SizedBox(height: 20),
                  
                  // Kolichestvo TextField
                  TextField(
                    controller: _kolichestvoController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Количество',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _isKolichestvoValid ? Theme.of(context).primaryColor : Colors.red,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _isKolichestvoValid
                              ? Theme.of(context).primaryColor
                              : Colors.red,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  
                  // Kurs TextField
                  TextField(
                    controller: _kursController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Курс',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _isKursValid ? Theme.of(context).primaryColor: Colors.red,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _isKursValid
                              ? Theme.of(context).primaryColor
                              : Colors.red,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  
                  // Obshiy TextField (readonly)
                  TextFormField(
                    controller: _obshiyController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Общий',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Add Button
                  ElevatedButton(
                    onPressed: () {
                      _validateFields();
                      if (_isKolichestvoValid && _isKursValid && _isValutaValid && _isArrowSelected) {
                        addTransaction();
                      }
                    },
                    child: Text('Добавить'),

            ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to secondary window
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TransactionsPage()),
                      );
                    },
                    child: Text('События'),
                  ),
                ],
              ),
            ),
          ),

          // Navigation Rail Overlay
          if (_isRailOpen)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isRailOpen = false; // Close NavigationRail when tapping outside
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.5), // Dim background
              ),
            ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            left: _isRailOpen ? 0 : -200, // Slide in/out effect
            top: 0,
            bottom: 0,
            child: Material(
              elevation: 8,
              child: Container(
                width: 200, // Fixed size for the NavigationRail
                color: Colors.blueGrey[50],
                child: NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                      switch(index){
                      case(1):
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Valuta(username: widget.username)));
                      case(2):
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Reports()));
                      case(3):
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => KassaPage()));
                      case(4):
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Users()));
                      case(5):
                      }
                      _isRailOpen = false; 
                      _selectedIndex = 0;
                                                            });
                  },
                  extended: true,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Главная'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.money),
                      label: Text('Валюта'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.info),
                      label: Text('Отчеты'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.money),
                      label: Text('Касса'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person),
                      label: Text('Пользователи'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.delete),
                      label: Text('Очистить'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
