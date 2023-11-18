import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dark_mode_manager.dart';
import 'package:provider/provider.dart';

class MisReservasScreen extends StatefulWidget {
  @override
  _MisReservasScreenState createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends State<MisReservasScreen> {
  List<dynamic> reservations = [];

  @override
  void initState() {
    super.initState();
    // Fetch reservations for the user when the screen is created
    fetchReservations();
  }

  Future<void> fetchReservations() async {
    final String apiUrl =
        'https://api2.parkingtalcahuano.cl/reservations/user/${await fetchUserId()}';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedReservations = json.decode(response.body);
        List<dynamic> activeReservations = [];

        for (var reservation in fetchedReservations) {
          activeReservations.add(reservation);
        }

        setState(() {
          reservations = activeReservations;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
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
              title: Text('Mis Reservas'),
            ),
            body: _buildReservasList(),
          ),
        );
      },
    );
  }

  Widget _buildReservasList() {
    if (reservations.isEmpty) {
      return Center(
        child: Text('No hay reservas activas para mostrar.'),
      );
    }

    return ListView.builder(
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        return _buildReservaItem(reservations[index]);
      },
    );
  }

  Widget _buildReservaItem(dynamic reserva) {
    return ListTile(
      title: Text('Reservación ID: ${reserva['id']}'),
      subtitle: Text('Hora de inicio: ${reserva['start_time']}'),
      // ... Otros detalles de la reserva
    );
  }

  Future<int?> fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    return userId;
  }
}
