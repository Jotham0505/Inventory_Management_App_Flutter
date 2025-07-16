import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Container(
          width: double.infinity,
          height: 320,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/onboardingImage.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '  Welcome to Tea \nInventory Manager',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Epilogue',
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '  Manage your tea inventory with ease. \nTrack your teas, suppliers, and orders.',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Epilogue Regular',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {},
          child: const Text('Sign Up'),
          style: TextButton.styleFrom(
            backgroundColor: Color(0XFF17CF73),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 15),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Epilogue',
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {},
          child: const Text('Login'),
          style: TextButton.styleFrom(
            backgroundColor: Color(0XFF17CF73),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 130, vertical: 15),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Epilogue',
            ),
          ),
        ),
      ],
    ));
  }
}
