import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'updateCar.dart';
import 'package:provider/provider.dart';
import 'dark_mode_manager.dart';

class ListarVehiculosScreen extends StatefulWidget {
  @override
  _ListarVehiculosScreenState createState() => _ListarVehiculosScreenState();
}

class _ListarVehiculosScreenState extends State<ListarVehiculosScreen> {
  List<Vehiculo> vehiculos = [];

  Future<int?> fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    int? userId = await fetchUserId();
    if (userId != null) {
      fetchVehicleData(userId);
    }
  }

  Future<void> fetchVehicleData(user_id) async {
    final apiUrl = Uri.parse('https://api2.parkingtalcahuano.cl/cars/$user_id');
    try {
      final response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          vehiculos = data
              .map((item) => Vehiculo.fromJson(item))
              .where((vehiculo) => vehiculo.is_active)
              .toList();
        });
        print(data);
      } else {
        print('Failed to load vehicle data');
      }
    } catch (exception) {
      print('Exception while fetching vehicle data: $exception');
    }
  }

  Future<void> actualizarEstadoEnUso(bool nuevoEstado, int id) async {
    final apiUrl = Uri.parse(
        'https://api2.parkingtalcahuano.cl/cars/$id/in_use?in_use=$nuevoEstado');

    try {
      final response = await http.put(apiUrl);
      if (response.statusCode == 200) {
        print('Estado de en uso actualizado exitosamente');

        // Si el nuevo estado es true, desactivar todos los demás vehículos
        if (nuevoEstado) {
          vehiculos.forEach((vehiculo) {
            if (vehiculo.id != id && vehiculo.enUso) {
              actualizarEstadoEnUso(false, vehiculo.id);
            }
          });
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListarVehiculosScreen(),
          ),
        );
      } else {
        print('Error al actualizar el estado de en uso');
      }
    } catch (exception) {
      print('Excepción al actualizar el estado de en uso: $exception');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DarkModeManager>(
      builder: (context, darkModeManager, child) {
        return Theme(
          data: darkModeManager.darkModeEnabled
              ? ThemeData.dark()
              : ThemeData.light(),
          child: Scaffold(
            appBar: AppBar(title: Text('Listar Vehículos')),
            body: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Marca')),
                  DataColumn(label: Text('Modelo')),
                  DataColumn(label: Text('Año')),
                  DataColumn(label: Text('Placa')),
                  DataColumn(label: Text('En Uso')),
                  DataColumn(label: Text('Usar')),
                  DataColumn(label: Text('Acción')),
                ],
                rows: vehiculos.map((vehiculo) {
                  return DataRow(cells: [
                    DataCell(Text(vehiculo.marca)),
                    DataCell(Text(vehiculo.modelo)),
                    DataCell(Text('${vehiculo.anio}')),
                    DataCell(Text(vehiculo.placa)),
                    DataCell(Text(vehiculo.enUso ? 'Sí' : 'No')),
                    DataCell(ElevatedButton(
                      child: Text(vehiculo.enUso ? 'Desactivar' : 'Activar'),
                      onPressed: () {
                        actualizarEstadoEnUso(!vehiculo.enUso, vehiculo.id);
                      },
                    )),
                    DataCell(ElevatedButton(
                      child: Text('Editar'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UpdateCarScreen(carId: vehiculo.id),
                          ),
                        );
                      },
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class Vehiculo {
  final int id;
  final String marca;
  final String modelo;
  final int anio;
  final String placa;
  final bool is_active;
  final bool enUso;

  Vehiculo({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.placa,
    required this.is_active,
    required this.enUso,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      id: json['id'],
      marca: json['brand'],
      modelo: json['model'],
      anio: json['year'],
      placa: json['license_plate'],
      is_active: json['is_active'],
      enUso: json['in_use'],
    );
  }
}
