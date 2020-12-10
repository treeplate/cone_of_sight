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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GridDrawer(_world.frontendWorld.list, _world.frontendWorld.w),
      ),
    );
  }
}

class World {
  World();
  //TODO: make world description
  FrontendGridDesc get frontendWorld => FrontendGridDesc(1, [EmptyGridCell()]); //TODO: make better grid
}

class FrontendGridDesc {
  FrontendGridDesc(this.w, this.list);
  final int w;
  final List<GridCell> list;
}