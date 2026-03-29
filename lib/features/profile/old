import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 60),
          const CircleAvatar(radius: 50, backgroundColor: Color(0xFF0284C7), child: Icon(Icons.person, size: 50, color: Colors.white)),
          const SizedBox(height: 15),
          const Text("Vexylon User", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("user@vexylon.com", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              children: [
                _buildProfileItem(Icons.wallet, "My Wallet"),
                _buildProfileItem(Icons.history, "Order History"),
                _buildProfileItem(Icons.settings, "Settings"),
                _buildProfileItem(Icons.help_outline, "Support Center"),
                _buildProfileItem(Icons.logout, "Logout", isLast: true),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, {bool isLast = false}) {
    return ListTile(
      leading: Icon(icon, color: isLast ? Colors.red : const Color(0xFF0284C7)),
      title: Text(title, style: TextStyle(color: isLast ? Colors.red : Colors.black)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
