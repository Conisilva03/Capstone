import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

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

  Future<void> recargarDinero(int userId, double amount) async {
    final String apiUrl =
        'https://api2.parkingtalcahuano.cl/wallet/charge/$userId?amount=$amount';

    final Map<String, dynamic> data = {
      'user_id': userId,
      'amount': amount,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Money charged successfully');
      // Call the function to create Webpay transaction
    } else {
      print('Error charging money: ${response.statusCode}');
      print('Response content: ${response.body}');
    }
  }

  Future<void> createWebpayTransaction(http.Response response) async {
    final String apiUrl =
        'https://api2.parkingtalcahuano.cl/webpay-plus/create';

    final Map<String, dynamic> requestData = {
      "buy_order": "buy0201", // Replace with a unique buy_order value
      "session_id": "id01031", // Replace with a unique session_id value
      "amount": 3000, // Replace with the desired amount
      "return_url": "https://api2.parkingtalcahuano.cl/",
    };

    final Map<String, dynamic> payload = {
      "request": requestData,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Webpay transaction created successfully');
      print('Token: ${responseData["response"]["token"]}');
      print('URL: ${responseData["response"]["url"]}');

      // Navigate to the WebView screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewScreen(
            key: UniqueKey(),
            url: responseData["response"]["url"],
          ),
        ),
      );
    } else {
      print('Error creating Webpay transaction: ${response.statusCode}');
      print('Response content: ${response.body}');
    }
  }

  List<Widget> _buildPaymentMethods() {
    return [
      RadioListTile<String>(
        title: Text('WebPay'),
        value: 'webpay',
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
                int? userId = await fetchUserId();

                if (amount != null && userId != null) {
                  await recargarDinero(userId, amount);
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
    );
  }
}

class WebViewScreen extends StatefulWidget {
  final String url;

  WebViewScreen({required this.url, Key? key}) : super(key: key);

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Webview Screen'),
      ),
      body: WebView(
        key: widget.key,
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
        navigationDelegate: (NavigationRequest request) {
          // Handle redirects or other navigation events
          return NavigationDecision.navigate;
        },
      ),
    );
  }
}
