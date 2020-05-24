import 'package:flutter/material.dart';

import 'package:hunting_words/widgets/board.dart';
import 'package:hunting_words/widgets/word_list.dart';

class PlayPage extends StatefulWidget {
  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  final gameWords = [
    "banana",
    "maca",
    "abacaxi",
    "laranja",
    "melao",
    "pera",
    "pessego",
    "abacate",
    "tomate",
    "melancia",
  ];
  List<int> hitWordIndexes = [];

  bool get isFinished {
    return hitWordIndexes.length == gameWords.length;
  }

  void onHomeAction(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacementNamed("/");
  }

  void onNewGameAction(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacementNamed("/play");
  }

  void onHitWord(String word, int wordIndex) {
    this.setState(() {
      hitWordIndexes = List.from(hitWordIndexes)..add(wordIndex);
    });

    if (isFinished) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text("Parabéns!"),
          content: Text("Você encontrou todas as palavras."),
          actions: [
            FlatButton(
              child: Text("Início"),
              onPressed: () => onHomeAction(context),
            ),
            FlatButton(
              child: Text("Novo Jogo"),
              onPressed: () => onNewGameAction(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final boardWidth = size.width;
    final boardHeight = 0.5 * size.height;
    print("[PlayPage] Board(width=$boardWidth, height=$boardHeight)");

    return Scaffold(
      appBar: AppBar(title: Text('Jogar')),
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Container(
                height: 0.2 * size.height,
                child: WordList(gameWords, hitIndexes: hitWordIndexes),
              ),
              Flexible(
                child: Board(
                  width: boardWidth,
                  height: boardHeight,
                  words: gameWords,
                  onHitWord: onHitWord,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
