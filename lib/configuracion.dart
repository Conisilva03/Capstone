import 'package:flutter/material.dart';

class ConfiguracionScreen extends StatefulWidget {
  @override
  _ConfiguracionScreenState createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  bool _darkModeEnabled =
      false; // Variable para controlar el estado del modo oscuro

  @override
  Widget build(BuildContext context) {
    // Definir los temas claro y oscuro
    final lightTheme = ThemeData.light();
    final darkTheme = ThemeData.dark();

    // Aplicar el tema actual basado en el estado del modo oscuro
    final theme = _darkModeEnabled ? darkTheme : lightTheme;

    return MaterialApp(
      theme: theme, // Aplicar el tema
      home: Scaffold(
        appBar: AppBar(
          title: Text('Configuración'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón para activar/desactivar el modo oscuro
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // Cambiar el estado del modo oscuro
                    _darkModeEnabled = !_darkModeEnabled;
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // Color azul
                  onPrimary: Colors.white, // Texto blanco
                ),
                child: Text(
                  _darkModeEnabled ? 'Modo Claro' : 'Modo Oscuro',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
