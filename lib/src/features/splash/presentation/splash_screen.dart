import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // GoRouter's redirect logic handles navigation away from splash.
    // This screen just shows a loading indicator or logo while redirect happens.
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             // TODO: Replace with your actual App Logo widget
             Icon(Icons.book_online, size: 80, color: Colors.deepPurple),
             SizedBox(height: 20),
             Text("مسارات النور", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
             SizedBox(height: 40),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}