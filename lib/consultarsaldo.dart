import 'package:flutter/material.dart';

class ConsultarSaldoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consultar Saldo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Saldo actual
            Text(
              'Saldo Actual:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '\$100.00', // Aquí muestra el saldo actual (puedes obtenerlo de tus datos o una base de datos)
              style: TextStyle(fontSize: 24),
            ),

            SizedBox(height: 20),

            // Botón para consultar saldo
            ElevatedButton(
              onPressed: () {
                // Aquí puedes agregar la lógica para consultar el saldo
                // Puedes actualizar el saldo desde tus datos o una API
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Color azul
                onPrimary: Colors.white, // Texto blanco
              ),
              child: Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
