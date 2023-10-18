import 'package:flutter/material.dart';
import 'inicio.dart';
import 'maps.dart';
import 'agregarusuario.dart';
import 'agregarvehiculo.dart';
import 'listarvehiculos.dart';
import 'recargar.dart';
import 'consultarsaldo.dart';
import 'configuracion.dart';

Widget buildDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        UserAccountsDrawerHeader(
          accountName: Text('Nombre del Usuario'),
          accountEmail: Text('correo@example.com'),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: Colors.blue,
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Inicio'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InicioScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.search),
          title: Text('Buscar Estacionamientos'),
          onTap: () {
            Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MapsScreen()), // Reemplaza MapsScreen con el nombre correcto de tu clase de pantalla de mapas
                );
          },
        ),
        ListTile(
          leading: Icon(Icons.person_add),
          title: Text('Invitar Amigos'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AgregarUsuarioScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.directions_car),
          title: Text('Agregar Vehículos'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AgregarVehiculosScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.list),
          title: Text('Listar Vehículos'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListarVehiculosScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.refresh),
          title: Text('Recargar'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecargarDineroScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.monetization_on),
          title: Text('Consultar Saldo'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConsultarSaldoScreen(),
              ),
            );
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.build),
          title: Text('Configuración'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConfiguracionScreen(),
              ),
            );
          },
        ),
      ],
    ),
  );
}
