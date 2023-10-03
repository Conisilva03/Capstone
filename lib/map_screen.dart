import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

    LatLng? selectedMarkerLocation;

  List<LatLng> parkingSpaceLocations = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://localhost:8000/parking_spaces'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<LatLng> locations = data.map<LatLng>((parkingSpace) {
        return LatLng(parkingSpace['latitude'], parkingSpace['longitude']);
      }).toList();

      setState(() {
        parkingSpaceLocations = locations;
      });
    } else {
      throw Exception('Failed to load data');
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
            Text('Latitude: ${selectedParkingSpace.latitude}'),
            Text('Longitude: ${selectedParkingSpace.longitude}'),
            // Add more information as needed
          ],
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(-36.827, -73.050), // Coordinates of Concepción, Chile
        zoom: 12.0, // Adjust the zoom level as needed
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayer(
            markers: parkingSpaceLocations
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
                          Icons.local_parking,
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
    );
  }
}
