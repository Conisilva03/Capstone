import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import the provider package
import 'login.dart';
import 'registro.dart';
import 'package:provider/provider.dart';
import 'dark_mode_manager.dart'; 

void main() {
  //debugPaintSizeEnabled = false;
  runApp(
    ChangeNotifierProvider(
      create: (context) => DarkModeManager(), // Provide an instance of DarkModeManager
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BienvenidaScreen(),
      theme: ThemeData(
        primaryColor: Colors.blue, // Your primary color
        // Add other light theme properties here
      ),
    );
  }
}


class BienvenidaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final darkModeManager = context.watch<DarkModeManager>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido'),
        actions: [
          IconButton(
            icon: Icon(
              darkModeManager.darkModeEnabled
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () {
              darkModeManager.toggleDarkMode();
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.blue,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¡Bienvenido a tu App!',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Image.asset(
              'assets/logo.png',
              height: 300,
              width: 300,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.black,
                minimumSize: Size(200, 40),
              ),
              child: Text(
                'Iniciar Sesión',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistroScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.black,
                minimumSize: Size(200, 40),
              ),
              child: Text(
                'Registrarse',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
