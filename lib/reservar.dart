import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ReservasScreen(),
    );
  }
}

class ReservasScreen extends StatefulWidget {
  @override
  _ReservasScreenState createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController fechaController = TextEditingController();
  TextEditingController horaController = TextEditingController();
  TextEditingController ubicacionController = TextEditingController();
  String? fecha;
  String? hora;
  String? ubicacion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservas de Estacionamiento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: fechaController,
                decoration:
                    InputDecoration(labelText: 'Fecha de Reserva (dd/mm/yyyy)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa una fecha válida (dd/mm/yyyy).';
                  }
                  if (!isValidDate(value)) {
                    return 'Ingresa una fecha válida (dd/mm/yyyy).';
                  }
                  return null;
                },
                onSaved: (value) {
                  fecha = value;
                },
              ),
              TextFormField(
                controller: horaController,
                decoration:
                    InputDecoration(labelText: 'Hora de Reserva (hh:mm)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa una hora válida (hh:mm).';
                  }
                  if (!isValidTime(value)) {
                    return 'Ingresa una hora válida (hh:mm).';
                  }
                  return null;
                },
                onSaved: (value) {
                  hora = value;
                },
              ),
              TextFormField(
                controller: ubicacionController,
                decoration: InputDecoration(
                    labelText: 'Ubicación (Ej. Calle y Número)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa una ubicación válida.';
                  }
                  return null;
                },
                onSaved: (value) {
                  ubicacion = value;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState != null &&
                      _formKey.currentState!.validate()) {
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

  static bool isValidDate(String value) {
    final dateRegex = RegExp(r'^\d{2}/\d{2}/2023$');
    if (!dateRegex.hasMatch(value)) return false;
    final parts = value.split('/');
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = 2023;
    if (day == null || month == null) return false;
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;
    return true;
  }

  static bool isValidTime(String value) {
    final timeRegex = RegExp(r'^\d{2}:\d{2}$');
    return timeRegex.hasMatch(value);
  }
}
