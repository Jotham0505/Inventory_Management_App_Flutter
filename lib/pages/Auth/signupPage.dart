import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back, size: 30),
                SizedBox(
                  width: 90,
                ),
                Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Epilogue',
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: 330,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 217, 243, 227),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Username',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: 330,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 217, 243, 227),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: 330,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 217, 243, 227),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: 330,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 217, 243, 227),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
            Spacer(),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: Color(0XFF17CF73),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 140, vertical: 20),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Epilogue',
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8), // Change the value as needed
                ),
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Epilogue',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
