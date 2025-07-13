import 'package:flutter/material.dart';
import 'package:apk_pre_order_makanan/halaman_utama.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Pre-Order Makanan',
      debugShowCheckedModeBanner: false,
      home: HalamanUtama(),
    );
  }
}
