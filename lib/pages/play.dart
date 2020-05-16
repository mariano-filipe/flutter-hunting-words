import 'package:flutter/material.dart';

import 'package:hunting_words/widgets/board.dart';

class PlayPage extends StatefulWidget {
  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  final _gameText = "amor";
  final _gameWords = ["barco", "remo", "maçã", "banana"];

  @override
  Widget build(BuildContext context) {
    final boardHeight = 0.5 * MediaQuery.of(context).size.height;
    print("[PlayPage] width: ${MediaQuery.of(context).size.width}");
    print("boardHeight: $boardHeight");

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
                child: Board(height: boardHeight, words: _gameWords),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
