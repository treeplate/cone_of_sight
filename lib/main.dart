import 'dart:async';

import 'package:flutter/services.dart';

import 'grid.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(
      worlds: await Future.wait(List<Future<World?>>.generate(
              1,
              (index) => World.parse(
                  rootBundle.loadString('worlds/${index + 1}.world')))) +
          [null]));
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
  bool done = false;
  void _onKey(RawKeyEvent event) {
    setState(() {
      if (event is RawKeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) _world?.left();
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) _world?.right();
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) _world?.up();
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) _world?.down();
        if (_world?.cells[_world!.player] is Goal) {
          setState(() {
            done = true;
          });
          Timer(
            Duration(seconds: 2),
            () => setState(() => worldIndex++),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      onKey: _onKey,
      autofocus: true,
      focusNode: FocusNode(),
      child: Scaffold(
        body: Container(
          color: Colors.black,
          child: Center(
            child: _world == null
                ? Text(
                    "You Won (for now)!",
                    style: TextStyle(color: Colors.white),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      done
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Text(
                                    "Climbing the Vertical People Transporter",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  CircularProgressIndicator(),
                                ])
                          : Text(
                              "Get to the Vertical People Transporter.",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                      GridDrawer(
                          _world!.frontendWorld.list, _world!.frontendWorld.w),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class World {
  World(this.cells, this.w, this.player);
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
          case " ":
            parsed.add(Empty());
            break;
          case "G":
            parsed.add(Goal());
            break;
          case "#":
            parsed.add(Wall());
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
    );
  }

  final List<RCell> cells;
  int w = 7;
  int player = 16;
  void right() {
    if (player < cells.length - 1 && cells[player + 1].canWalk) player++;
  }

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
    fCells[player] = PlayerGridCell();
    fCells[player + 1] = cells[player + 1].gC;
    fCells[player - 1] = cells[player - 1].gC;
    fCells[player + w] = cells[player + w].gC;
    fCells[player - w] = cells[player - w].gC;
    fCells[player + w + 1] = cells[player + w + 1].gC;
    fCells[player - w + 1] = cells[player - w + 1].gC;
    fCells[player + w - 1] = cells[player + w - 1].gC;
    fCells[player - w - 1] = cells[player - w - 1].gC;
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

class FrontendGridDesc {
  FrontendGridDesc(this.w, this.list);
  final int w;
  final List<GridCell> list;
}
