import 'package:flutter/material.dart';
import 'tabs.dart';
import 'package:flutter_map/flutter_map.dart';

class MapsScreen extends StatefulWidget {
  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tu app de Talcahuano'),
      ),
      body: TabBarDemo(),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MapsScreen(),
  ));
}
