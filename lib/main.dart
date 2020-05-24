import 'package:flutter/material.dart';

import 'package:hunting_words/pages/home.dart';
import 'package:hunting_words/pages/play.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hunting Words',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.amberAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(title: 'Hunting Words'),
        '/play': (context) => PlayPage()
      },
    );
  }
}
