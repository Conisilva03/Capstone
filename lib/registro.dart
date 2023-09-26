import 'package:flutter/material.dart';

class RegistroScreen extends StatefulWidget {
  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController rutController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();

  bool aceptaTerminos =
      false; // Para rastrear si el checkbox está marcado o desmarcado

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrarse'),
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

            // Encabezado
            Text(
              'Registrarse',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue),
            ),

            SizedBox(height: 20),

            // Formulario de registro
            TextFormField(
              controller: nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextFormField(
              controller: apellidoController,
              decoration: InputDecoration(labelText: 'Apellido'),
            ),
            TextFormField(
              controller: correoController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),
            TextFormField(
              controller: rutController,
              decoration: InputDecoration(labelText: 'RUT'),
            ),
            _buildPasswordTextField(
              labelText: 'Contraseña',
              obscureText: _obscurePassword,
              onPressedIcon: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            _buildPasswordTextField(
              labelText: 'Repetir Contraseña',
              obscureText: _obscureRepeatPassword,
              onPressedIcon: () {
                setState(() {
                  _obscureRepeatPassword = !_obscureRepeatPassword;
                });
              },
            ),

            SizedBox(height: 20),

            // Checkbox de aceptación de términos y condiciones
            Row(
              children: [
                Checkbox(
                  value: aceptaTerminos,
                  onChanged: (bool? value) {
                    setState(() {
                      aceptaTerminos = value ?? false;
                    });
                  },
                ),
                Text('Acepto los términos y condiciones'),
              ],
            ),

            SizedBox(height: 20),

            // Botón de registro
            ElevatedButton(
              onPressed: () {
                // Verificar si se aceptaron los términos y condiciones
                if (aceptaTerminos) {
                  // Puedes acceder a los valores ingresados en los campos de texto
                  final nombre = nombreController.text;
                  final apellido = apellidoController.text;
                  final correo = correoController.text;
                  final rut = rutController.text;
                  final password = passwordController.text;
                  final repeatPassword = repeatPasswordController.text;

                  // Realiza la lógica de registro aquí
                  // Luego, navega de vuelta a la pantalla principal (main.dart)
                  Navigator.pop(context);
                } else {
                  // Muestra un mensaje de error si no se aceptaron los términos y condiciones
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Debes aceptar los términos y condiciones para registrarte.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Color azul
                onPrimary: Colors.white, // Texto blanco
              ),
              child: Text('Registrarse'),
            ),

            SizedBox(height: 20),

            // Texto de "ya tienes cuenta"
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('¿Ya tienes cuenta?'),
                TextButton(
                  onPressed: () {
                    // Tu lógica para navegar a la pantalla de inicio de sesión aquí
                    Navigator.pop(context);
                  },
                  child: Text('Ingresar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _obscurePassword = true; // Para ocultar/mostrar la contraseña
  bool _obscureRepeatPassword =
      true; // Para ocultar/mostrar la contraseña de repetición

  Widget _buildPasswordTextField({
    required String labelText,
    required bool obscureText,
    required VoidCallback onPressedIcon,
  }) {
    return TextFormField(
      controller: obscureText ? passwordController : repeatPasswordController,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: IconButton(
          onPressed: onPressedIcon,
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
