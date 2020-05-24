import 'package:flutter/material.dart';

class WordList extends StatelessWidget {
  final List<String> words;
  final List<int> hitIndexes;

  const WordList(this.words, {Key key, @required this.hitIndexes})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 5,
      children: words
          .asMap()
          .map(
            (index, word) => MapEntry(
              index,
              Center(
                child: Text(
                  word,
                  style: TextStyle(
                    color: hitIndexes.contains(index)
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black,
                    decoration: hitIndexes.contains(index)
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
            ),
          )
          .values
          .toList(),
    );
  }
}
