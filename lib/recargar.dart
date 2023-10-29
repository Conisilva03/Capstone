import 'package:flutter/material.dart';
import 'tabs.dart';
import 'package:provider/provider.dart';
import 'dark_mode_manager.dart';

class RecargarDineroScreen extends StatefulWidget {
  @override
  _RecargarDineroScreenState createState() => _RecargarDineroScreenState();
}

class _RecargarDineroScreenState extends State<RecargarDineroScreen> {
  TextEditingController _montoController = TextEditingController();
  double saldo = 0.0;
  String? metodoDePagoSeleccionado;

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
            Text(
              'Métodos de Pago:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            RadioListTile<String>(
              title: Text('Tarjeta de Crédito'),
              value: 'tarjeta_credito',
              groupValue: metodoDePagoSeleccionado,
              onChanged: (String? value) {
                setState(() {
                  metodoDePagoSeleccionado = value;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('Transferencia Bancaria'),
              value: 'transferencia',
              groupValue: metodoDePagoSeleccionado,
              onChanged: (String? value) {
                setState(() {
                  metodoDePagoSeleccionado = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Lógica para recargar
                // Aquí puedes verificar el método de pago seleccionado y realizar la recarga correspondiente.
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.lightBlue,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10), // Ajusta el tamaño del botón
              ),
              child: Text('Recargar', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
      drawer: buildDrawer(context),
    );
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }
}
