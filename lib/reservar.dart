import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class ParkingSpace {
  final String id;
  final LatLng location;
  final String name;
  final String description;
  final String locationAddress; // Dirección detallada del estacionamiento
  final bool state;

  ParkingSpace(this.id, this.location, this.name, this.description,
      this.locationAddress, this.state);
}

class ReservarScreen extends StatefulWidget {
  final String id;
  ReservarScreen({required this.id});

  @override
  _ReservarScreenState createState() => _ReservarScreenState();
}

class _ReservarScreenState extends State<ReservarScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController fechaController = TextEditingController();
  TextEditingController horaController = TextEditingController();
  TextEditingController ubicacionController = TextEditingController();
  String? fecha;
  String? hora;
  String? ubicacion;
  ParkingSpace? parkingSpace;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    loadParkingSpace();
  }

  Future<ParkingSpace?> fetchData(String id) async {
    try {
      final response = await http
          .get(Uri.parse('https://api1.marweg.cl/parking_spaces/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ParkingSpace(
            data['id'],
            LatLng(data['latitude'], data['longitude']),
            data['name'],
            data['description'],
            data['location'],
            data['state']);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error al cargar datos: $e');
      return null;
    }
  }

  Future<void> loadParkingSpace() async {
    ParkingSpace? fetchedParkingSpace = await fetchData(widget.id);
    if (fetchedParkingSpace != null) {
      setState(() {
        parkingSpace = fetchedParkingSpace;
        ubicacionController.text = parkingSpace!.location.toString();
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (time != null && time != selectedTime) {
      setState(() {
        selectedTime = time;
        horaController.text =
            '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Reservar Estacionamiento - ${parkingSpace?.name ?? "Cargando..."}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            // Cambiado a ListView para evitar overflow
            children: <Widget>[
              if (parkingSpace != null) ...[
                Text('Nombre: ${parkingSpace!.name}'),
                Text('Descripción: ${parkingSpace!.description}'),
                Text('Ubicación: ${parkingSpace!.locationAddress}'),
                SizedBox(height: 20),
              ],
              ListTile(
                title: Text(
                    'Fecha de Reserva: ${fechaController.text.isEmpty ? "Seleccionar fecha" : fechaController.text}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2024),
                  );
                  if (pickedDate != null)
                    setState(() {
                      fechaController.text =
                          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                    });
                },
              ),
              ListTile(
                title: Text(
                  selectedTime != null
                      ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                      : 'Seleccione una hora',
                ),
                trailing: Icon(Icons.access_time),
                onTap: _pickTime,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Reserva creada: Fecha: $fecha, Hora: $hora, Ubicación: $ubicacion'),
                      ),
                    );
                  }
                },
                child: Text('Reservar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isValidDate(String input) {
    final RegExp regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    return regex.hasMatch(input);
  }

  bool isValidTime(String input) {
    final RegExp regex = RegExp(r'^\d{2}:\d{2}$');
    return regex.hasMatch(input);
  }
}
