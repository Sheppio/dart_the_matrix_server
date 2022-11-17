import 'dart:convert';

class Cell {
  String? owner;
  int red;
  int green;
  int blue;

  Cell(
      {this.owner, required this.red, required this.green, required this.blue});

  Map<String, dynamic> toJson() => {
        if (owner != null) 'owner': owner,
        'color': base64.encode([red, green, blue]),
      };

  factory Cell.fromJson(Map<String, dynamic> json) {
    var colors = base64.decode(json['color']);
    var owner = json['owner'];
    return Cell(
        red: colors[0], green: colors[1], blue: colors[2], owner: owner);
  }
}
