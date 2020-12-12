import 'package:flutter/services.dart';

import 'grid.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final World _world = World();
  void _onKey(RawKeyEvent event) {
    setState(() {
      if(event is RawKeyDownEvent) {
      if(event.logicalKey == LogicalKeyboardKey.arrowLeft) _world.left();
      if(event.logicalKey == LogicalKeyboardKey.arrowRight) _world.right();
      if(event.logicalKey == LogicalKeyboardKey.arrowUp) _world.up();
      if(event.logicalKey == LogicalKeyboardKey.arrowDown) _world.down();
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
        body: Center(
          child: GridDrawer(_world.frontendWorld.list, _world.frontendWorld.w),
        ),
      ),
    );
  }
}

class World {
  World();
  List<RCell> cells = [Wall(), Wall(), Empty(), Empty(), Wall(), Wall(), Empty(), Wall(), Empty(), Empty(), Wall(), Wall()];
  int w = 3;
  int player = 2;
  void right() {
    if (player < cells.length-1 && cells[player + 1].canWalk) player++;
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
    List<GridCell> fCells = cells.map((RCell cell) => cell.gC).toList();
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

class FrontendGridDesc {
  FrontendGridDesc(this.w, this.list);
  final int w;
  final List<GridCell> list;
}
