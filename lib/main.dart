import 'dart:async';

import 'package:flutter/services.dart';

import 'grid.dart';
import 'package:flutter/material.dart';

//TODO: animation

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MyApp(
      worlds: await Future.wait(List<Future<World?>>.generate(
              3,
              (index) => World.parse(
                  rootBundle.loadString('worlds/${index + 1}.world')))) +
          [null],
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({required this.worlds});
  final List<World?> worlds;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "Robofontini",

        //textTheme: Typography.whiteMountainView,
      ),
      home: MyHomePage(
        worlds: worlds,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.worlds}) : super(key: key);

  final List<World?> worlds;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  World? get _world => worlds[worldIndex];
  List<World?> get worlds => widget.worlds;
  int worldIndex = 0;
  int textIndex = 0;
  List<String?> texts = [
    "Hello, yellow dot.",
    "I have been instructed to guide you through these stories.",
    "Use arrow keys to move, and get to the Vertical People Transporter, which looks like an elevator.",
    null,
    "Your lantern does not seem very good.",
    "You should be getting to the next Vertical People Transporter.",
    null,
    "Your lantern has been upgraded.",
    "You can now see better.",
    "This story was modeled after a certain place in the forest. I've heard you've been there.",
    null,
  ];
  bool done = false;
  bool _onKey(FocusNode node, RawKeyEvent event) {
    setState(() {
      if (event is RawKeyDownEvent && done == false) {
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) _world?.left();
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) _world?.right();
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) _world?.up();
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) _world?.down();
        if (event.logicalKey == LogicalKeyboardKey.enter &&
            texts[textIndex + 1] != null) textIndex++;
        if (_world?.cells[_world!.player] is Goal) {
          setState(() {
            done = true;
          });
          Timer(
            Duration(seconds: 2),
            () => setState(() {
              worldIndex++;
              while (texts[textIndex] != null) textIndex++;
              textIndex += 1;
              if (worldIndex == 3) _world?.view = 2;
              done = false;
            }),
          );
        }
      }
    });
    return true;
  }

  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    focusNode.requestFocus();
    return Focus(
      autofocus: false,
      onKey: _onKey,
      focusNode: focusNode,
      child: Scaffold(
        body: Container(
          color: Colors.black,
          child: Center(
            child: _world == null
                ? Text(
                    "{ The End }",
                    style: TextStyle(
                      fontFamily: "Robofontini",
                      color: Colors.white,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /*Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Enable Debug More Sight", style: TextStyle(color: Colors.white),),
                          Checkbox(
                            onChanged: (bool? value) {
                              setState(() {
                                _world!.view = value! ? 2 : 1;
                              });
                            },
                            value: _world!.view == 2,
                            fillColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.white,
                            ),
                          ),
                        ],
                      ),*/
                      done
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Text(
                                    "'Happy to transport you up!' --Vertical People Transporter",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Robofontini",
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  CircularProgressIndicator(),
                                ])
                          : RichText(
                              text: TextSpan(
                                text: texts[textIndex]!,
                                style: TextStyle(
                                  fontFamily: "Robofontini",
                                ),
                                children: [
                                  TextSpan(
                                    text: texts[textIndex + 1] == null
                                        ? ""
                                        : "  \n\n(Press <ENTER> to continue)",
                                    style: TextStyle(
                                      fontFamily: "Robofontini",
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      GridDrawer(
                        _world!.frontendWorld.list,
                        _world!.frontendWorld.w,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class World {
  World(this.cells, this.w, this.player, this.view);
  static Future<World> parse(Future<String> text) async {
    List<String> data = (await text).split('\n');
    List<RCell> parsed = [];
    int w = 0;
    int playerIndex = int.parse(data.first);
    //print("parse($to)");
    for (String line in data.toList()..removeRange(0, 1)) {
      w = 0;
      for (String char in line.split('')) {
        switch (char) {
          case ".":
            parsed.add(Empty());
            break;
          case "G":
            parsed.add(Goal());
            break;
          case "#":
            parsed.add(Wall());
            break;
          case " ":
            parsed.add(AlwaysShaded());
            break;
          default:
            throw FormatException(
                "Unexpected \"$char\"(${char.runes.first}) while parsing world");
        }
        w++;
      }
    }
    return World(
      parsed,
      w,
      playerIndex,
      1,
    );
  }

  final List<RCell> cells;
  int w = 7;
  int player = 16;
  void right() {
    if (player < cells.length - 1 && cells[player + 1].canWalk) player++;
  }

  int view;

  void left() {
    if (player > 0 && cells[player - 1].canWalk) player--;
  }

  void up() {
    if (player >= w && cells[player - w].canWalk) player -= w;
  }

  void down() {
    if (player < cells.length - w && cells[player + w].canWalk) player += w;
  }

  FrontendGridDesc get frontendWorld {
    //List<GridCell> fCells = cells.map((RCell cell) => cell.gC).toList();
    List<GridCell> fCells = List.filled(cells.length, ShadedGridCell());
    List<int> places = [];
    for (int a = -view; a < view + 1; a++) {
      for (int b = -view; b < view + 1; b++) {
        //print("$a + $w * $b ($player)");
        places.add(a + w * b);
      }
    }
    for (int place in places) {
      fCells[player + place] = cells[player + place].gC;
    }
    fCells[player] = PlayerGridCell();
    return FrontendGridDesc(w, fCells);
  }
}

abstract class RCell {
  GridCell get gC;
  bool get canWalk;
}

class Empty extends RCell {
  GridCell get gC => EmptyGridCell();
  bool get canWalk => true;
}

class Wall extends RCell {
  GridCell get gC => WallGridCell();
  bool get canWalk => false;
}

class Goal extends RCell {
  GridCell get gC => GoalGridCell();
  bool get canWalk => true;
}

class AlwaysShaded extends RCell {
  GridCell get gC => ShadedGridCell();
  bool get canWalk => false;
}

class FrontendGridDesc {
  FrontendGridDesc(this.w, this.list);
  final int w;
  final List<GridCell> list;
}
