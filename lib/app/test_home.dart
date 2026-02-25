import 'package:flutter/material.dart';

class TestHome extends StatelessWidget {
  const TestHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Screen'),
      ),
      body: Column(
        children: [
          Text('home screen'),
        ],
      ),
    );
  }
}
