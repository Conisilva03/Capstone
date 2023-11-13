import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'maps.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'map_screen.dart';
import 'package:nanoid/nanoid.dart';


class ParkingSpace {
  final String id;
  final LatLng location;
  final String name;
  final String description;
  final String locationAddress;
  final bool state;

  ParkingSpace(this.id, this.location, this.name, this.description, this.locationAddress, this.state);
}

class ReservarAhoraScreen extends StatefulWidget {
  final String id;
  ReservarAhoraScreen({required this.id});

  @override
  _ReservarAhoraScreenState createState() => _ReservarAhoraScreenState();
}

class _ReservarAhoraScreenState extends State<ReservarAhoraScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController fechaController = TextEditingController();
  TextEditingController horaController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController ubicacionController = TextEditingController();


  String? fecha;
  String? hora;
  ParkingSpace? parkingSpace;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  TimeOfDay? selectedEndTime;
  int? walletBalance;

Future<void> cancelReservation(String reservationId) async {
  try {
    final response = await http.put(
      Uri.parse('https://api2.parkingtalcahuano.cl/reservations/$reservationId/cancel'),
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Reservation canceled successfully.');
      // Optionally, you can perform additional actions after cancellation.
    } else {
      print('Error canceling reservation: ${response.statusCode}');
      // Handle error as needed.
    }
  } catch (e) {
    print('Error canceling reservation: $e');
    // Handle error as needed.
  }
}

@override
void initState() {
  super.initState();
  loadParkingSpace();
  // Inicializar el campo de hora de inicio con la hora actual
  selectedTime = TimeOfDay(hour: 8, minute: 0); // Set the start time to 8:00 AM
  horaController.text =
      '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';


  // Check and update the state of the parking space
  checkAndUpdateParkingSpaceState();

  // Fetch and update the user's wallet balance
  fetchAndUpdateWalletBalance();
}

Future<void> fetchAndUpdateWalletBalance() async {
  try {
    // Fetch the user ID
    int? userId = await fetchUserId();

    if (userId != null) {
      // Fetch the user's wallet information
      Map<String, dynamic> wallet = await fetchWallet(userId);

      setState(() {
        walletBalance = wallet['balance'];
      });
    }
  } catch (e) {
    print('Error fetching wallet balance: $e');
  }
}


Future<void> checkAndUpdateParkingSpaceState() async {
  // Fetch the parking space details
  ParkingSpace? fetchedParkingSpace = await fetchData(widget.id);

  if (fetchedParkingSpace != null) {
    // Update the parking space state in the UI
    setState(() {
      parkingSpace = fetchedParkingSpace;
      ubicacionController.text = parkingSpace!.location.toString();
    });

    // Check if the current time is after the reservation end time
    DateTime now = DateTime.now();
    DateTime reservationEndTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedEndTime!.hour,
      selectedEndTime!.minute,
    );

    if (now.isAfter(reservationEndTime)) {
      // Reservation has ended, update the parking space state to inactive
      updateParkingSpaceState(widget.id, false);
      
      // Cancel the reservation
      cancelReservation(widget.id);
    }
  }
}

  String formatTimeToISO8601(String timeString) {
    // Parse the time string into TimeOfDay
    List<String> parts = timeString.split(':');
    TimeOfDay timeOfDay = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    // Get the current date
    DateTime now = DateTime.now();

    // Create a DateTime object with today's date and the parsed time
    DateTime dateTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);

    // Format the DateTime object to ISO8601 format
    String formattedTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(dateTime);

    return formattedTime;
  }

  Future<ParkingSpace?> fetchData(String id) async {
    try {
      final response = await http.get(Uri.parse('https://api1.marweg.cl/parking_spaces/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        String? locationAddress = data['locationAddress'];
        if (locationAddress == null) {
          // Handle the case where locationAddress is not present in the API response
          locationAddress = "Location Address Not Available";
        }

        return ParkingSpace(
          data['id'],
          LatLng(data['latitude'], data['longitude']),
          data['name'],
          data['description'],
          locationAddress,
          data['state'],
        );
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error al cargar datos: $e');
      return null;
    }
  }

  Future<void> loadParkingSpace() async {
    ParkingSpace? fetchedParkingSpace = await fetchData(widget.id);
    if (fetchedParkingSpace != null) {
      setState(() {
        parkingSpace = fetchedParkingSpace;
        ubicacionController.text = parkingSpace!.location.toString();
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (time != null && time != selectedTime) {
      // Comprobar si la hora seleccionada está dentro del rango permitido
      if (time.hour >= 8 && time.hour < 19) {
        setState(() {
          selectedTime = time;
          horaController.text =
              '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';
        });
      } else {
        // Mostrar un mensaje si se selecciona una hora fuera del rango permitido
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Por favor, seleccione una hora entre las 8:00 y las 19:00'),
          ),
        );
      }
    }
  }

  Future<void> _pickEndTime() async {
    TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: selectedEndTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (endTime != null && endTime != selectedEndTime) {
      // Comprobar si la hora seleccionada está dentro del rango permitido
      if (endTime.hour >= 8 && endTime.hour < 19) {
        setState(() {
          selectedEndTime = endTime;
          endTimeController.text =
              '${selectedEndTime!.hour.toString().padLeft(2, '0')}:${selectedEndTime!.minute.toString().padLeft(2, '0')}';
        });
      } else {
        // Mostrar un mensaje si se selecciona una hora fuera del rango permitido
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Por favor, seleccione una hora de fin entre las 8:00 y las 19:00'),
          ),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = DateTime.now();
        fechaController.text =
            '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}';

      });
    }
  }
Future<int?> fetchUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userId = prefs.getInt('user_id');
  return userId;
}
    // Function to send parking movement data
  Future<void> sendParkingMovementData(int? userId, String entryTime, String exitTime, String parkingSpotId, double totalCost, String vehicleType, String licensePlate, String notes) async {
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

  Future<void> updateParkingSpaceState(String id, bool newState) async {
    try {
      final response = await http.put(
        Uri.parse(
            'https://api1.marweg.cl/parking_spaces/$id/update_state?new_state=$newState'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Estado del estacionamiento actualizado con éxito.');
      } else {
        print('Error al actualizar el estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al realizar la solicitud: $e');
    }
  }

Future<String> checkReservationInRange(String spotId, String startDateTime, String endDateTime) async {
  try {
    final Map<String, dynamic> requestData = {
      "start_time": startDateTime,
      "end_time": endDateTime,
    };

    final response = await http.post(
      Uri.parse('https://api2.parkingtalcahuano.cl/reservations/check?spot_id=$spotId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String? status = data['status'];

      if (status != null) {
        return status;
      } else {
        return 'Failed to retrieve reservation status';
      }
    } else {
      return 'Failed to check reservation';
    }
  } catch (e) {
    print('Error checking reservation: $e');
    return 'Error checking reservation';
  }
}


int generateShortNumericId() {
  final Random random = Random();
  return random.nextInt(1000000); // Número aleatorio de hasta 9 dígitos
}


Future<Map<String, dynamic>> fetchWallet(int userId) async {
    final url = Uri.parse('https://api2.parkingtalcahuano.cl/wallets/$userId');
    final response = await http.get(url, headers: {
      'accept': 'application/json',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'Failed to load wallet with status code: ${response.statusCode}');
    }
  }


Future<void> createReservation(String startDateTime, String endDateTime) async {
  try {
    // Fetch the user ID
    int? userId = await fetchUserId();

    if (userId == null) {
      print('Error: User ID is null.');
      return;
    }

    // Fetch the user's wallet information
    Map<String, dynamic> wallet = await fetchWallet(userId);

    // Check if the wallet balance is greater than the reservation fee
    int reservationFee = 15; 
    int walletBalance = wallet['balance'];

    if (walletBalance < reservationFee) {
      print('Error: Insufficient balance for reservation.');
      return;
    }
    int idcar=generateShortNumericId();
    print(idcar);

    final Map<String, dynamic> reservationData = {
      "id": idcar,
      "user_id": userId,
      "parking_spot_id": widget.id,
      "start_time": startDateTime,
      "end_time": endDateTime,
      "is_active": true,
    };

    print('Check monto billetera: $reservationData');
    final response = await http.post(
      Uri.parse('https://api2.parkingtalcahuano.cl/reservations/'),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(reservationData),
    );

    if (response.statusCode == 200) {
      print('Reservation created successfully.');
    } else {
      print('Error creating reservation: ${response.statusCode}');
    }
  } catch (e) {
    print('Error creating reservation: $e');
  }
}





// Utility function to calculate the reservation cost based on minutes
String calculateReservationCost(DateTime start, DateTime end, int ratePerMinute) {
  Duration difference = end.difference(start);
  int minutes = difference.inMinutes;
  int cost = minutes * ratePerMinute;
  return cost.toString();
}




  Future<void> _submitForm() async {
    int? userId = await fetchUserId();

    if (_formKey.currentState!.validate()) {
      // Validar la fecha y hora seleccionadas
      if (selectedDate == null || selectedTime == null || selectedEndTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor, seleccione una fecha y hora válidas.'),
          ),
        );
        return;
      }

      final String startDateTime =
          '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')} ${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00';
      final String endDateTime =
          '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')} ${selectedEndTime!.hour.toString().padLeft(2, '0')}:${selectedEndTime!.minute.toString().padLeft(2, '0')}:00';

      // Verificar si el dinero en la billetera es suficiente
      bool isBalanceSufficient = await checkWalletBalance(startDateTime, endDateTime);
    print(isBalanceSufficient);
    if (!isBalanceSufficient) {
      // Mostrar un mensaje de alerta
      showInsufficientBalanceAlert();
      return;
    }

      final String reservationStatus = await checkReservationInRange(widget.id, startDateTime, endDateTime);

    if (reservationStatus == 'Available') {
      // Calculate the cost based on minutes and a rate (e.g., $15 per minute)
      int ratePerMinute = 15; // Adjust as needed
      String reservationCost = calculateReservationCost(
          DateTime.parse(startDateTime), DateTime.parse(endDateTime), ratePerMinute);

      // Navigate to the confirmation screen
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => ConfirmationScreen(
      cost: reservationCost,
      parkingSpaceName: parkingSpace!.name,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      onAccept: () async {
        // Accept reservation logic here, e.g., createReservation function
        await createReservation(startDateTime, endDateTime);
        print(userId);
        print(startDateTime);
        print(widget.id);
        print('normal');
        await sendParkingMovementData(userId,
      startDateTime,
      endDateTime,
      widget.id, // Assuming widget.id is the parking_spot_id
      double.parse(reservationCost), // Assuming cost is the total_cost
      'normal', // Replace with the actual vehicle type
      'licensePlate', // Replace with the actual license plate
      'Reserva', // Replace with any additional notes or an empty string
    );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reserva realizada con éxito.'),
          ),
        );

        // Navigate back to the map screen or any other screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MapsScreen(),
          ),
        );
      },
    ),
  ),
);

      } else {
        // Mostrar un mensaje de conflicto de reserva
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estacionamiento No Disponible en ese horario'),
          ),
        );
      }
    }
  }

// Método para verificar si el dinero en la billetera es suficiente
Future<bool> checkWalletBalance(String startDateTime, String endDateTime) async {
  try {
    // Fetch the user ID
    int? userId = await fetchUserId();

    if (userId == null) {
      print('Error: User ID is null.');
      return false;
    }

    // Fetch the user's wallet information
    Map<String, dynamic> wallet = await fetchWallet(userId);

    // Check if the wallet balance is greater than the reservation fee
    int reservationFee = 15; // Assuming the fixed fee is 15
    int walletBalance = wallet['balance'];

    // Calculate the difference in time (in minutes)
    DateTime start = DateTime.parse(startDateTime);
    DateTime end = DateTime.parse(endDateTime);
    Duration difference = end.difference(start);
    int differenceInMinutes = difference.inMinutes;

    // Calculate the amount based on the reservation fee and time difference
    int amount = reservationFee * differenceInMinutes;

    return walletBalance >= amount;
  } catch (e) {
    print('Error checking wallet balance: $e');
    return false;
  }
}


// Método para mostrar un mensaje de alerta por saldo insuficiente
void showInsufficientBalanceAlert() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Saldo Insuficiente'),
        content: Text('Tu saldo en la billetera no es suficiente para realizar la reserva.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Aceptar'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservar Estacionamiento'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Reservar Estacionamiento',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (walletBalance != null)
                Text(
                  'Saldo en Billetera: \$$walletBalance',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Información del Estacionamiento:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (parkingSpace != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nombre: ${parkingSpace!.name}'),
                      Text('Descripción: ${parkingSpace!.description}'),
                      Text('Estado: ${parkingSpace!.state ? 'Disponible' : 'Ocupado'}'),
                      Text('Ubicación: ${parkingSpace!.location.toString()}'),
                    ],
                  ),
                SizedBox(height: 20),
                Text(
                  'Seleccione una Fecha y Hora:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: fechaController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Fecha (dd/mm/yyyy)',
                    hintText: 'Seleccione una fecha',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: _pickDate,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, seleccione una fecha.';
                    }
                    if (!isValidDate(value)) {
                      return 'Fecha no válida. Utilice el formato dd/mm/yyyy.';
                    }
                    return null;
                  },
                  onTap: _pickDate,
                ),
                TextFormField(
                  controller: horaController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Hora de Inicio (hh:mm)',
                    hintText: 'Seleccione una hora de inicio',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: _pickTime,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, seleccione una hora de inicio.';
                    }
                    if (!isValidTime(value)) {
                      return 'Hora no válida. Utilice el formato hh:mm.';
                    }
                    return null;
                  },
                  onTap: _pickTime,
                ),
                TextFormField(
                  controller: endTimeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Hora de Fin (hh:mm)',
                    hintText: 'Seleccione una hora de fin',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: _pickEndTime,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, seleccione una hora de fin.';
                    }
                    if (!isValidTime(value)) {
                      return 'Hora no válida. Utilice el formato hh:mm.';
                    }
                    return null;
                  },
                  onTap: _pickEndTime,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Ocupar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ConfirmationScreen extends StatelessWidget {
  final String cost;
  final String parkingSpaceName;
  final String startDateTime;
  final String endDateTime;
  final Function onAccept;

  ConfirmationScreen({
    required this.cost,
    required this.parkingSpaceName,
    required this.startDateTime,
    required this.endDateTime,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmación de Reserva'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Detalles de la Reserva:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Estacionamiento: $parkingSpaceName',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Text(
              'Fecha y Hora de Inicio: $startDateTime',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Text(
              'Fecha y Hora de Fin: $endDateTime',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Costo de la Reserva:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '\$$cost',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Perform the action when the user accepts
                onAccept();
              },
              child: Text('Aceptar Reserva'),
            ),
          ],
        ),
      ),
    );
  }
}




bool isValidDate(String input) {
  final RegExp regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
  return regex.hasMatch(input);
}

bool isValidTime(String input) {
  final RegExp regex = RegExp(r'^\d{2}:\d{2}$');
  return regex.hasMatch(input);
}


