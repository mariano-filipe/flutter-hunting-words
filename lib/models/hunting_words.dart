/*
* Wordfind.js 0.0.1
* (c) 2012 Bill, BunKat LLC.
* Wordfind is freely distributable under the MIT license.
* For all details and documentation: http://github.com/bunkat/wordfind
* - Translation to Dart by Filipe Mariano (fmarianofs@gmail.com)
*/

import 'dart:math';
import 'package:flutter/foundation.dart';

/*
* Generates a new word find (word search) puzzle provided a set of words.
* Can automatically determine the smallest puzzle size in which all words
* fit, or the puzzle size can be manually configured.  Will automatically
* increase puzzle size until a valid puzzle is found.
*/
class HuntingWords {
  // Letters used to fill blank spots in the puzzle
  static const LETTERS = 'abcdefghijklmnoprstuvwy';
  final List<String> words;
  List<List<String>> puzzle;

  HuntingWords({@required this.words, settings}) {
    puzzle = _newPuzzle(settings);
  }

  /*
  * Definitions for all the different orientations in which words can be
  * placed within a puzzle. New orientation definitions can be added and they
  * will be automatically available.
  */

  // The list of all the possible orientations
  var allOrientations = [
    'horizontal',
    'horizontalBack',
    'vertical',
    'verticalUp',
    'diagonal',
    'diagonalUp',
    'diagonalBack',
    'diagonalUpBack'
  ];

  // The definition of the orientation, calculates the next square given a
  // starting square (x,y) and distance (i) from that square.
  var orientations = {
    "horizontal": (x, y, i) => {"x": x + i, "y": y},
    "horizontalBack": (x, y, i) => {"x": x - i, "y": y},
    "vertical": (x, y, i) => {"x": x, "y": y + i},
    "verticalUp": (x, y, i) => {"x": x, "y": y - i},
    "diagonal": (x, y, i) => {"x": x + i, "y": y + i},
    "diagonalBack": (x, y, i) => {"x": x - i, "y": y + i},
    "diagonalUp": (x, y, i) => {"x": x + i, "y": y - i},
    "diagonalUpBack": (x, y, i) => {"x": x - i, "y": y - i}
  };

  // Determines if an orientation is possible given the starting square (x,y),
  // the height (h) and width (w) of the puzzle, and the length of the word (l).
  // Returns true if the word will fit starting at the square provided using
  // the specified orientation.
  var checkOrientations = {
    "horizontal": (x, y, h, w, l) => w >= x + l,
    "horizontalBack": (x, y, h, w, l) => x + 1 >= l,
    "vertical": (x, y, h, w, l) => h >= y + l,
    "verticalUp": (x, y, h, w, l) => y + 1 >= l,
    "diagonal": (x, y, h, w, l) => (w >= x + l) && (h >= y + l),
    "diagonalBack": (x, y, h, w, l) => (x + 1 >= l) && (h >= y + l),
    "diagonalUp": (x, y, h, w, l) => (w >= x + l) && (y + 1 >= l),
    "diagonalUpBack": (x, y, h, w, l) => (x + 1 >= l) && (y + 1 >= l)
  };

  // Determines the next possible valid square given the square (x,y) was ]
  // invalid and a word lenght of (l).  This greatly reduces the number of
  // squares that must be checked. Returning {x: x+1, y: y} will always work
  // but will not be optimal.
  var skipOrientations = {
    "horizontal": (x, y, l) => {"x": 0, "y": y + 1},
    "horizontalBack": (x, y, l) => {"x": l - 1, "y": y},
    "vertical": (x, y, l) => {"x": 0, "y": y + 100},
    "verticalUp": (x, y, l) => {"x": 0, "y": l - 1},
    "diagonal": (x, y, l) => {"x": 0, "y": y + 1},
    "diagonalBack": (x, y, l) => {"x": l - 1, "y": x >= l - 1 ? y + 1 : y},
    "diagonalUp": (x, y, l) => {"x": 0, "y": y < l - 1 ? l - 1 : y + 1},
    "diagonalUpBack": (x, y, l) => {"x": l - 1, "y": x >= l - 1 ? y + 1 : y}
  };

  /*
  * Initializes the puzzle and places words in the puzzle one at a time.
  *
  * Returns either a valid puzzle with all of the words or null if a valid
  * puzzle was not found.
  *
  * @param {[String]} words: The list of words to fit into the puzzle
  * @param {[Options]} options: The options to use when filling the puzzle
  */
  _fillPuzzle(words, options) {
    var puzzle = <List<String>>[];

    // initialize the puzzle with blanks
    for (int i = 0; i < options["height"]; i++) {
      puzzle.add(<String>[]);
      for (int j = 0; j < options["width"]; j++) {
        puzzle[i].add('');
      }
    }

    // add each word into the puzzle one at a time
    for (int i = 0; i < words.length; i++) {
      if (!_placeWordInPuzzle(puzzle, options, words[i])) {
        // if a word didn't fit in the puzzle, give up
        return null;
      }
    }

    // return the puzzle
    return puzzle;
  }

  /*
  * Adds the specified word to the puzzle by finding all of the possible
  * locations where the word will fit and then randomly selecting one. Options
  * controls whether or not word overlap should be maximized.
  *
  * Returns true if the word was successfully placed, false otherwise.
  *
  * @param {[[String]]} puzzle: The current state of the puzzle
  * @param {[Options]} options: The options to use when filling the puzzle
  * @param {String} word: The word to fit into the puzzle.
  */
  _placeWordInPuzzle(puzzle, options, word) {
    // find all of the best locations where this word would fit
    var locations = _findBestLocations(puzzle, options, word);

    if (locations.length == 0) {
      return false;
    }

    // select a location at random and place the word there
    var sel = locations[(Random().nextDouble() * locations.length).floor()];
    _placeWord(
      puzzle,
      word,
      sel["x"],
      sel["y"],
      orientations[sel["orientation"]],
    );

    return true;
  }

  /*
  * Iterates through the puzzle and determines all of the locations where
  * the word will fit. Options determines if overlap should be maximized or
  * not.
  *
  * Returns a list of location objects which contain an x,y cooridinate
  * indicating the start of the word, the orientation of the word, and the
  * number of letters that overlapped with existing letter.
  *
  * @param {[[String]]} puzzle: The current state of the puzzle
  * @param {[Options]} options: The options to use when filling the puzzle
  * @param {String} word: The word to fit into the puzzle.
  */
  _findBestLocations(puzzle, options, word) {
    var locations = [],
        height = options["height"],
        width = options["width"],
        wordLength = word.length,
        maxOverlap = 0; // we'll start looking at overlap = 0

    // loop through all of the possible orientations at this position
    for (int k = 0, len = options["orientations"].length; k < len; k++) {
      var orientation = options["orientations"][k],
          check = checkOrientations[orientation],
          next = orientations[orientation],
          skipTo = skipOrientations[orientation],
          x = 0,
          y = 0;

      // loop through every position on the board
      while (y < height) {
        // see if this orientation is even possible at this location
        if (check(x, y, height, width, wordLength)) {
          // determine if the word fits at the current position
          var overlap = _calcOverlap(word, puzzle, x, y, next);

          // if the overlap was bigger than previous overlaps that we've seen
          if (overlap >= maxOverlap ||
              (options["preferOverlap"] == null && overlap > -1)) {
            maxOverlap = overlap;
            locations.add({
              "x": x,
              "y": y,
              "orientation": orientation,
              "overlap": overlap
            });
          }

          x++;
          if (x >= width) {
            x = 0;
            y++;
          }
        } else {
          // if current cell is invalid, then skip to the next cell where
          // this orientation is possible. this greatly reduces the number
          // of checks that we have to do overall
          var nextPossible = skipTo(x, y, wordLength);
          x = nextPossible["x"];
          y = nextPossible["y"];
        }
      }
    }

    // finally prune down all of the possible locations we found by
    // only using the ones with the maximum overlap that we calculated
    return options["preferOverlap"]
        ? _pruneLocations(locations, maxOverlap)
        : locations;
  }

  /*
  * Determines whether or not a particular word fits in a particular
  * orientation within the puzzle.
  *
  * Returns the number of letters overlapped with existing words if the word
  * fits in the specified position, -1 if the word does not fit.
  *
  * @param {String} word: The word to fit into the puzzle.
  * @param {[[String]]} puzzle: The current state of the puzzle
  * @param {int} x: The x position to check
  * @param {int} y: The y position to check
  * @param {function} fnGetSquare: Function that returns the next square
  */
  _calcOverlap(word, puzzle, x, y, fnGetSquare) {
    var overlap = 0;

    // traverse the squares to determine if the word fits
    for (int i = 0, len = word.length; i < len; i++) {
      var next = fnGetSquare(x, y, i);
      var square = puzzle[next["y"]][next["x"]];

      // if the puzzle square already contains the letter we
      // are looking for, then count it as an overlap square
      if (square == word[i]) {
        overlap++;
      }
      // if it contains a different letter, than our word doesn't fit
      // here, return -1
      else if (square != '') {
        return -1;
      }
    }

    // if the entire word is overlapping, skip it to ensure words aren't
    // hidden in other words
    return overlap;
  }

  /*
  * If overlap maximization was indicated, this function is used to prune the
  * list of valid locations down to the ones that contain the maximum overlap
  * that was previously calculated.
  *
  * Returns the pruned set of locations.
  *
  * @param {[Location]} locations: The set of locations to prune
  * @param {int} overlap: The required level of overlap
  */
  _pruneLocations(locations, overlap) {
    var pruned = [];
    for (int i = 0, len = locations.length; i < len; i++) {
      if (locations[i]["overlap"] >= overlap) {
        pruned.add(locations[i]);
      }
    }
    return pruned;
  }

  /*
  * Places a word in the puzzle given a starting position and orientation.
  *
  * @param {[[String]]} puzzle: The current state of the puzzle
  * @param {String} word: The word to fit into the puzzle.
  * @param {int} x: The x position to check
  * @param {int} y: The y position to check
  * @param {function} fnGetSquare: Function that returns the next square
  */
  _placeWord(puzzle, word, x, y, fnGetSquare) {
    for (var i = 0, len = word.length; i < len; i++) {
      var next = fnGetSquare(x, y, i);
      puzzle[next["y"]][next["x"]] = word[i];
    }
  }

  /*
  * Generates a new word find (word search) puzzle.
  *
  * Settings:
  *
  * height: desired height of the puzzle, default: smallest possible
  * width:  desired width of the puzzle, default: smallest possible
  * orientations: list of orientations to use, default: all orientations
  * fillBlanks: true to fill in the blanks, default: true
  * maxAttempts: number of tries before increasing puzzle size, default:3
  * maxGridGrowth: number of puzzle grid increases, default:10
  * preferOverlap: maximize word overlap or not, default: true
  *
  * Returns the puzzle that was created.
  *
  * @param {[String]} words: List of words to include in the puzzle
  * @param {options} settings: The options to use for this puzzle
  * @api public
  */
  _newPuzzle(settings) {
    if (words.length == 0) {
      throw new Exception('Zero words provided');
    }
    var puzzle, attempts = 0, gridGrowths = 0, opts = settings ?? {};
    // copy and sort the words by length, inserting words into the puzzle
    // from longest to shortest works out the best
    var wordList = List<String>.from(words);
    wordList.sort((a, b) => b.length.compareTo(a.length));

    // initialize the options
    var maxWordLength = wordList[0].length;
    var options = {
      "height": opts["height"] ?? maxWordLength,
      "width": opts["width"] ?? maxWordLength,
      "orientations": opts["orientations"] ?? allOrientations,
      "fillBlanks": opts["fillBlanks"] != null ? opts["fillBlanks"] : true,
      "allowExtraBlanks":
          opts["allowExtraBlanks"] != null ? opts["allowExtraBlanks"] : true,
      "maxAttempts": opts["maxAttempts"] ?? 3,
      "maxGridGrowth":
          opts["maxGridGrowth"] != null ? opts["maxGridGrowth"] : 10,
      "preferOverlap":
          opts["preferOverlap"] != null ? opts["preferOverlap"] : true
    };

    // add the words to the puzzle
    // since puzzles are random, attempt to create a valid one up to
    // maxAttempts and then increase the puzzle size and try again
    while (puzzle == null) {
      while (puzzle == null && attempts < options["maxAttempts"]) {
        puzzle = _fillPuzzle(wordList, options);
        attempts++;
      }

      if (puzzle == null) {
        gridGrowths++;
        if (gridGrowths > options["maxGridGrowth"]) {
          throw new Exception(
              "No valid ${options["width"]}x${options["height"]} grid found and not allowed to grow more");
        }
        print(
            "No valid ${options["width"]}x${options["height"]} grid found after ${attempts - 1} attempts, trying with bigger grid");
        options["height"] += 1;
        options["width"] += 1;
        attempts = 0;
      }
    }

    // fill in empty spaces with random letters
    if (options["fillBlanks"]) {
      var lettersToAdd = [], fillingBlanksCount = 0, extraLetterGenerator;
      if (options["fillBlanks"] is Function) {
        extraLetterGenerator = options["fillBlanks"];
      } else if (options["fillBlanks"] is String) {
        lettersToAdd = options["fillBlanks"].toLowerCase().split('');
        extraLetterGenerator = () {
          var removedElement = lettersToAdd.removeLast();
          if (removedElement == null) {
            fillingBlanksCount++;
          }
          return removedElement ?? "";
        };
      } else {
        extraLetterGenerator =
            () => LETTERS[(Random().nextDouble() * LETTERS.length).floor()];
      }
      var extraLettersCount = _fillBlanks(puzzle, extraLetterGenerator);
      if (lettersToAdd.length > 0) {
        throw new Exception(
            "Some extra letters provided were not used: $lettersToAdd");
      }
      if (fillingBlanksCount > 0 && !options["allowExtraBlanks"]) {
        throw new Exception(
            "$fillingBlanksCount extra letters were missing to fill the grid");
      }
      var gridFillPercent = 100 *
          (1 - extraLettersCount / (options["width"] * options["height"]));
      print(
          "Blanks filled with $extraLettersCount random letters - Final grid is filled at $gridFillPercent%");
    }

    return puzzle;
  }

  /*
  * Wrapper around `_newPuzzle` allowing to find a solution without some words.
  *
  * @param {options} settings: The options to use for this puzzle.
  * Same as `_newPuzzle` + allowedMissingWords
  */
  newPuzzleLax(words, opts) {
    try {
      return this._newPuzzle(opts);
    } catch (e) {
      if (!opts["allowedMissingWords"]) {
        throw e;
      }
      opts = Map.from(opts);
      opts["allowedMissingWords"] -= 1;
      for (var i = 0; i < words.length; i++) {
        var wordList = words.slice(0);
        wordList.splice(i, 1);
        try {
          var puzzle = this.newPuzzleLax(wordList, opts);
          print("Solution found without word '${words[i]}'");
          return puzzle;
        } catch (e) {} // continue if error
      }
      throw e;
    }
  }

  /*
  * Fills in any empty spaces in the puzzle with random letters.
  *
  * @param {[[String]]} puzzle: The current state of the puzzle
  * @api public
  */
  _fillBlanks(puzzle, extraLetterGenerator) {
    var extraLettersCount = 0;
    for (var i = 0, height = puzzle.length; i < height; i++) {
      var row = puzzle[i];
      for (var j = 0, width = row.length; j < width; j++) {
        if (puzzle[i][j] == '') {
          puzzle[i][j] = extraLetterGenerator();
          extraLettersCount++;
        }
      }
    }
    return extraLettersCount;
  }

  /*
  * Returns the starting location and orientation of the specified words
  * within the puzzle. Any words that are not found are returned in the
  * notFound array.
  *
  * Returns
  *   x position of start of word
  *   y position of start of word
  *   orientation of word
  *   word
  *   overlap (always equal to word.length)
  *
  * @param {[[String]]} puzzle: The current state of the puzzle
  * @param {[String]} words: The list of words to find
  * @api public
  */
  solve(puzzle, words) {
    var options = {
          "height": puzzle.length,
          "width": puzzle[0].length,
          "orientations": allOrientations,
          "preferOverlap": true
        },
        found = [],
        notFound = [];

    for (var i = 0, len = words.length; i < len; i++) {
      var word = words[i],
          locations = _findBestLocations(puzzle, options, word);

      if (locations.length > 0 && locations[0].overlap == word.length) {
        locations[0].word = word;
        found.add(locations[0]);
      } else {
        notFound.add(word);
      }
    }

    return {found: found, notFound: notFound};
  }

  /*
  * Outputs a puzzle to the console, useful for debugging.
  * Returns a formatted string representing the puzzle.
  *
  * @param {[[String]]} puzzle: The current state of the puzzle
  * @api public
  */
  String toString() {
    var puzzleString = '';
    for (var i = 0, height = puzzle.length; i < height; i++) {
      var row = puzzle[i];
      for (var j = 0, width = row.length; j < width; j++) {
        puzzleString += (row[j] == '' ? ' ' : row[j]) + ' ';
      }
      puzzleString += '\n';
    }

    return puzzleString;
  }
}
