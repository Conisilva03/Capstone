import 'package:flutter/material.dart';
import 'maps.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true; // Para ocultar/mostrar la contraseña

  void _togglePasswordVisibility() {
    // Cambiar la visibilidad de la contraseña
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ingresar'),
        backgroundColor:
            Colors.blue, // Cambiar el color del fondo del encabezado
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo en la parte superior
            Image.asset(
              'assets/logo.png',
              height: 100,
              width: 100,
            ),

            SizedBox(height: 20),

            // Encabezado "Ingresar"
            Text(
              'Ingresar',
              style: TextStyle(
                fontSize: 24,
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            // Mensaje de bienvenida
            Text(
              '¡Hola, un placer volver a verte!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 20),

            // Formulario de inicio de sesión
            TextFormField(
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),

            SizedBox(height: 20),

            // Campo de contraseña con botón para mostrar/ocultar
            _buildPasswordTextField(),

            SizedBox(height: 20),

            // Botón de "Ingresar"
            ElevatedButton(
              onPressed: () {
                // Navegar a la pantalla de mapas (maps.dart)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MapsScreen()), // Reemplaza MapsScreen con el nombre correcto de tu clase de pantalla de mapas
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Color azul
                onPrimary: Colors.white, // Texto blanco
              ),
              child: Text('Ingresar'),
            ),

            SizedBox(height: 20),

            // Enlace para "Olvidó su contraseña?" y "Registrarse"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    // Tu lógica para "Olvidó su contraseña?" aquí
                  },
                  child: Text(
                    'Olvidó su contraseña?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navegar a la pantalla de registro (registro.dart)
                    Navigator.pushNamed(context, '/registrarse');
                  },
                  child: Text(
                    'Registrarse',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        suffixIcon: IconButton(
          onPressed: () {
            _togglePasswordVisibility();
          },
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
