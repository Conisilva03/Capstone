import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? selectedMarkerLocation;
  Position? currentLocation;

  List<LatLng> parkingSpaceLocations = [];
  List<LatLng> filteredParkingSpaceLocations = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
    getCurrentLocation();

  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://api1.marweg.cl/parking_spaces'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<LatLng> locations = data.map<LatLng>((parkingSpace) {
        return LatLng(parkingSpace['latitude'], parkingSpace['longitude']);
      }).toList();

      setState(() {
        parkingSpaceLocations = locations;
        filteredParkingSpaceLocations = locations;
      });
    } else {
      throw Exception('Failed to load data');
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
    print(e);
  }
}


  void _showMarkerInfo(BuildContext context, LatLng location) {
    final selectedParkingSpace = parkingSpaceLocations.firstWhere(
      (LatLng parkingSpace) =>
          parkingSpace.latitude == location.latitude &&
          parkingSpace.longitude == location.longitude,
    );

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Parking Space Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              
             
              Text('Longitude: ${selectedParkingSpace.longitude}'),
              Text('Latitude: ${selectedParkingSpace.latitude}'),
              // Add more information as needed
            ],
          ),
        );
      },
    );
  }

  void filterParkingSpaces(String query) {
    setState(() {
      filteredParkingSpaceLocations = parkingSpaceLocations
          .where((location) =>
              location.toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  ? LatLng(currentLocation!.latitude, currentLocation!.longitude)
                  : LatLng(-36.714658, -73.114729), // Default center coordinates
              zoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: filteredParkingSpaceLocations
                    .map<Marker>((LatLng location) => Marker(
                          point: location,
                          width: 80,
                          height: 80,
                          builder: (context) => GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedMarkerLocation = location;
                              });
                              _showMarkerInfo(context, location);
                            },
                            child: Icon(
                              Icons.directions_car ,
                              color: selectedMarkerLocation == location
                                  ? Colors.red
                                  : Colors.blue,
                              size: 48.0,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
