import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Board extends StatefulWidget {
  final double height;
  final List<String> words;

  Board({Key key, @required this.height, @required this.words})
      : super(key: key);

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  final nRows = 5;
  final nCols = 5;
  final List hitLetters = [];

  @override
  Widget build(BuildContext context) {
    final randomLetters = generateRandomLetters();
    final boardWidth = MediaQuery.of(context).size.width;
    final letterWidth = boardWidth / nCols;
    final letterHeight = widget.height / nRows;

    print("[board] width: $boardWidth height: ${widget.height}");

    return Stack(
      children: [
        GridView.count(
          childAspectRatio: letterWidth / letterHeight,
          crossAxisCount: nCols,
          children: randomLetters
              .asMap()
              .map(
                (index, letter) => MapEntry(
                  index,
                  BoardLetter(
                    letter,
                    hitLetters.contains(index),
                  ),
                ),
              )
              .values
              .toList(),
        ),
        Positioned(
          width: boardWidth,
          height: widget.height,
          child: GestureDetector(
            onPanEnd: onPanEnd,
            onPanUpdate: (details) =>
                onPanUpdate(details, letterWidth, letterHeight),
            child: Container(
              color: Colors.red.withAlpha(100),
            ),
          ),
        ),
      ],
    );
  }

  List<String> generateRandomLetters() {
    return [
      'a',
      'x',
      'd',
      'a',
      'e',
      'm',
      'a',
      'm',
      'o',
      'r',
      'f',
      'b',
      'ç',
      'c',
      'g',
      's',
      'l',
      'e',
      'i',
      'f',
      'u',
      'a',
      'd',
      'o',
      'm'
    ];
  }

  void onPanUpdate(
      DragUpdateDetails details, double letterWidth, double letterHeight) {
    final position = details.localPosition;
    var colOffset = position.dx ~/ letterWidth;
    var rowOffset = position.dy ~/ letterHeight;
    var letterHitIndex = rowOffset * nCols + colOffset;

    this.setState(() {
      hitLetters.add(letterHitIndex);
    });
  }

  void onPanEnd(DragEndDetails details) {
    this.setState(() {
      hitLetters.clear();
    });
  }
}

class BoardLetter extends StatelessWidget {
  final String letter;
  final bool isSelected;

  const BoardLetter(
    this.letter,
    this.isSelected, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange : Colors.blue,
        border: Border.all(width: 1),
      ),
      child: Center(child: Text(letter)),
    );
  }
}
