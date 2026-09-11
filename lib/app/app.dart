import 'package:flutter/material.dart';

class ShopSphereApp extends StatelessWidget {
  const ShopSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopSphere',
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: Text('ShopSphere'))),
    );
  }
}
