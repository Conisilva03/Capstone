import 'package:flutter/material.dart';
import 'inicio.dart';
import 'agregarusuario.dart';
import 'agregarvehiculo.dart';
import 'listarvehiculos.dart';
import 'recargar.dart';
import 'consultarsaldo.dart';
import 'configuracion.dart';

class TabBarDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          title: Text('Navegación de Pestañas'),
        ),
        drawer: Drawer(
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
                  // Navegar a la pantalla de mapas (maps.dart)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            InicioScreen()), // Reemplaza MapsScreen con el nombre correcto de tu clase de pantalla de mapas
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.search),
                title: Text('Buscar Estacionamientos'),
                onTap: () {
                  // Tu lógica para la pestaña Buscar Estacionamientos aquí
                },
              ),
              ListTile(
                leading: Icon(Icons.person_add),
                title: Text('Invitar Amigos'),
                onTap: () {
                  // Navegar a la pantalla de mapas (maps.dart)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AgregarUsuarioScreen()), // Reemplaza MapsScreen con el nombre correcto de tu clase de pantalla de mapas
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
                        builder: (context) =>
                            AgregarVehiculosScreen()), // Reemplaza MapsScreen con el nombre correcto de tu clase de pantalla de mapas
                  ); // Tu lógica para la pestaña Agregar Vehículo aquí
                },
              ),
              ListTile(
                leading: Icon(Icons.list),
                title: Text('Listar Vehículos'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ListarVehiculosScreen()), // Reemplaza MapsScreen con el nombre correcto de tu clase de pantalla de mapas
                  ); // Tu lógica para la pestaña Agregar Vehículo aquí // Tu lógica para la pestaña Listar Vehículos aquí
                },
              ),
              ListTile(
                leading: Icon(Icons.refresh),
                title: Text('Recargar'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            RecargarDineroScreen()), // Reemplaza MapsScreen con el nombre correcto de tu clase de pantalla de mapas
                  ); // Tu lógica para la pestaña Recargar aquí
                },
              ),
              ListTile(
                leading: Icon(Icons.monetization_on),
                title: Text('Consultar Saldo'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ConsultarSaldoScreen()), // Reemplaza MapsScreen con el nombre correcto de tu clase de pantalla de mapas
                  ); // Tu lógica para la pestaña Consultar Saldo aquí
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
                        builder: (context) =>
                            ConfiguracionScreen()), // Reemplaza MapsScreen con el nombre correcto de tu clase de pantalla de mapas
                  ); // Tu lógica para la sección Herramientas aquí
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
