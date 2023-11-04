import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RegistroScreen(),
    );
  }
}

class RegistroScreen extends StatefulWidget {
  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nombreApellidoController =
      TextEditingController();
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool aceptaTerminos = false;
  bool _obscurePassword = true;

  String _hashPassword(String password) {
    return md5.convert(utf8.encode(password)).toString();
  }

  Future<bool> checkUserExistence(String username, String email) async {
    final response = await http.post(
      Uri.parse('https://api2.parkingtalcahuano.cl/users/check-existence'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"username": username, "email": email}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      return responseBody['exists'] ?? false;
    } else {
      throw Exception('Error checking user existence');
    }
  }

  Future<Map<String, dynamic>?> registerUser({
    required String name,
    required String username,
    required String email,
    required String password,
    required String role,
    required bool is_active,
  }) async {
    final response = await http.post(
      Uri.parse('https://api2.parkingtalcahuano.cl/users/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "name": name,
        "username": username,
        "email": email,
        "hashed_password": _hashPassword(password),
        "role": role,
        "is_active": is_active,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Failed to register user: ${response.body}');
      return null;
    }
  }

  Future<bool> createWallet({required int userId}) async {
    final response = await http.post(
      Uri.parse('https://api2.parkingtalcahuano.cl/wallets/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"user_id": userId, "balance": 0}),
    );

    return response.statusCode == 200;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nombreApellido = nombreApellidoController.text.trim();
    final usuario = usuarioController.text.trim();
    final correo = correoController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    if (!aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debe aceptar los términos y condiciones')),
      );
      return;
    }

    final userExists = await checkUserExistence(usuario, correo);
    if (userExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El usuario o correo ya existe')),
      );
      return;
    }

    final Map<String, dynamic>? user = await registerUser(
      name: nombreApellido,
      username: usuario,
      email: correo,
      password: password,
      role: 'user',
      is_active: true,
    );

    if (user != null && user.containsKey('id')) {
      final bool walletCreated = await createWallet(userId: user['id']);
      if (walletCreated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario registrado con éxito')),
        );
        // You can navigate to another screen here, if needed
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear la billetera del usuario')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar el usuario')),
      );
    }
  }

  void _mostrarTerminosYCondiciones() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Términos y Condiciones"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    "1. Al utilizar esta aplicación, usted se compromete a pagar todas las tarifas asociadas, incluyendo cargos a la tarifa por incumplimiento."),
                SizedBox(height: 10),
                Text(
                    "2. No nos hacemos responsables de daños a vehículos ni sus pertenencias."),
                SizedBox(height: 10),
                Text("3. Aplicación solo para mayores de edad."),
                // ... Puedes agregar más términos aquí...
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // The build method starts here.
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: nombreApellidoController,
                  decoration: InputDecoration(labelText: 'Nombre y Apellido'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: usuarioController,
                  decoration: InputDecoration(labelText: 'Usuario'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: correoController,
                  decoration: InputDecoration(labelText: 'Correo electrónico'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    } else if (!value.contains('@')) {
                      return 'Correo no válido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: _obscurePassword,
                  decoration:
                      InputDecoration(labelText: 'Confirmar Contraseña'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    } else if (value != passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    Checkbox(
                      value: aceptaTerminos,
                      onChanged: (bool? newValue) {
                        setState(() {
                          aceptaTerminos = newValue ?? false;
                        });
                      },
                    ),
                    GestureDetector(
                      onTap: _mostrarTerminosYCondiciones,
                      child: const Text(
                        'Acepto los términos y condiciones',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Registrarse'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
