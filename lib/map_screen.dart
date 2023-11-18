import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reservarahora.dart';
import 'reservar.dart';
import 'dart:async';
import 'inicio.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class ParkingSpace {
  final String id;
  final LatLng location;
  final String name;
  final String description;
  final String coordinates;
  final bool state;

  ParkingSpace(
    this.id,
    this.location,
    this.name,
    this.description,
    this.coordinates,
    this.state,
  );
}

class _MapScreenState extends State<MapScreen> {
  List<dynamic> reservations = [];
  LatLng? selectedMarkerLocation;
  Position? currentLocation;

  Timer? reservationTimer;

  List<ParkingSpace> parkingSpaceLocations = [];
  List<ParkingSpace> filteredParkingSpaceLocations = [];

  TextEditingController searchController = TextEditingController();

  Future<int?> fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    return userId;
  }

  List<dynamic> fullActiveReservations = [];
  List<dynamic> fullNonActiveReservations = [];

  Future<void> fetchAllReservations() async {
    final String apiUrl = 'https://api2.parkingtalcahuano.cl/reservations';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedReservations = json.decode(response.body);

        for (var reservation in fetchedReservations) {
          if (reservation['is_active']) {
            fullActiveReservations.add(reservation);
          } else {
            fullNonActiveReservations.add(reservation);
          }
        }

        setState(() {
          reservations = fullActiveReservations;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  List<dynamic> activeReservations = [];
  List<dynamic> nonActiveReservations = [];

  Future<void> fetchReservationsForUser(int userId) async {
    final String apiUrl =
        'https://api2.parkingtalcahuano.cl/reservations/user/$userId';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedReservations = json.decode(response.body);

        for (var reservation in fetchedReservations) {
          if (reservation['is_active']) {
            activeReservations.add(reservation);
          } else {
            nonActiveReservations.add(reservation);
          }
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

  bool isCarInUse(String licensePlate) {
    return activeReservations.any((reservation) =>
        reservation['vehicle_license_plate'] == licensePlate &&
        DateTime.parse(reservation['start_time']).isBefore(DateTime.now()) &&
        DateTime.parse(reservation['end_time']).isAfter(DateTime.now()));
  }

  void showTimerAlert(int reservationId, String endDateTime) {
    DateTime now = DateTime.now();
    DateTime endTime = DateTime.parse(endDateTime);
    Duration remainingTime = endTime.difference(now);

    if (remainingTime <= Duration(minutes: 15)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('¡Atención!'),
            content: Text(
                'La reserva #$reservationId está por finalizar en 15 minutos.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Entendido'),
              ),
            ],
          );
        },
      );
    }
  }

  bool isWithinTimeLimit(String endDateTime) {
    DateTime now = DateTime.now();
    DateTime endTime = DateTime.parse(endDateTime);
    Duration timeUntilEnd = endTime.difference(now);

    return timeUntilEnd <= Duration(minutes: 15) && timeUntilEnd.inMinutes >= 0;
  }

  void sendPostRequest() async {
    final url = Uri.parse('http://192.168.1.102/move/forward');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Solicitud POST enviada con éxito');
      } else {
        print(
            'Error al enviar la solicitud POST. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al enviar la solicitud POST: $e');
    }
  }

  Future<void> sendParkingMovementData(
      int? userId,
      String entryTime,
      String exitTime,
      String parkingSpotId,
      double totalCost,
      String vehicleType,
      String licensePlate,
      String notes) async {
    try {
      final Map<String, dynamic> parkingMovementData = {
        "user_id": userId,
        "entry_time": entryTime,
        "exit_time": exitTime,
        "parking_spot_id": parkingSpotId,
        "total_cost": totalCost,
        "vehicle_type": vehicleType,
        "license_plate": licensePlate,
        "notes": notes,
      };

      final response = await http.post(
        Uri.parse('https://api2.parkingtalcahuano.cl/parking-movements/'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(parkingMovementData),
      );

      if (response.statusCode == 200) {
        print('Parking movement data sent successfully.');
      } else {
        print('Error sending parking movement data: ${response.statusCode}');
        // Handle error as needed.
      }
    } catch (e) {
      print('Error sending parking movement data: $e');
      // Handle error as needed.
    }
  }

  Future<Map<String, dynamic>> fetchUserCarData(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api2.parkingtalcahuano.cl/cars/in-use/$userId'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load user car data');
      }
    } catch (e) {
      print('Error fetching user car data: $e');
      return {};
    }
  }

  Future<void> updateReservationStatus(int reservationId) async {
    final String apiUrl =
        'https://api2.parkingtalcahuano.cl/reservations/$reservationId/cancel/';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'is_active': false}),
      );

      if (response.statusCode == 200) {
        print('Reservation $reservationId status updated successfully.');
      } else {
        print('Error updating reservation status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating reservation status: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> _showTimerAlert(int reservationId, String endDateTime) async {
    await Future.delayed(Duration.zero);

    DateTime now = DateTime.now();
    DateTime endTime = DateTime.parse(endDateTime);
    Duration remainingTime = endTime.difference(now);

    if (remainingTime <= Duration(minutes: 15)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('¡Atención!'),
            content: Text(
                'La reserva #$reservationId está por finalizar en 15 minutos.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Entendido'),
              ),
            ],
          );
        },
      );
    }
  }

  void checkReservationStatus() {
    DateTime now = DateTime.now();

    for (var reservation in reservations) {
      DateTime endTime = DateTime.parse(reservation['end_time']);
      Duration timeUntilEnd = endTime.difference(now);

      if (timeUntilEnd <= Duration(minutes: 15) && reservation['is_active']) {
        // Reservation is about to end, update is_active to false
        print('caducated');
        updateReservationStatus(reservation['id']);
      }
    }
  }

  Future<void> initialize() async {
    await fetchData();
    final userId = await fetchUserId();
    if (userId != null) {
      fetchReservationsForUser(userId);
    }
    fetchAllReservations();
    getCurrentLocation();
    reservationTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      checkReservationStatus();
    });
  }

  Future<void> fetchData() async {
    try {
      final response =
          await http.get(Uri.parse('https://api1.marweg.cl/parking_spaces'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<ParkingSpace> parkingSpaces =
            (data as List<dynamic>).map((parkingSpace) {
          return ParkingSpace(
              parkingSpace['id'],
              LatLng(parkingSpace['latitude'], parkingSpace['longitude']),
              parkingSpace['name'],
              parkingSpace['description'],
              parkingSpace['location'],
              parkingSpace['state']);
        }).toList();

        setState(() {
          parkingSpaceLocations = parkingSpaces;
          filteredParkingSpaceLocations = parkingSpaces;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error al cargar datos: $e');
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentLocation = position;
      });
    } catch (e) {
      print('Error al obtener la ubicación actual: $e');
    }
  }

  void _showMarkerInfo(BuildContext context, ParkingSpace parkingSpace) async {
    final isParkingSpaceAvailable = activeReservations.isEmpty ||
        !activeReservations.any(
            (reservation) => reservation['parking_spot_id'] == parkingSpace.id);

    final isParkingSpaceAvailableNow = parkingSpace.state;
    int userId = (await fetchUserId()) ??
        0; // Use a default value if fetchUserId() returns null
    Map<String, dynamic> carData = await fetchUserCarData(userId);

    String licensePlate = carData['license_plate'] ?? 'Unknown';

    if (isParkingSpaceAvailable && !isCarInUse(licensePlate)) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informacion de Estacionamiento',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text('Nombre: ${parkingSpace.name}'),
                Text('Descripcion: ${parkingSpace.description}'),
                Text('Direccion: ${parkingSpace.coordinates}'),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(text: 'Estado Actual: '),
                      TextSpan(
                        text: isParkingSpaceAvailableNow
                            ? "Disponible"
                            : "Ocupado",
                        style: TextStyle(
                          color: isParkingSpaceAvailableNow
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                if (fullActiveReservations == true)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.0),
                      Text('Horario de reservas:'),
                      for (var reservation in fullActiveReservations)
                        if (reservation['parking_spot_id'] == parkingSpace.id)
                          Text(
                            'Desde: ${reservation['start_time']} - Hasta: ${reservation['end_time']}',
                          ),
                    ],
                  ),
                Spacer(),
                Divider(),
                if (isParkingSpaceAvailable)
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        padding: EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 20,
                        ),
                        textStyle: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ReservarAhoraScreen(id: parkingSpace.id),
                          ),
                        );
                      },
                      child: Text('Ocupar Ahora'),
                    ),
                  ),
                Spacer(),
                Spacer(),
              ],
            ),
          );
        },
      );
    } else {
      // El espacio está ocupado o el automóvil está en uso, mostrar mensaje correspondiente
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Este espacio de estacionamiento no está disponible para este vehiculo.'),
        ),
      );
    }
  }

  void filterParkingSpaces(String query) {
    setState(() {
      String trimmedQuery = query.trim().toLowerCase();
      List<String> queryWords = trimmedQuery.split(' ');

      filteredParkingSpaceLocations =
          parkingSpaceLocations.where((parkingSpace) {
        String lowerCaseName = parkingSpace.name.toLowerCase();

        bool matchesName =
            queryWords.every((word) => lowerCaseName.contains(word));

        bool matchesLocation = parkingSpace.location
            .toString()
            .toLowerCase()
            .contains(trimmedQuery);

        return matchesName || matchesLocation;
      }).toList();
    });
  }

  List<Widget> buildReservations() {
    return reservations.map<Widget>((reservation) {
      final DateTime startTime = DateTime.parse(reservation['start_time']);
      final DateTime endTime = DateTime.parse(reservation['end_time']);
      final DateTime currentTime = DateTime.now();

      final String spot_id = reservation['parking_spot_id'];

      final Duration timeUntilStart = startTime.isAfter(currentTime)
          ? startTime.difference(currentTime)
          : Duration.zero;
      final Duration timeUntilEnd = endTime.isAfter(currentTime)
          ? endTime.difference(currentTime)
          : Duration.zero;

      final String startTimerText = timeUntilStart == Duration.zero
          ? 'Comienza ahora'
          : 'Comienza en ${timeUntilStart.inMinutes} minutos';

      final String endTimerText = timeUntilEnd == Duration.zero
          ? 'Termina ahora'
          : 'Termina en ${timeUntilEnd.inMinutes} minutos';

      // ALERTA COMMENTADA
      // showTimerAlert(reservation['id'], reservation['end_time']);

      return Card(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: ListTile(
          contentPadding:
              EdgeInsets.only(top: 10), // Añadir espacio en la parte superior
          title: Text(
            'Reservación ID: ${reservation['id']}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hora de inicio: ${reservation['start_time']}',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Hora de finalización: ${reservation['end_time']}',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Tiempo hasta el inicio: $startTimerText',
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
              Text(
                'Tiempo hasta la finalización: $endTimerText',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Handle the "Agregar tiempo" action here
                      // Add the code to extend the reservation time
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
                    child: Text('Agregar tiempo',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showCancelConfirmationDialog(
                        context,
                        reservation['id'],
                        (int reservationId, int refundAmount, int? userId) {
                          // Handle the cancellation action here
                          // Add the code to cancel the reservation
                          updateReservationStatus(reservationId);
                        },
                        reservation['end_time'],
                        spot_id,
                      );

                      // Redireccionar con Navigator.push
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => InicioScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    child: Text('Cancelar',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (isWithinTimeLimit(reservation['end_time'])) {
                        sendPostRequest(); // Función para enviar la solicitud POST
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'El tiempo límite para enviar la solicitud POST ha pasado.'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors
                          .orange, // Puedes cambiar el color según tus preferencias
                    ),
                    child: Text('Bajar rampa'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Future<void> chargeWallet(int userId, int amount) async {
    final String apiUrl =
        'https://api2.parkingtalcahuano.cl/wallet/charge/$userId?amount=$amount';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Wallet charged successfully.');
      } else {
        print('Error charging wallet: ${response.statusCode}');
      }
    } catch (e) {
      print('Error charging wallet: $e');
    }
  }

  void showCancelConfirmationDialog(
      BuildContext context,
      int reservationId,
      Function(int, int, int?) onConfirm,
      String endDateTime,
      String parkingSpotId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Está seguro de que desea cancelar la reserva?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Calculate the refund amount based on the remaining time
                DateTime now = DateTime.now();
                DateTime endTime = DateTime.parse(endDateTime);
                Duration remainingTime = endTime.difference(now);

                // Refund amount calculation, multiplying by 10 instead of 15
                int refundAmount = (remainingTime.inMinutes * 10);
                final userId = await fetchUserId();

                if (refundAmount > 0) {
                  await chargeWallet(userId ?? 0, refundAmount);
                }

                // Call the onConfirm callback with the reservationId, refundAmount, and userId
                onConfirm(reservationId, refundAmount, userId);

                // Close the dialog
                Navigator.of(context).pop();

                // Show a message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('La reserva ha sido cancelada exitosamente.'),
                  ),
                );

                // Send parking movement data
                DateTime entryTime =
                    DateTime.parse(endDateTime); // Use reservation's start time
                String exitTime =
                    now.toIso8601String(); // Current time as exit time
                double totalCost = refundAmount.toDouble();
                String vehicleType =
                    "Normal"; // You need to replace this with the actual vehicle type
                String licensePlate =
                    ""; // You need to replace this with the actual license plate
                String notes =
                    "Recarga Cancelacion Reserva"; // You can add additional notes if needed

                await sendParkingMovementData(
                  userId,
                  entryTime.toIso8601String(),
                  exitTime,
                  parkingSpotId,
                  totalCost,
                  vehicleType,
                  licensePlate,
                  notes,
                );

                // Redireccionar con Navigator.push
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InicioScreen()),
                );
              },
              child: Text('Confirmar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Marker buildMarkerWithColor(ParkingSpace parkingSpace) {
    bool hasActiveReservation = activeReservations.any(
        (reservation) => reservation['parking_spot_id'] == parkingSpace.id);

    Color markerColor = hasActiveReservation
        ? Colors.green // Color for spaces with active reservations
        : parkingSpace.state
            ? Colors.blue // Color for available spaces (state = true)
            : Colors.red; // Color for occupied spaces (state = false)

    return Marker(
      point: parkingSpace.location,
      width: 80,
      height: 80,
      builder: (context) => GestureDetector(
        onTap: () {
          setState(() {
            selectedMarkerLocation = parkingSpace.location;
          });
          _showMarkerInfo(context, parkingSpace);
        },
        child: Icon(
          Icons.directions_car,
          color: markerColor,
          size: 48.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: TextField(
            controller: searchController,
            onChanged: (query) {
              filterParkingSpaces(query);
            },
            decoration: InputDecoration(
              labelText: 'Buscar Espacios de Estacionamiento',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              center: currentLocation != null
                  ? LatLng(
                      currentLocation!.latitude, currentLocation!.longitude)
                  : LatLng(-36.714658, -73.114729),
              zoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: filteredParkingSpaceLocations
                    .map<Marker>(
                        (parkingSpace) => buildMarkerWithColor(parkingSpace))
                    .toList(),
              ),
            ],
          ),
        ),
        if (reservations != null && reservations.isNotEmpty)
          Expanded(
            child: ListView(
              children: buildReservations(),
            ),
          ),
      ],
    ));
  }
}
