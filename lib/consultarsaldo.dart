import 'package:flutter/material.dart';
import 'tabs.dart';
import 'package:provider/provider.dart';
import 'dark_mode_manager.dart';

class ConsultarSaldoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DarkModeManager>(
      builder: (context, darkModeManager, child) {
        final lightTheme = ThemeData.light();
        final darkTheme = ThemeData.dark();

        final theme = darkModeManager.darkModeEnabled ? darkTheme : lightTheme;

        return Theme(
          data: theme, // Apply the theme to this screen
          child: Scaffold(
            appBar: AppBar(
              title: Text('Consultar Saldo'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Current balance
                  Text(
                    'Saldo Actual:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$100.00', // Display the current balance here (you can get it from your data or a database)
                    style: TextStyle(fontSize: 32),
                  ),

                  SizedBox(height: 20),

                  // Additional Information
                  Text(
                    'Última transacción:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Compra en Estacionamiento XYZ',
                    style: TextStyle(fontSize: 20),
                  ),

                  SizedBox(height: 20),

                  // Chart or Graph (You can use a chart library like fl_chart)
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue[100],
                    ),
                    child: Center(
                      child: Text(
                        'Gráfico de Transacciones', // You can replace this with an actual chart or graph widget
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Button to check balance
                  ElevatedButton(
                    onPressed: () {
                      // Add logic to check the balance here
                      // You can update the balance from your data or an API
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // Blue color
                      onPrimary: Colors.white, // White text
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    ),
                    child: Text(
                      'Actualizar Saldo',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            drawer: buildDrawer(context),
          ),
        );
      },
    );
  }
}
