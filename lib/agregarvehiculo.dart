import 'package:flutter/material.dart';
import 'tabs.dart';
import 'package:provider/provider.dart';
import 'dark_mode_manager.dart';

class AgregarVehiculosScreen extends StatefulWidget {
  @override
  _AgregarVehiculosScreenState createState() => _AgregarVehiculosScreenState();
}

class _AgregarVehiculosScreenState extends State<AgregarVehiculosScreen> {
  // Variables for input fields
  TextEditingController _marcaController = TextEditingController();
  TextEditingController _modeloController = TextEditingController();
  TextEditingController _anioController = TextEditingController();
  TextEditingController _placaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<DarkModeManager>(
      builder: (context, darkModeManager, child) {
        final lightTheme = ThemeData.light();
        final darkTheme = ThemeData.dark();

        final theme = darkModeManager.darkModeEnabled ? darkTheme : lightTheme;

        return Theme(
          data: theme, // Apply the theme to this screen
          child: Scaffold(
            appBar: AppBar(
              title: Text('Agregar Vehículo'),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Marca field
                  TextFormField(
                    controller: _marcaController,
                    decoration: InputDecoration(labelText: 'Marca'),
                  ),

                  SizedBox(height: 20),

                  // Modelo field
                  TextFormField(
                    controller: _modeloController,
                    decoration: InputDecoration(labelText: 'Modelo'),
                  ),

                  SizedBox(height: 20),

                  // Año field
                  TextFormField(
                    controller: _anioController,
                    decoration: InputDecoration(labelText: 'Año'),
                  ),

                  SizedBox(height: 20),

                  // Placa field
                  TextFormField(
                    controller: _placaController,
                    decoration: InputDecoration(labelText: 'Patente'),
                  ),

                  SizedBox(height: 20),

                  // Button to add vehicle
                  ElevatedButton(
                    onPressed: () {
                      // Your logic to add the vehicle here
                      String marca = _marcaController.text;
                      String modelo = _modeloController.text;
                      String anio = _anioController.text;
                      String placa = _placaController.text;

                      // Perform the logic to add the vehicle, such as sending the data to a database.

                      // After adding the vehicle, you can perform additional actions, such as navigating to the home screen or displaying a success message.
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // Blue color
                      onPrimary: Colors.white, // White text
                    ),
                    child: Text('Agregar Vehículo'),
                  ),
                ],
              ),
            ),
            drawer: buildDrawer(context),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // Dispose of controllers to prevent memory leaks.
    _marcaController.dispose();
    _modeloController.dispose();
    _anioController.dispose();
    _placaController.dispose();
    super.dispose();
  }
}
