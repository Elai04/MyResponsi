import 'package:disaster_locator/screens/auth.dart';
import 'package:disaster_locator/screens/map.dart';
import 'package:flutter/material.dart';
import 'screens/reports.dart';

void main() => runApp(const DisasterLocatorApp());

class DisasterLocatorApp extends StatelessWidget {
  const DisasterLocatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'Bebas Neue',
          useMaterial3: true,
          colorSchemeSeed: Colors.red),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // SCREENS
  static const List<Widget> _pages = <Widget>[
    Center(child: MapScreen()),
    Center(child: ReportsScreen()),
    Center(child: Text('SOS Emergency Trigger')),
    Center(child: AuthScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: AppBar(
              centerTitle: true,
              backgroundColor: Color(0xFFEBEBEB),
              title: Text(
                'Disaster Resource Locator',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Color(0xFFDE4855),
                ),
                textAlign: TextAlign.center,
              )),
        ),
      ),
      body: _pages[_selectedIndex],
      backgroundColor: Color(0xFFEBEBEB),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFEBEBEB),
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed, // Necessary for 4+ items
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.map, color: Color(0xFFDE4855)), label: 'Map'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart, color: Color(0xFFDE4855)),
              label: 'Reports'),
          BottomNavigationBarItem(
              icon: Icon(Icons.warning, color: Color(0xFFDE4855)),
              label: 'SOS'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Color(0xFFDE4855)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
