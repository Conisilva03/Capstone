import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import for JSON encoding
import 'package:crypto/crypto.dart'; // Import for MD5 hashing

class RegistroScreen extends StatefulWidget {
  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController nombreApellidoController =
      TextEditingController();
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool aceptaTerminos = false;

  // Función para cifrar la contraseña usando MD5
  String _hashPassword(String password) {
    return md5.convert(utf8.encode(password)).toString();
  }

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
              controller: nombreApellidoController,
              decoration: InputDecoration(labelText: 'Nombre y Apellido'),
            ),
            TextFormField(
              controller: usuarioController,
              decoration: InputDecoration(labelText: 'Nombre de Usuario'),
            ),
            TextFormField(
              controller: correoController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),
            _buildPasswordTextField(
              controller: passwordController,
              labelText: 'Contraseña',
              obscureText: _obscurePassword,
              onPressedIcon: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            SizedBox(height: 10),
            _buildPasswordTextField(
              controller: confirmPasswordController,
              labelText: 'Confirmar Contraseña',
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
                if (passwordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Las contraseñas no coinciden.'),
                    ),
                  );
                  return;
                }

                if (aceptaTerminos) {
                  final nombreApellido = nombreApellidoController.text;
                  final usuario = usuarioController.text;
                  final correo = correoController.text;
                  final passwordHashed = (passwordController.text);

                  final Map<String, String> requestBody = {
                    'full_name': nombreApellido,
                    'username': usuario,
                    'email': correo,
                    'hashed_password': passwordHashed,
                  };

                  final response = await http.post(
                    Uri.parse('https://api2.parkingtalcahuano.cl/users/'),
                    headers: <String, String>{
                      'Content-Type': 'application/json',
                    },
                    body: jsonEncode(requestBody),
                  );

                  if (response.statusCode == 200) {
                    Navigator.pop(context);
                  } else {
                    String errorMsg = 'Registro fallido. Inténtalo de nuevo.';
                    var responseData;
                    try {
                      responseData = jsonDecode(response.body);
                      if (responseData.containsKey('error')) {
                        errorMsg = responseData['error'];
                      }
                    } catch (e) {
                      // handle parsing error
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMsg),
                      ),
                    );
                  }
                } else {
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

  bool _obscurePassword = true;

  Widget _buildPasswordTextField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required VoidCallback onPressedIcon,
  }) {
    return TextFormField(
      controller: controller,
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
