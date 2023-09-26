import 'package:flutter/material.dart';
import 'login.dart';
import 'registro.dart';
import 'maps.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BienvenidaScreen(),
      theme: ThemeData(primaryColor: Colors.blue),
    );
  }
}

class BienvenidaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido'),
      ),
      body: Container(
        color: Colors.blue, // Fondo celeste
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¡Bienvenido a tu App!',
              style:
                  TextStyle(fontSize: 24, color: Colors.white), // Texto blanco
            ),
            SizedBox(height: 20),
            Image.asset(
              'assets/logo.png',
              height: 300,
              width: 300,
            ),
            SizedBox(height: 40), // Espacio entre el logo y los botones
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white, // Fondo blanco
                onPrimary: Colors.black, // Texto negro
                minimumSize:
                    Size(200, 40), // Ancho fijo de 200, altura automática
              ),
              child: Text(
                'Iniciar Sesión',
                style: TextStyle(
                  fontSize: 18, // Tamaño de letra más grande
                ),
              ),
            ),

            SizedBox(height: 10), // Espacio entre los botones
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistroScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white, // Fondo blanco
                onPrimary: Colors.black, // Texto negro
                minimumSize:
                    Size(200, 40), // Ancho fijo de 200, altura automática
              ),
              child: Text(
                'Registro',
                style: TextStyle(
                  fontSize: 18, // Tamaño de letra más grande
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
