import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'recargar.dart';
import 'dark_mode_manager.dart';
import 'tabs.dart'; // Supongo que 'tabs.dart' define el método 'buildDrawer'

class ConsultarSaldoScreen extends StatelessWidget {
  const ConsultarSaldoScreen({Key? key}) : super(key: key);

  Future<int?> fetchUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<Map<String, dynamic>> fetchWallet(int userId) async {
    final url = Uri.parse('https://api2.parkingtalcahuano.cl/wallets/$userId');
    final response = await http.get(url, headers: {
      'accept': 'application/json',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'Error al cargar la billetera con el código de estado: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchRecentTransactions(int userId) async {
    final url =
        Uri.parse('https://api2.parkingtalcahuano.cl/parking-movements/$userId');
    final response = await http.get(url, headers: {
      'accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final List<dynamic> transactions = json.decode(response.body);
      // Devolver solo las últimas tres transacciones
      return transactions.cast<Map<String, dynamic>>().toList();
    } else {
      throw Exception(
          'Error al cargar las transacciones con el código de estado: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DarkModeManager>(
      builder: (context, darkModeManager, child) {
        return Theme(
          data: darkModeManager.darkModeEnabled
              ? ThemeData.dark()
              : ThemeData.light(),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Consultar Saldo'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<int?>(
                future: fetchUserId(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.data == null) {
                    return const Center(child: Text("User ID not found"));
                  }

                  // Si tenemos el ID de usuario, buscamos la billetera
                  final userId = snapshot.data!;
                  return FutureBuilder<Map<String, dynamic>>(
                    future: fetchWallet(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else if (snapshot.hasData) {
                        final data = snapshot.data!;
                        final balance = data['balance']?.toDouble() ?? 0.0;

                        return FutureBuilder<List<Map<String, dynamic>>>(
                          future: fetchRecentTransactions(userId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text("Error: ${snapshot.error}"));
                            } else if (snapshot.hasData) {
                              final transactions = snapshot.data!;

                              return _buildBalanceDisplay(
                                  balance, transactions, context);
                            } else {
                              return const Center(
                                  child: Text("No hay datos de transacciones"));
                            }
                          },
                        );
                      } else {
                        return const Center(
                            child: Text("No hay datos de billetera disponibles"));
                      }
                    },
                  );
                },
              ),
            ),
            drawer: buildDrawer(context),
          ),
        );
      },
    );
  }

Widget _buildBalanceDisplay(
  double balance, List<Map<String, dynamic>> transactions, BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        'Saldo Disponible:',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      Text(
        '\$$balance',
        style: const TextStyle(fontSize: 32),
      ),
      const SizedBox(height: 20),
      Expanded(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.blue[100],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Última transacción:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (transactions.isNotEmpty)
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: transactions.map((transaction) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID: ${transaction['id']}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            'Hora de entrada: ${transaction['entry_time']}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            'Hora de salida: ${transaction['exit_time']}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            'ID de lugar de estacionamiento: ${transaction['parking_spot_id']}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            'Costo total: \$${transaction['total_cost']}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            'Tipo de vehículo: ${transaction['vehicle_type']}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            'Matrícula: ${transaction['license_plate']}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            'Notas: ${transaction['notes']}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const Divider(),
                        ],
                      );
                    }).toList(),
                  ),
                )
              else
                const Text('Sin transacciones recientes'),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecargarDineroScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        ),
        child: const Text(
          'Recargar',
          style: TextStyle(fontSize: 18),
        ),
      ),
    ],
  );
}



}
