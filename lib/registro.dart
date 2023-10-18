import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import for JSON encoding

class RegistroScreen extends StatefulWidget {
  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool aceptaTerminos = false;

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
            Image.asset(
              'assets/logo.png',
              height: 100,
              width: 100,
            ),

            SizedBox(height: 20),

            Text(
              'Registrarse',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue),
            ),

            SizedBox(height: 20),

            TextFormField(
              controller: nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextFormField(
              controller: correoController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
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

            SizedBox(height: 20),

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

            ElevatedButton(
              onPressed: () async {
                if (aceptaTerminos) {
                  final nombre = nombreController.text;
                  final correo = correoController.text;
                  final password = passwordController.text;

                  // Create a JSON body with the specified fields
                  final Map<String, String> requestBody = {
                    'username': nombre,
                    'email': correo,
                    'hashed_password': password,
                  };

                  // Make a POST request to register the user
                  final response = await http.post(
                    Uri.parse('http://0.0.0.0:8000/users/'), // Use the correct endpoint
                    headers: <String, String>{
                      'Content-Type': 'application/json', // Use JSON content type
                    },
                    body: jsonEncode(requestBody), // Encode the JSON body
                  );

                  if (response.statusCode == 200) {
                    // Registration successful
                    Navigator.pop(context); // Navigate back to login screen
                  } else {
                    // Registration failed
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Registration failed. Please try again.'),
                      ),
                    );
                  }
                } else {
                  // Show an error message if terms are not accepted
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Debes aceptar los términos y condiciones para registrarte.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
              ),
              child: Text('Registrarse'),
            ),

            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('¿Ya tienes cuenta?'),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to login screen
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

  bool _obscurePassword = true;

  Widget _buildPasswordTextField({
    required String labelText,
    required bool obscureText,
    required VoidCallback onPressedIcon,
  }) {
    return TextFormField(
      controller: passwordController,
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
