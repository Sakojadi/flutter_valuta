import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'events.dart';
import 'valuta.dart';
import 'reports.dart';
import 'kassa.dart';
import 'users.dart';
import 'api_service.dart'; 
import 'login.dart';
import 'falling_dollars.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_localizations.dart';


void main() {
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('en');  // Default language is English

  // Change language
  void changeLanguage(String languageCode) {
    setState(() {
      _locale = Locale(languageCode); // Set the new language
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Valuta',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        primaryColor: Colors.yellow[700]!,
        colorScheme: ColorScheme.dark(
          primary: Colors.yellow[700]!,
          secondary: Colors.teal[300]!,
          surface: Color.fromARGB(255, 18, 18, 18),
          error: Colors.redAccent,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[700],
            foregroundColor: Colors.black,
            elevation: 4.0,
          ),
        ),
      ),
      locale: _locale,  // Set the current locale
      supportedLocales: [
        Locale('en', 'US'), // English
        Locale('ru', 'RU'), // Russian
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: LoginPage(changeLanguage: changeLanguage),  // Pass the language change function to the LoginPage
    );
  }
}



class MainPage extends StatefulWidget {
  final String username;
  final Function(String) changeLanguage;

  MainPage({required this.username, required this.changeLanguage});

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
  bool isEnglishSelected = true; 
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

  Future<void> deleteAllData() async {
    bool result = await ApiService.deleteAllData();
    if (result){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('All data deleted successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete all data')));
    }
  }


  Future<void> addTransaction() async {
  _validateFields();
  if (_isKolichestvoValid && _isKursValid && _isValutaValid && _isArrowSelected) {
    final transactionType = _selectedButton == 'up' ? 'buy' : 'sell';

    // Pass the selected valuta name (text) for the transaction
    final result = await ApiService.addTransaction(
      // widget.username,
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
     if (widget.changeLanguage == 'ru') {
      isEnglishSelected = false; // Russian is selected
    } else {
      isEnglishSelected = true; // Default to English
    }
  
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
      _isKolichestvoValid = _kolichestvoController.text.isNotEmpty;
      _isKursValid = _kursController.text.isNotEmpty;
      _isValutaValid = _selectedItem != null;
      _isArrowSelected = _selectedButton != null;
    });
  }

  Future<void> fetchLatestRate(String valuta, String trans) async {
    try {
      final latestRate = await ApiService.fetchLatestRateFromTransactions(valuta, trans); // Assuming this method exists
      setState(() {
        _kursController.text = latestRate?.toString() ?? ''; // Update the rate field, or leave it empty if not found
      });
    } catch (e) {
      print('Error fetching latest rate: $e');
    }
  }
  
  void _onValutaSelected() async {
    
  if (_selectedItem != null && _selectedButton != null)  {
    try {
      print("lol hello: $_selectedItem");
      // Fetch the latest rate from the transactions for the selected valuta
      double? latestRate = await ApiService.fetchLatestRateFromTransactions(_selectedItem, _selectedButton!);
      if (latestRate != null) {
        // If a rate is found, update the rate field (Kurs)
        _kursController.text = latestRate.toStringAsFixed(2);
      } else {
        // If no rate found, leave the field empty or handle as needed
        _kursController.clear();
      }
    } catch (e) {
      print('Error fetching latest rate: $e');
    }
  }
  
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context, 'main')),
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
                            _onValutaSelected();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedButton == 'up' ?Theme.of(context).primaryColor : Colors.transparent,
                            border: Border.all(
                              color: !_isArrowSelected ? Colors.red : Theme.of(context).primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.arrow_upward,
                            color: Colors.white ,
                            size: 36.0,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedButton = 'down';
                            _onValutaSelected();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedButton == 'down' ? Theme.of(context).primaryColor : Colors.transparent,
                            border: Border.all(
                              color: !_isArrowSelected ? Colors.red : Theme.of(context).primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.arrow_downward,
                            color: Colors.white,
                            size: 36.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: !_isValutaValid
                      ? Colors.red
                      : Theme.of(context).primaryColor, // Match text field border color logic
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add inner padding
              child: DropdownButtonHideUnderline( // Remove the default underline
                child: DropdownButton<String>(
                  value: _selectedItem, // Keep the selected valuta name
                  hint: Text(
                    AppLocalizations.of(context, 'select'),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color, // Match text color
                    ),
                  ),
                  isExpanded: true,
                  items: _valutaList.map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
                    return DropdownMenuItem<String>(
                      value: item['valuta'], // Use valuta name as value
                      child: Text(
                        item['valuta'] ?? '',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color, // Match text color
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedItem = newValue; 
                      _onValutaSelected();
                                          });
                  },
                ),
              ),
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
                      labelText: AppLocalizations.of(context, 'quantity'),
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
                      labelText: AppLocalizations.of(context, 'rate'),
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
                      labelText: AppLocalizations.of(context, 'total'),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: 
                              Theme.of(context).primaryColor
                        ),
                      ),
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
child: Text(AppLocalizations.of(context, 'add')),

            ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to secondary window
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TransactionsPage()),
                      );
                      resetState();
                    },
                    child: Text(AppLocalizations.of(context, 'events')),
                  ),
                ],
              ),
            ),
          ),

          // Navigation Rail Overlay
          Stack(
  children: [
    // Dimmed background when rail is open
    if (_isRailOpen)
      GestureDetector(
        onTap: () {
          setState(() {
            _isRailOpen = false; // Close NavigationRail when tapping outside
          });
        },
        child: Container(
          color: Colors.black.withOpacity(0.5), // Dim background
          height: MediaQuery.of(context).size.height, // Full screen height
          width: MediaQuery.of(context).size.width, // Full screen width
        ),
      ),
    // NavigationRail with shadow
    AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      left: _isRailOpen ? 0 : -200, // Slide in/out effect
      top: 0,
      bottom: 0,
      child: Material(
        elevation: 8, // Shadow effect
        child: Container(
          width: 200, // Fixed size for the NavigationRail
          height: MediaQuery.of(context).size.height, // Full screen height
          color: Colors.black, // Background color for the rail
          child: Column(
            children: [
              // Upper section with profile and logout
              Container(
                color: Theme.of(context).colorScheme.surface, // Entirely yellow background
                padding: EdgeInsets.all(16), // Padding around profile and button
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          foregroundColor: Colors.white,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          child: Icon(Icons.person), // Profile icon
                        ),
                        SizedBox(width: 8), // Spacing between icon and text
                        Expanded(
                          child: Text(
                            widget.username, // Display the username
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis, // Handle long usernames
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16), // Space between profile and logout button
                    SizedBox(
                      width: double.infinity, // Full width for logout button
                      child: IconButton(
                        icon: Icon(
                          Icons.exit_to_app,
                          color: Colors.red,
                          size: 36, // Bigger size for the logout icon
                        ),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage(changeLanguage: widget.changeLanguage)), // Go back to LoginPage
                            (route) => false, // Clear navigation stack
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Remaining destinations
              Expanded(
                child: NavigationRail(
                  backgroundColor: Colors.yellow[700], // Background for main destinations
                  indicatorColor: Colors.black,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
  setState(() {
    _selectedIndex = index;
    _isRailOpen = false;
    _selectedIndex = 0;
  });

  if (index == 1) {
    () async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Valuta()),
      );

      if (result == true) {
        fetchValutas(); // Trigger fetchValutas if something was added or deleted
      }
      resetState();
    }(); // Immediately invoke the async function
  } else if (index == 2) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Reports()),
    );
    resetState();
  } else if (index == 3) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => KassaPage()),
    );
    resetState();
  } else if (index == 4) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Users(username: widget.username)),
    );
    resetState();
  } else if (index == 5) {
    showDeleteConfirmationDialog(context);
  }

                  },
                  extended: true,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home, color: Colors.white),
                      label: Text(AppLocalizations.of(context, 'main'), style: TextStyle(color: Colors.black)),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.money, color: Colors.black),
                      label: Text(AppLocalizations.of(context, 'currency'), style: TextStyle(color: Colors.black)),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.info, color: Colors.black),
                      label: Text(AppLocalizations.of(context, 'reports'), style: TextStyle(color: Colors.black)),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.wallet, color: Colors.black),
                      label: Text(AppLocalizations.of(context, 'cash'), style: TextStyle(color: Colors.black)),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person, color: Colors.black),
                      label: Text(AppLocalizations.of(context, 'users'), style: TextStyle(color: Colors.black)),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.delete, color: Colors.black),
                      label: Text(AppLocalizations.of(context, 'clear'), style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
              Padding(
  padding: const EdgeInsets.all(8.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // English button
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnglishSelected ? Colors.yellow[700] : Colors.grey,
        ),
        onPressed: () {
          setState(() {
            isEnglishSelected = true;  // Set English to selected
          });
          widget.changeLanguage('en');  // Change language to English
        },
        child: Text('ENG'),
      ),
      SizedBox(width: 8),
      // Russian button
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: !isEnglishSelected ? Colors.yellow[700] : Colors.grey,
        ),
        onPressed: () {
          setState(() {
            isEnglishSelected = false;  // Set Russian to selected
          });
          widget.changeLanguage('ru');  // Change language to Russian
        },
        child: Text('RU'),
      ),
    ],
  ),
)

            ],
          ),
        ),
      ),
    ),
  ],
),

        ],
      ),
    );
  }

void resetState() {
  _isKolichestvoValid = true;
  _isKursValid = true;
  _isValutaValid = true;
  _isArrowSelected = true;
  setState(() {
    _kolichestvoController.clear();
    _kursController.clear();
    _obshiyController.clear();
    _selectedItem = null;
    _selectedButton = null;
  });
}

void showDeleteConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing the dialog by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context, 'deleteAll')),
        actions: <Widget>[
          TextButton(
            child: Text(AppLocalizations.of(context, 'no')),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: Text(AppLocalizations.of(context, 'yes')),
            onPressed: () {
              deleteAllData();
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}
}
