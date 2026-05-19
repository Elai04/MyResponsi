import 'package:disaster_locator/screens/auth.dart';
import 'package:disaster_locator/screens/map.dart';
import 'package:disaster_locator/screens/profile.dart';
import 'package:disaster_locator/screens/reports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:disaster_locator/firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const DisasterLocatorApp());
}

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
      // The top-level gatekeeper checking if user is logged in or out
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            FlutterNativeSplash.remove();
            return const MainNavigation(); // Logged in -> Enter App
          }
          FlutterNativeSplash.remove();
          return const AuthScreen(); // Logged out -> Show Auth Screen
        },
      ),
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

  final List<Widget> _pages = const [
    MapScreen(),
    ReportsScreen(),
    Center(child: Text('SOS Emergency Trigger')),
    ProfileScreen(), // Your fully operational CRUD profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: AppBar(
              centerTitle: true,
              backgroundColor: const Color(0xFFEBEBEB),
              title: const Text(
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      backgroundColor: const Color(0xFFEBEBEB),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFEBEBEB),
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map, color: Color(0xFFDE4855)), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart, color: Color(0xFFDE4855)), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.warning, color: Color(0xFFDE4855)), label: 'SOS'),
          BottomNavigationBarItem(icon: Icon(Icons.person, color: Color(0xFFDE4855)), label: 'Profile'),
        ],
      ),
    );
  }
}