import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isLoggingOut = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedAvatar = "🦁";

  final List<String> _avatars = ["🦁", "🦊", "🐻", "🐼", "🐨", "🤖"];

  final User? _currentUser = FirebaseAuth.instance.currentUser;

  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout Failed: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  Future<void> _saveProfileToFirebase() async {
    if (_currentUser == null) return;

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name field cannot be empty")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _usersCollection.doc(_currentUser.uid).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'avatar': _selectedAvatar,
        'email': _currentUser.email,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated in Firestore!")),
      );
      setState(() => _isEditing = false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save data: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(body: Center(child: Text("No user logged in.")));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _usersCollection.doc(_currentUser.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !_isSaving) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFDE4855))));
        }

        // Initialize our input text controllers if remote database data exists
        if (snapshot.hasData && snapshot.data!.exists && !_isEditing && !_isSaving) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          _nameController.text = data['name'] ?? "";
          _phoneController.text = data['phone'] ?? "";
          _selectedAvatar = data['avatar'] ?? "🦁";
        }

        return Scaffold(
          backgroundColor: const Color(0xFFEBEBEB),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                children: [
                  // --- AVATAR DISPLAY & SELECTION ---
                  Text(_selectedAvatar, style: const TextStyle(fontSize: 80)),

                  if (_isEditing) ...[
                    const SizedBox(height: 10),
                    const Text("Select Avatar Picture:"),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 10,
                      children: _avatars.map((avatar) {
                        return GestureDetector(
                          onTap: () => setState(() => _selectedAvatar = avatar),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedAvatar == avatar ? const Color(0xFFDE4855) : Colors.transparent,
                                width: 2,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Text(avatar, style: const TextStyle(fontSize: 24)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // --- DISPLAY / EDIT FORMS ---
                  if (!_isEditing) ...[
                    Text(
                        _nameController.text.isEmpty ? "Set Account Name" : _nameController.text,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 5),
                    Text(
                        _phoneController.text.isEmpty ? "No Phone Number Added" : _phoneController.text,
                        style: const TextStyle(fontSize: 18, color: Colors.black54)
                    ),
                    const SizedBox(height: 5),
                    Text(_currentUser.email ?? "", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _isEditing = true),
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit Profile Data"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 45),
                        backgroundColor: const Color(0xFFDE4855),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(fontFamily: 'sans-serif'), // Keep plain font for user typing input fields
                      decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _phoneController,
                      style: const TextStyle(fontFamily: 'sans-serif'),
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: _isSaving ? null : () => setState(() => _isEditing = false),
                          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfileToFirebase,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          child: _isSaving
                              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("Save Changes"),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 50),
                  const Divider(),
                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: _isLoggingOut ? null : _logout,
                    icon: _isLoggingOut ? const SizedBox.shrink() : const Icon(Icons.logout),
                    label: _isLoggingOut
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Log Out"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}