import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // 🚀 FIXED: Removed the trailing '2.dart' here
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _currentPosition;
  final MapController _mapController = MapController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  /// Request permission and fetch live device location coordinates
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled. Please enable them.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    // Get current position coordinates
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    }

    // Start listening to live location stream changes
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((Position streamPosition) {
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(streamPosition.latitude, streamPosition.longitude);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. The Interactive Map canvas
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: _isLoading || _currentPosition == null
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFDE4855)),
                  SizedBox(height: 10),
                  Text("Fetching live GPS location...", style: TextStyle(color: Colors.black54)),
                ],
              ),
            )
                : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition!,
                initialZoom: 15.0,
              ),
              children: [
                // Renders open-source map tiles from OpenStreetMap
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.disaster_locator',
                ),
                // Renders the live pulsing marker for user position
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 50,
                      height: 50,
                      child: const Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 9,
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // 2. Category Filter Panel
        Positioned(
          top: 20,
          left: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list, color: Color(0xFFDE4855)),
              onSelected: (String result) {
                print("Selected filter: $result");
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                _buildPopupItem("Hospital", Icons.local_hospital, Colors.red),
                _buildPopupItem("Pharmacy", Icons.local_pharmacy, Colors.green),
                _buildPopupItem("School (PPS)", Icons.school, Colors.blue),
                _buildPopupItem("Hall (PPS)", Icons.meeting_room, Colors.orange),
              ],
            ),
          ),
        ),

        // 3. Recenter Button
        if (!_isLoading && _currentPosition != null)
          Positioned(
            bottom: 110,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                _mapController.move(_currentPosition!, 15.0);
              },
              child: const Icon(Icons.my_location, color: Color(0xFFDE4855)),
            ),
          ),

        // 4. Large Floating Emergency SOS Trigger
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton.large(
            backgroundColor: const Color(0xFFDE4855),
            onPressed: () {
              // Action logic for routing to SOS
            },
            child: const Text(
              "SOS",
              style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(String label, IconData icon, Color color) {
    return PopupMenuItem<String>(
      value: label,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}