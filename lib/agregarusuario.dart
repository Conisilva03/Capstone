import 'package:flutter/material.dart';

class AgregarUsuarioScreen extends StatefulWidget {
  @override
  _AgregarUsuarioScreenState createState() => _AgregarUsuarioScreenState();
}

class _AgregarUsuarioScreenState extends State<AgregarUsuarioScreen> {
  // Variables para los campos de entrada
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _correoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invitar Amigos'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo de nombre
            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),

            SizedBox(height: 20),

            // Campo de correo electrónico
            TextFormField(
              controller: _correoController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),

            SizedBox(height: 20),

            // Recuadro de mensaje
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Querido amig@ de Parking App, te invito a unirte a nuestra comunidad!',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),

            SizedBox(height: 20),

            // Botón para invitar amigo
            ElevatedButton(
              onPressed: () {
                // Tu lógica para agregar el usuario aquí
                String nombre = _nombreController.text;
                String correo = _correoController.text;

                // Realizar la lógica para agregar el usuario, por ejemplo, enviar los datos a una base de datos.

                // Después de agregar el usuario, puedes navegar a la pantalla de inicio o a donde desees.
                Navigator.pop(
                    context); // Esto regresará a la pantalla anterior.
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Color azul
                onPrimary: Colors.white, // Texto blanco
              ),
              child: Text('Invitar Amigo'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Liberar los controladores al cerrar la pantalla para evitar fugas de memoria.
    _nombreController.dispose();
    _correoController.dispose();
    super.dispose();
  }
}
