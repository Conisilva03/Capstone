import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Vehiculo {
  // Define the properties of your 'Vehiculo' class based on your API response
  final int id;
  final String brand;
  final String model;
  final int year;
  final String licensePlate;

  Vehiculo({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.licensePlate,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      id: json['id'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      licensePlate: json['license_plate'],
    );
  }
}

class UpdateCarScreen extends StatefulWidget {
  final int carId;

  UpdateCarScreen({required this.carId});

  @override
  _UpdateCarScreenState createState() => _UpdateCarScreenState();
}

class _UpdateCarScreenState extends State<UpdateCarScreen> {
  TextEditingController brandController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController licensePlateController = TextEditingController();

  List<Vehiculo> vehiculos = []; // Define the list of vehicles

  Future<void> fetchVehicleData(int userId) async {
    final apiUrl = Uri.parse('https://api2.parkingtalcahuano.cl/cars/$userId');
    try {
      final response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          vehiculos = data
              .map((item) => Vehiculo.fromJson(item))
              .where((vehiculo) => vehiculo.id == widget.carId)
              .toList();
        });
        print(vehiculos);
      } else {
        print('Failed to load vehicle data');
      }
    } catch (exception) {
      print('Exception while fetching vehicle data: $exception');
    }
  }




Future<int?> fetchUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userId = prefs.getInt('user_id');
  return userId;
}
@override
void initState() {
  super.initState();

  // Fetch user ID and vehicle data
  fetchUserId().then((userId) {
    if (userId != null) {
      fetchVehicleData(userId).then((_) {
        // Llenar los controladores de texto con los valores del primer vehículo
        if (vehiculos.isNotEmpty) {
          Vehiculo primerVehiculo = vehiculos.first;
          brandController.text = primerVehiculo.brand;
          modelController.text = primerVehiculo.model;
          yearController.text = primerVehiculo.year.toString();
          licensePlateController.text = primerVehiculo.licensePlate;
        }
      });
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Actualizar Auto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: brandController,
              decoration: InputDecoration(labelText: 'Marca'),
            ),
            TextFormField(
              controller: modelController,
              decoration: InputDecoration(labelText: 'Modelo'),
            ),
            TextFormField(
              controller: yearController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Año'),
            ),
            TextFormField(
              controller: licensePlateController,
              decoration: InputDecoration(labelText: 'Patente'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                updateCarDetails();
              },
              child: Text('Actualizar Auto'),
            ),
          ],
        ),
      ),
    );
  }

  void updateCarDetails() async {
    final apiUrl = Uri.parse('https://api2.parkingtalcahuano.cl/cars/${widget.carId}/update-details');
    try {
      final response = await http.put(
        apiUrl,
        body: jsonEncode({
          'brand': brandController.text,
          'model': modelController.text,
          'year': int.parse(yearController.text),
          'license_plate': licensePlateController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        // Car details updated successfully, fetch and update the details
        // You can navigate back to the listing screen if needed
        Navigator.pop(context);
      } else {
        // Handle error cases
        print('Failed to update car details');
      }
    } catch (exception) {
      print('Exception while updating car details: $exception');
    }
  }
}
