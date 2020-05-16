import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Board extends StatefulWidget {
  final double width;
  final double height;
  final List<String> words;

  Board(
      {Key key,
      @required this.width,
      @required this.height,
      @required this.words})
      : super(key: key);

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  final nRows = 5;
  final nCols = 5;
  List<int> hitLetters = [];
  int startIndex;

  double get letterWidth {
    return widget.width / nCols;
  }

  double get letterHeight {
    return widget.height / nRows;
  }

  @override
  Widget build(BuildContext context) {
    final randomLetters = generateRandomLetters();

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
          width: widget.width,
          height: widget.height,
          child: GestureDetector(
            onPanStart: onPanStart,
            onPanEnd: onPanEnd,
            onPanUpdate: (details) => onPanUpdate(details),
            child: Opacity(
              opacity: 0.3,
              child: Container(
                color: Colors.red,
              ),
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

  int computeLetterIndex(Offset localPosition) {
    var colOffset = localPosition.dx ~/ letterWidth;
    var rowOffset = localPosition.dy ~/ letterHeight;
    return rowOffset * nCols + colOffset;
  }

  int colOf(int index) {
    return index % nCols;
  }

  bool checkSameRow(int startIndex, int endIndex) {
    return startIndex ~/ nCols == endIndex ~/ nCols;
  }

  bool checkSameCol(int startIndex, int endIndex) {
    return startIndex % nCols == endIndex % nCols;
  }

  bool checkSameMainDiagonal(int startIndex, int endIndex) {
    return colOf(max(startIndex, endIndex)) >
            colOf(min(startIndex, endIndex)) &&
        startIndex % (nCols + 1) == endIndex % (nCols + 1);
  }

  bool checkSameCounterDiagonal(int startIndex, int endIndex) {
    return colOf(max(startIndex, endIndex)) <
            colOf(min(startIndex, endIndex)) &&
        startIndex % (nCols - 1) == endIndex % (nCols - 1);
  }

  List<int> genSelection(int startIndex, int endIndex, int growFactor) {
    final selection = <int>[];
    if (startIndex > endIndex) {
      var temp = startIndex;
      startIndex = endIndex;
      endIndex = temp;
    }
    for (int i = startIndex; i <= endIndex; i += growFactor) {
      selection.add(i);
    }
    return selection;
  }

  void onPanUpdate(DragUpdateDetails details) {
    final currentIndex = computeLetterIndex(details.localPosition);

    if (checkSameRow(startIndex, currentIndex)) {
      print("[onPanUpdate] row selection");
      this.setState(() {
        hitLetters = genSelection(startIndex, currentIndex, 1);
      });
    } else if (checkSameCol(startIndex, currentIndex)) {
      print("[onPanUpdate] col selection");
      this.setState(() {
        hitLetters = genSelection(startIndex, currentIndex, nCols);
      });
    } else if (checkSameMainDiagonal(startIndex, currentIndex)) {
      print("[onPanUpdate] main diagonal selection");
      this.setState(() {
        hitLetters = genSelection(startIndex, currentIndex, nCols + 1);
      });
    } else if (checkSameCounterDiagonal(startIndex, currentIndex)) {
      print("[onPanUpdate] counter diagonal selection");
      this.setState(() {
        hitLetters = genSelection(startIndex, currentIndex, nCols - 1);
      });
    } else {
      print("[onPanUpdate] invalid selection");
    }
  }

  void onPanEnd(DragEndDetails details) {
    print("[onPandEnd]");
  }

  void onPanStart(DragStartDetails details) {
    final letterIndex = computeLetterIndex(details.localPosition);
    print("[onPanStart] hit letter $letterIndex");

    this.setState(() {
      startIndex = letterIndex;
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
