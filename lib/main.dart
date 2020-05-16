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
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => HomePage(title: 'Caça Palavras'),
          '/play': (context) => PlayPage()
        });
  }
}
