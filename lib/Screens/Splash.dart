import 'package:short_video_editor/Screens/Home.dart';
import 'package:short_video_editor/main.dart';
import 'package:flutter/material.dart';
import 'package:short_video_editor/Screens/Splash.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();

    // Delay for 2 seconds and navigate to Home screen
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.cyanAccent, Colors.purple], // Light sky blue & cyan
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/qlogo.png", height: 250),
              SizedBox(height: 20),
              Text(
                "QuickTrim Fast Video Editor",
                style: TextStyle(
                  fontSize: 24, // Slightly larger for better visibility
                  fontWeight: FontWeight.w900, // Extra bold for emphasis
                  color: Colors.white,
                  letterSpacing: 1.5, // Adds spacing between letters for a sleek look
                  shadows: [
                    Shadow(
                      blurRadius: 5,
                      color: Colors.black.withOpacity(0.3), // Subtle text shadow
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center, // Ensures the text is well-aligned
              ),

            ],
          ),
        ),
      ),
    );
  }

}
