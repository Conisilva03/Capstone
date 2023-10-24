import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CerrarSesionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cerrar Sesión'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            mostrarDialogoCerrarSesion(context);
          },
          child: Text('Cerrar Sesión'),
        ),
      ),
    );
  }

  Future<void> mostrarDialogoCerrarSesion(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('¿Cerrar Sesión?'),
          content: Text('¿Estás seguro de que deseas cerrar la sesión?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                // Elimina el token de autenticación antes de cerrar la sesión.
                await eliminarTokenDeAutenticacion();

                // Cierra la sesión y vuelve a la pantalla de inicio de sesión o a donde sea necesario.
                Navigator.of(context).pop(); // Cierra el diálogo
                Navigator.of(context).pop(); // Cierra la pantalla actual
              },
              child: Text('Sí'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> eliminarTokenDeAutenticacion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('auth_token');
    } catch (e) {
      print('Error al eliminar el token de autenticación: $e');
      // Maneja cualquier error que pueda ocurrir al eliminar el token de autenticación.
    }
  }
}
