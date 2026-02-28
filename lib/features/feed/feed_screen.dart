import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(title: const Text("Explore News"), backgroundColor: Colors.white, elevation: 0),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                Container(height: 150, decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(15)))),
                ListTile(
                  title: Text("Vexylon Update #${index + 1}"),
                  subtitle: const Text("Checking out the new professional UI of our super app."),
                  trailing: const Icon(Icons.favorite_border, color: Colors.red),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
