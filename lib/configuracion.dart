import 'package:flutter/material.dart';
import 'tabs.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'dark_mode_manager.dart';
import 'updateEmail.dart';

class ConfiguracionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final darkModeManager = Provider.of<DarkModeManager>(context);
    final lightTheme = ThemeData.light();
    final darkTheme = ThemeData.dark();
    final theme = darkModeManager.darkModeEnabled ? darkTheme : lightTheme;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Modificar mi perfil'),
          actions: [
            IconButton(
              icon: Icon(
                darkModeManager.darkModeEnabled
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () {
                darkModeManager.toggleDarkMode();
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  darkModeManager.toggleDarkMode();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                ),
                child: Text(
                  darkModeManager.darkModeEnabled
                      ? 'Modo Claro'
                      : 'Modo Oscuro',
                ),
              ),
              SizedBox(height: 20), // Añadir un espacio entre botones
              ElevatedButton(
                onPressed: () {
                  // Redireccionar a la pantalla de edición de correo electrónico
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EmailUpdateScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  onPrimary: Colors.white,
                ),
                child: Text('Editar Email'),
              ),
            ],
          ),
        ),
        drawer: buildDrawer(context),
      ),
    );
  }
}
