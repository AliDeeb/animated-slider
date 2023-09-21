import 'package:animated_slider/animated_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Animated slider',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int weight = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "What is your weight ?",
              style: TextStyle(
                fontSize: 32.0,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
            ),
            Text(
              "$weight",
              style: TextStyle(
                fontSize: 36.0,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontWeight: FontWeight.bold,
              ),
            ),
            AnimatedSlider(
              width: MediaQuery.of(context).size.width,
              height: 125,
              minRange: 40,
              maxRange: 120,
              dotColor: Colors.black,
              lineColor: Colors.black,
              lineStrokeWidth: 1.5,
              activeWindowColor: Colors.black,
              inactiveWindowColor: Colors.transparent,
              minmaxRangeStyle: null,
              inactiveValueColor: Colors.black,
              activeValueColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  weight = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
