import 'dart:math';
import 'package:flutter/material.dart';

import "package:hunting_words/models/hunting_words.dart";

class Board extends StatefulWidget {
  final double width;
  final double height;
  final List<String> words;
  final onHitWord;

  Board(
      {Key key,
      @required this.width,
      @required this.height,
      @required this.words,
      @required this.onHitWord})
      : super(key: key);

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  final nRows = 10;
  final nCols = 10;
  List<String> puzzle;
  List<int> selection = [];
  List<int> hitIndexes = [];
  int startIndex;

  double get letterWidth {
    return widget.width / nCols;
  }

  double get letterHeight {
    return widget.height / nRows;
  }

  @override
  void initState() {
    var _puzzle = HuntingWords(words: widget.words, settings: {
      "width": nRows,
      "height": nCols,
    }).puzzle;
    puzzle = _puzzle.expand((i) => i).toList();

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
              .asMap()
              .map(
                (index, letter) => MapEntry(
                  index,
                  BoardLetter(
                    letter,
                    isSelected: selection.contains(index),
                    isHit: hitIndexes.contains(index),
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
              opacity: 0,
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
    final _selection = <int>[];
    if (startIndex > endIndex) {
      var temp = startIndex;
      startIndex = endIndex;
      endIndex = temp;
    }
    for (int i = startIndex; i <= endIndex; i += growFactor) {
      _selection.add(i);
    }
    return _selection;
  }

  void onPanUpdate(DragUpdateDetails details) {
    final currentIndex = computeLetterIndex(details.localPosition);
    List<int> _selection = [];
    if (checkSameRow(startIndex, currentIndex)) {
      _selection = genSelection(startIndex, currentIndex, 1);
    } else if (checkSameCol(startIndex, currentIndex)) {
      _selection = genSelection(startIndex, currentIndex, nCols);
    } else if (checkSameMainDiagonal(startIndex, currentIndex)) {
      _selection = genSelection(startIndex, currentIndex, nCols + 1);
    } else if (checkSameCounterDiagonal(startIndex, currentIndex)) {
      _selection = genSelection(startIndex, currentIndex, nCols - 1);
    }

    this.setState(() {
      selection = _selection;
    });
  }

  void onPanEnd(DragEndDetails details) {
    final word = selection
        .map((index) => puzzle[index])
        .fold("", (value, letter) => value + letter);

    // Check if this is a valid word
    var reversedWord = word.split('').reversed.join();
    var wordIndex = widget.words
        .indexWhere((gameWord) => gameWord == word || gameWord == reversedWord);

    if (wordIndex != -1) {
      print("word $word/$reversedWord was hit");
      widget.onHitWord(word, wordIndex);
      this.setState(() {
        hitIndexes = List.from(hitIndexes)..addAll(selection);
      });
    }
    this.setState(() {
      selection = [];
    });
  }

  void onPanStart(DragStartDetails details) {
    this.setState(() {
      startIndex = computeLetterIndex(details.localPosition);
    });
  }
}

class BoardLetter extends StatelessWidget {
  final String letter;
  final bool isSelected;
  final bool isHit;

  const BoardLetter(
    this.letter, {
    @required this.isSelected,
    @required this.isHit,
    Key key,
  }) : super(key: key);

  Color getColor(BuildContext context) {
    if (isSelected) {
      return Theme.of(context).primaryColor;
    }
    if (isHit) {
      return Theme.of(context).accentColor;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: getColor(context),
        border: Border.all(width: 1),
      ),
      child: Center(child: Text(letter)),
    );
  }
}
