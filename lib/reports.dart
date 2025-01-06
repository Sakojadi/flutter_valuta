import 'package:flutter/material.dart';
import 'app_localizations.dart';

class Reports extends StatefulWidget {
  @override
  ReportsState createState() => ReportsState();
}

class ReportsState extends State<Reports> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
        title: Text(AppLocalizations.of(context, 'reports')),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Text('Data added will be displayed here'),
      ),
    );
  }
}
