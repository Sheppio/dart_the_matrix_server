import 'dart:convert';
import 'dart:math';

//import 'package:dio/dio.dart';
//import 'package:flutter/foundation.dart';
//import 'package:flutter/material.dart';
import 'package:color/color.dart';
import 'package:riverpod/riverpod.dart';

import '../models/cell.dart';
//import 'package:image/image.dart' as image;

//part 'items_repository_riverpod.g.dart';

// @riverpod
// ItemsRepositoryRiverpod itemsRepositoryRiverpod(
//     ItemsRepositoryRiverpodRef ref) {
//   debugPrint('boohoo arse');
//   return ItemsRepositoryRiverpod(
//     sharedPreferences:
//         ref.read(sharedPreferencesProvider), // a constant defined elsewhere
//   );
// }

final boardRepositoryRiverpodProvider =
    NotifierProvider<BoardRepository, List<List<Cell>>>(BoardRepository.new);

class BoardRepository extends Notifier<List<List<Cell>>> {
  ItemsRepositoryRiverpod() {
    print('BoardRepository constrctor called.');
  }

  var cols = 16;
  var rows = 16;

  var board = [<Cell>[]];
  late List<Color> primaryColors;

  @override
  List<List<Cell>> build() {
    print('BoardRepository build() called.');
    primaryColors = generatePrimaryColors();
    board = List.generate(
        cols, (i) => List.filled(rows, Cell(red: 224, green: 224, blue: 224)),
        growable: false);
    return board;
  }

  String getBoardJson() {
    return jsonEncode(board);
  }

  List<List<Cell>> getBoardFromJson(String json) {
    var x = jsonDecode(json);
    var nb = [<Cell>[]];
    for (int c = 0; c < x.length; c++) {
      nb.add(<Cell>[]);
      for (int r = 0; r < x[c].length; r++) {
        nb[c].add(Cell.fromJson(x[c][r]));
      }
    }
    return board;
  }

  List<Color> generatePrimaryColors() {
    var colorsRequired = 6;
    var colors = <Color>[];
    for (var i = 0; i < colorsRequired; i++) {
      colors.add(Color.hsv(i * (360 / colorsRequired), 100, 100));
      print(colors[i].toString());
    }
    return colors;
  }

  _refreshState() {
    print("_refreshState() called");
    // items.forEach(((element) {
    //   print(element.toJson());
    // }));
    state = List<List<Cell>>.from(board);
  }

  setCell(int colIndex, int rowIndex, Cell cell) async {
    _setCell(colIndex, rowIndex, cell);
    _refreshState();
    var remoteCell = await _remoteSetCell(colIndex, rowIndex, cell);
    if (remoteCell != cell) {
      _setCell(colIndex, rowIndex, remoteCell);
      _refreshState();
    }
    ;
  }

  _setCell(int colIndex, int rowIndex, Cell cell) {
    board[colIndex][rowIndex] = cell;
  }

  Future<Cell> _remoteSetCell(int colIndex, int rowIndex, Cell cell) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var rnd = Random();
    return rnd.nextDouble() < 0.5
        ? cell
        : Cell(
            red: rnd.nextInt(255),
            green: rnd.nextInt(255),
            blue: rnd.nextInt(255));
  }

  loadRandomPhoto() async {
    throw Exception('loadRandomPhoto() not implemented');
    // try {
    //   Response<List<int>> rs;
    //   rs = await Dio().get<List<int>>(
    //     'https://picsum.photos/200',
    //     options: Options(
    //         responseType: ResponseType.bytes), // set responseType to `bytes`
    //   );
    //   var imageFile = rs.data!;
    //   var pic = image.decodeImage(imageFile);
    //   pic = image.copyResize(pic!, width: cols, height: rows);
    //   for (var r = 0; r < rows; r++) {
    //     for (int c = 0; c < cols; c++) {
    //       _setCell(c, r, Color(pic.getPixel(c, r)));
    //     }
    //   }
    // } catch (e) {
    //   print(e);
    // }
  }
}
