import 'package:flutter/material.dart';

class OlvidoContrasenaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Olvido de contraseña'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Olvidé mi contraseña',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Ingresa tu dirección de correo electrónico a continuación para restablecer tu contraseña.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Agregar lógica para enviar un correo de restablecimiento de contraseña
                // Esto podría implicar enviar un enlace de restablecimiento al correo proporcionado.
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12), // Tamaño reducido
                textStyle: TextStyle(fontSize: 16), // Tamaño de texto reducido
              ),
              child: Text('Enviar correo'),
            ),
          ],
        ),
      ),
    );
  }
}
