import 'package:flutter/material.dart';

import 'package:hunting_words/widgets/board.dart';

class PlayPage extends StatefulWidget {
  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  final _gameText = "amor";
  final _gameWords = [
    "banana",
    "maca",
    "abacaxi",
    "laranja",
    "melao",
    "melancia",
    "pera",
    "pessego",
    "abacate",
    "tomate"
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final boardWidth = size.width;
    final boardHeight = 0.5 * size.height;
    print("[PlayPage] Board(width=$boardWidth, height=$boardHeight)");

    return Scaffold(
      appBar: AppBar(
        title: Text('Jogar'),
      ),
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(8.0),
                child: Text(_gameText),
              ),
              Flexible(
                child: Board(
                  width: boardWidth,
                  height: boardHeight,
                  words: _gameWords,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
