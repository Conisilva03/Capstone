import 'package:flutter/material.dart';
import 'map_screen.dart'; // Import the new Dart file
import 'tabs.dart';
import 'package:provider/provider.dart';
import 'dark_mode_manager.dart';

class MapsScreen extends StatefulWidget {
  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  @override
  Widget build(BuildContext context) {
    final darkModeManager = Provider.of<DarkModeManager>(context); // Use Provider.of

    final lightTheme = ThemeData.light();
    final darkTheme = ThemeData.dark();

    final theme = darkModeManager.darkModeEnabled ? darkTheme : lightTheme;

    return MaterialApp(
      theme: theme,
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        appBar: AppBar(
          title: Text('Tu app de Talcahuano'),
        ),
        drawer: buildDrawer(context),
        body: MapScreen(), // Use the new MapScreen widget
      ),
    );
  }
}
