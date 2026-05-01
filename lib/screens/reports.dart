import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          "Live Agency Updates",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // 1. Flood Level Card (Sg. Damansara example)
        _reportCard(
          title: "Flood: Sg. Damansara",
          subtitle: "Current Water Level: 5.2m",
          status: "Warning",
          color: Colors.orange,
          icon: Icons.water_damage,
        ),

        // 2. Haze / IPU Card
        _reportCard(
          title: "Haze: Air Pollutant Index",
          subtitle: "Current IPU: 55 (Moderate)",
          status: "Stable",
          color: Colors.green,
          icon: Icons.air,
        ),

        // 3. NADMA Bulletin
        _reportCard(
          title: "NADMA Bulletin",
          subtitle: "Evacuation centers (PPS) active in Selangor.",
          status: "Official",
          color: Colors.blue,
          icon: Icons.info_outline,
        ),
      ],
    );
  }

  // A simple, reusable card for your report front-end
  Widget _reportCard(
      {required String title,
      required String subtitle,
      required String status,
      required Color color,
      required IconData icon}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: color, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(8)),
          child: Text(status,
              style: const TextStyle(color: Colors.white, fontSize: 10)),
        ),
      ),
    );
  }
}
