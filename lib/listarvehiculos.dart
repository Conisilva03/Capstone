import 'package:flutter/material.dart';
import 'tabs.dart';
import 'package:provider/provider.dart';
import 'dark_mode_manager.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; // Add this import

class ListarVehiculosScreen extends StatefulWidget {
  @override
  _ListarVehiculosScreenState createState() => _ListarVehiculosScreenState();
}

class _ListarVehiculosScreenState extends State<ListarVehiculosScreen> {
  // List of vehicles
  List<Vehiculo> vehiculos = []; // Initialize an empty list

  @override
  void initState() {
    super.initState();
    // Fetch vehicle data when the widget is initialized
    fetchVehicleData();
  }

  Future<void> fetchVehicleData() async {
    // Replace with your API URL
    final apiUrl = Uri.parse('http://localhost:8000/cars/1');

    try {
      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          // Convert JSON data into a list of Vehiculo objects
          vehiculos = data.map((item) => Vehiculo.fromJson(item)).toList();
        });
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception or handle the error as needed.
        print('Failed to load vehicle data');
      }
    } catch (exception) {
      print('Exception while fetching vehicle data: $exception');
    }
  }

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
              title: Text('Listar Vehículos'),
            ),
            body: ListView.builder(
              itemCount: vehiculos.length,
              itemBuilder: (context, index) {
                final vehiculo = vehiculos[index];
                return ListTile(
                  title: Text('${vehiculo.marca} ${vehiculo.modelo}'),
                  subtitle: Text('Año: ${vehiculo.anio} - Placa: ${vehiculo.placa}'),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey),
                    itemBuilder: (context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'seleccionar',
                        child: Text('Seleccionar'),
                      ),
                      PopupMenuItem<String>(
                        value: 'editar',
                        child: Text('Editar'),
                      ),
                      PopupMenuItem<String>(
                        value: 'eliminar',
                        child: Text('Desactivar'),
                      ),
                    ],
                    onSelected: (String choice) {
                      // Handle user selection here
                      switch (choice) {
                        case 'seleccionar':
                          // Logic for selecting the vehicle
                          break;
                        case 'editar':
                          // Logic for editing the vehicle
                          break;
                        case 'eliminar':
                          // Logic for deleting the vehicle
                          break;
                      }
                    },
                  ),
                );
              },
            ),
            drawer: buildDrawer(context),
          ),
        );
      },
    );
  }
}

class Vehiculo {
  final String marca;
  final String modelo;
  final int anio;
  final String placa;

  Vehiculo({
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.placa,
  });

  // Factory constructor to create Vehiculo objects from JSON
  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      marca: json['brand'],
      modelo: json['model'],
      anio: json['year'],
      placa: json['license_plate'],
    );
  }
}
