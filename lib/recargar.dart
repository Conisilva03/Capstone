import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RecargarDineroScreen extends StatefulWidget {
  @override
  _RecargarDineroScreenState createState() => _RecargarDineroScreenState();
}

class _RecargarDineroScreenState extends State<RecargarDineroScreen> {
  TextEditingController _montoController = TextEditingController();
  double saldo = 0.0;
  String? metodoDePagoSeleccionado;

  Future<int?> fetchUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<void> recargarDinero(double amount) async {
    int? userId = await fetchUserId();
    if (userId != null) {
      String apiUrl = 'https://api2.parkingtalcahuano.cl/wallet/charge/$userId';

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {
        'user_id': userId,
        'amount': amount,
      };

      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print("Recarga exitosa");
      } else {
        print("Error al recargar: ${response.statusCode}");
        print("Body: ${response.body}");
      }
    } else {
      print("No se pudo obtener el ID del usuario");
    }
  }

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
              'Recargar Dinero',
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
            TextFormField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Ingrese el monto',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Método de Pago:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ..._buildPaymentMethods(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                double? amount = double.tryParse(_montoController.text);
                if (amount != null) {
                  await recargarDinero(amount);
                } else {
                  _showErrorDialog();
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.lightBlue,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text('Recargar', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
      //drawer: buildDrawer(context), // Assuming this method is defined elsewhere in your code.
    );
  }

  List<Widget> _buildPaymentMethods() {
    return [
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
    ];
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Por favor, ingrese un monto válido.'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }
}
