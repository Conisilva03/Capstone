import 'package:flutter/material.dart';

class AgregarVehiculosScreen extends StatefulWidget {
  @override
  _AgregarVehiculosScreenState createState() => _AgregarVehiculosScreenState();
}

class _AgregarVehiculosScreenState extends State<AgregarVehiculosScreen> {
  // Variables para los campos de entrada
  TextEditingController _marcaController = TextEditingController();
  TextEditingController _modeloController = TextEditingController();
  TextEditingController _anioController = TextEditingController();
  TextEditingController _placaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Vehículo'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo de marca
            TextFormField(
              controller: _marcaController,
              decoration: InputDecoration(labelText: 'Marca'),
            ),

            SizedBox(height: 20),

            // Campo de modelo
            TextFormField(
              controller: _modeloController,
              decoration: InputDecoration(labelText: 'Modelo'),
            ),

            SizedBox(height: 20),

            // Campo de año
            TextFormField(
              controller: _anioController,
              decoration: InputDecoration(labelText: 'Año'),
            ),

            SizedBox(height: 20),

            // Campo de placa
            TextFormField(
              controller: _placaController,
              decoration: InputDecoration(labelText: 'Patente'),
            ),

            SizedBox(height: 20),

            // Botón para agregar vehículo
            ElevatedButton(
              onPressed: () {
                // Tu lógica para agregar el vehículo aquí
                String marca = _marcaController.text;
                String modelo = _modeloController.text;
                String anio = _anioController.text;
                String placa = _placaController.text;

                // Realiza la lógica para agregar el vehículo, por ejemplo, enviar los datos a una base de datos.

                // Después de agregar el vehículo, puedes realizar una acción adicional, como navegar a la pantalla de inicio o mostrar un mensaje de éxito.
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Color azul
                onPrimary: Colors.white, // Texto blanco
              ),
              child: Text('Agregar Vehículo'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Liberar los controladores al cerrar la pantalla para evitar fugas de memoria.
    _marcaController.dispose();
    _modeloController.dispose();
    _anioController.dispose();
    _placaController.dispose();
    super.dispose();
  }
}
