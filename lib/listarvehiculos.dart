import 'package:flutter/material.dart';

class ListarVehiculosScreen extends StatefulWidget {
  @override
  _ListarVehiculosScreenState createState() => _ListarVehiculosScreenState();
}

class _ListarVehiculosScreenState extends State<ListarVehiculosScreen> {
  // Lista de vehículos (puedes reemplazarla con tus datos reales)
  List<Vehiculo> vehiculos = [
    Vehiculo(marca: 'Toyota', modelo: 'Corolla', anio: 2020, placa: 'ABC123'),
    Vehiculo(marca: 'Honda', modelo: 'Civic', anio: 2019, placa: 'XYZ789'),
    // Agrega más vehículos aquí
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child: Text('Eliminar'),
                ),
              ],
              onSelected: (String choice) {
                // Manejar la selección del usuario aquí
                switch (choice) {
                  case 'seleccionar':
                    // Lógica para seleccionar el vehículo
                    break;
                  case 'editar':
                    // Lógica para editar el vehículo
                    break;
                  case 'eliminar':
                    // Lógica para eliminar el vehículo
                    break;
                }
              },
            ),
          );
        },
      ),
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
}
