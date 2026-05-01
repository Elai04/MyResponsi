import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. The "Map" Background

        Padding(
          padding: const EdgeInsets.all(8.0), // The margin you wanted
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
                20.0), // Adjust this number for more/less roundness
            child: Image.asset(
              'assets/map.jpg', // Ensure this matches your filename in pubspec.yaml
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        // 2. The Category Filter (Floating at the top)
        Positioned(
          top: 20,
          left: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list, color: Colors.red),
              onSelected: (String result) {
                // This is where you would filter the map later
                print("Selected: $result");
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                _buildPopupItem("Hospital", Icons.local_hospital, Colors.red),
                _buildPopupItem("Pharmacy", Icons.local_pharmacy, Colors.green),
                _buildPopupItem("School (PPS)", Icons.school, Colors.blue),
                _buildPopupItem(
                    "Hall (PPS)", Icons.meeting_room, Colors.orange),
              ],
            ),
          ),
        ),

        // 3. Floating Action Button for SOS
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton.large(
            backgroundColor: Color.fromARGB(255, 222, 72, 85),
            onPressed: () {}, // Lead to SOS screen
            child: const Text("SOS",
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // Simple widget to create the filter buttons
  Widget _filterChip(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Chip(
        backgroundColor: color.withOpacity(0.2),
        side: BorderSide(color: color),
        label: Text(label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

PopupMenuItem<String> _buildPopupItem(
    String label, IconData icon, Color color) {
  return PopupMenuItem<String>(
    value: label,
    child: Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
