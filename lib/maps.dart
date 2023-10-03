import 'package:flutter/material.dart';
import 'tabs.dart';
import 'map_screen.dart'; // Import the new Dart file

void main() {
  runApp(MaterialApp(
    home: MapsScreen(),
  ));
}

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
      body: MapScreen(), // Use the new MapScreen widget
    );
  }
}
