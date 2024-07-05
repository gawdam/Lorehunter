import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorehunter/screens/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Flutter Demo',
        // theme: ThemeData(
        //   useMaterial3: true,

        // ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}
