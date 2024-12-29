import 'package:flutter/material.dart';

class Reports extends StatefulWidget {
  @override
  ReportsState createState() => ReportsState();
}


class ReportsState extends State<Reports> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('REPORTS')),
      ),
      body: Center(
        child: Text('Data added will be displayed here'),
      ),
    );
  }
}
