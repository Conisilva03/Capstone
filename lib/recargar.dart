import 'package:flutter/material.dart';

class RecargarDineroScreen extends StatefulWidget {
  @override
  _RecargarDineroScreenState createState() => _RecargarDineroScreenState();
}

class _RecargarDineroScreenState extends State<RecargarDineroScreen> {
  TextEditingController _montoController = TextEditingController();
  double saldo = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recargar Dinero'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Saldo: \$${saldo.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Lógica para recargar dinero
                // Puedes abrir un diálogo de confirmación antes de realizar la recarga.
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.lightBlue,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10), // Ajusta el tamaño del botón
              ),
              child: Text('RECARGAR', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 20),
            Text(
              'Monto:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                // Abre el teclado numérico cuando se toca el campo de texto
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: TextFormField(
                controller: _montoController,
                keyboardType: TextInputType.number, // Teclado numérico
                decoration: InputDecoration(
                  labelText: 'Ingrese el monto',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Lógica para seleccionar el método de pago
                // Puedes abrir una pantalla para seleccionar el método de pago aquí.
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.lightBlue,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10), // Ajusta el tamaño del botón
              ),
              child: Text('Seleccionar Método de Pago',
                  style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }
}
