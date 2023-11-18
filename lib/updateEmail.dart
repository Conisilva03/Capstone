import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dark_mode_manager.dart';

class UserApi {
  static const baseUrl = 'https://api2.parkingtalcahuano.cl/users';

  Future<int?> fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    return userId;
  }

  Future<Map<String, dynamic>> fetchDataAndStoreData(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$userId'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error al cargar datos: $e');
      throw e;
    }
  }

  Future<int?> fetchUserIdFromEmail(String email) async {
    final apiUrl = Uri.parse('$baseUrl/get-user-id');

    try {
      final response = await http.post(
        apiUrl,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['user_id'];
      } else {
        print('Failed to fetch user ID. Status code: ${response.statusCode}');
        return null;
      }
    } catch (exception) {
      print('Exception while fetching user ID: $exception');
      return null;
    }
  }

  Future<void> updateEmail(int userId, String newEmail) async {
    final apiUrl = Uri.parse('$baseUrl/$userId/update-email');

    try {
      final response = await http.put(
        apiUrl,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'new_email': newEmail,
        }),
      );

      if (response.statusCode == 200) {
        print('Email updated successfully');
      } else {
        print('Failed to update email. Status code: ${response.statusCode}');
      }
    } catch (exception) {
      print('Exception while updating email: $exception');
    }
  }
}

class EmailUpdateScreen extends StatefulWidget {
  @override
  _EmailUpdateScreenState createState() => _EmailUpdateScreenState();
}

class _EmailUpdateScreenState extends State<EmailUpdateScreen> {
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch user ID and fill the email field if available
    fetchUserIdAndFillEmail();
  }

  Future<void> fetchUserIdAndFillEmail() async {
    final userApi = UserApi();
    final userId = await userApi.fetchUserId();
    if (userId != null) {
      final userData = await userApi.fetchDataAndStoreData(userId);
      final userEmail = userData['email'];
      if (userEmail != null) {
        setState(() {
          emailController.text = userEmail;
        });
      }
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
              title: Text('Actualizar Email'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo de correo electrónico no puede estar vacío';
                      } else if (!RegExp(
                              r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                          .hasMatch(value)) {
                        return 'Ingrese un correo electrónico válido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final email = emailController.text;
                      if (email.isNotEmpty) {
                        final userApi = UserApi();
                        final userId =
                            await userApi.fetchUserIdFromEmail(email);
                        if (userId != null) {
                          await userApi.updateEmail(userId, email);
                          Navigator.pop(context);
                        } else {
                          print('Fallo al obtener el ID del usuario.');
                        }
                      } else {
                        print('El email no puede estar vacío.');
                      }
                    },
                    child: Text('Actualizar Email'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void main() {
    runApp(MaterialApp(
      home: EmailUpdateScreen(),
    ));
  }
}
