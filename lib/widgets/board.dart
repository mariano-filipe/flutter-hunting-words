import 'dart:math';
import 'package:flutter/material.dart';

import "package:hunting_words/models/hunting_words.dart";

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
  final nRows = 8;
  final nCols = 8;
  List<List<String>> puzzle;
  List<int> hitLetters = [];
  int startIndex;

  double get letterWidth {
    return widget.width / nCols;
  }

  double get letterHeight {
    return widget.height / nRows;
  }

  @override
  void initState() {
    puzzle = HuntingWords(words: widget.words, settings: {
      "width": nRows,
      "height": nCols,
    }).puzzle;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GridView.count(
          childAspectRatio: letterWidth / letterHeight,
          crossAxisCount: nCols,
          children: puzzle
              .expand((i) => i)
              .toList()
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
      this.setState(() {
        hitLetters = genSelection(startIndex, currentIndex, 1);
      });
    } else if (checkSameCol(startIndex, currentIndex)) {
      this.setState(() {
        hitLetters = genSelection(startIndex, currentIndex, nCols);
      });
    } else if (checkSameMainDiagonal(startIndex, currentIndex)) {
      this.setState(() {
        hitLetters = genSelection(startIndex, currentIndex, nCols + 1);
      });
    } else if (checkSameCounterDiagonal(startIndex, currentIndex)) {
      this.setState(() {
        hitLetters = genSelection(startIndex, currentIndex, nCols - 1);
      });
    }
  }

  void onPanEnd(DragEndDetails details) {}

  void onPanStart(DragStartDetails details) {
    this.setState(() {
      startIndex = computeLetterIndex(details.localPosition);
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
