import 'package:flutter/material.dart';

class InicioScreen extends StatefulWidget {
  @override
  _InicioScreenState createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página de Inicio'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bienvenido a la página de inicio'),
            SizedBox(height: 20),
            Image.asset(
              '/captura1.png', // Ruta de la imagen en assets
              height: 200, // Altura de la imagen
              width: 200, // Ancho de la imagen
            ),
          ],
        ),
      ),
    );
  }
}
