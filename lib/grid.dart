import 'package:flutter/material.dart';

class GridDrawer extends StatelessWidget {
  GridDrawer(this.grid, this.width);
  final List<GridCell> grid;
  final int width;
  int get height => grid.length ~/ width;
  Widget build(BuildContext context) {
    //print("DRW");
    return CustomPaint(
      painter: GridPainter(
        width,
        height,
        grid,
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  GridPainter(this.width, this.height, this.grid);
  final int width;
  final int height;
  final List<GridCell> grid;
  bool shouldRepaint(CustomPainter _) => true;
  void paint(Canvas canvas, Size size) {
    //print("PNT");
    double cellDim = 40;
    Size cellSize = Size(cellDim+1, cellDim+1);
    for (int y = 0; y < height; y += 1) {
      for (int x = 0; x < width; x += 1) {
        grid[x + (y * width)]
            .paint(canvas, cellSize, Offset(x * cellDim, y * cellDim));
      }
    }
  }
}

abstract class GridCell {
  void paint(Canvas canvas, Size size, Offset offset);
}

class EmptyGridCell extends GridCell {
  void paint(Canvas canvas, Size size, Offset offset) {
    canvas.drawRect(offset & size, (Paint()..color=Colors.white));
  }
}

class WallGridCell extends GridCell {
  void paint(Canvas canvas, Size size, Offset offset) {
    canvas.drawRect(offset & size, Paint()..color = Colors.brown);
  }
}

class GoalGridCell extends GridCell {
  void paint(Canvas canvas, Size size, Offset offset) {
    canvas.drawRect(offset & size, Paint()..color = Colors.grey);
    canvas.drawLine(offset+Offset(size.width/2, 0), offset+Offset(size.width/2,size.height), Paint());
  }
}

class PlayerGridCell extends GridCell {
  void paint(Canvas canvas, Size size, Offset offset) {
    canvas.drawRect(offset & size, (Paint()..color=Colors.white));
    canvas.drawOval(offset & size, Paint()..color = Colors.yellow);
  }
}

class ShadedGridCell extends GridCell {
  void paint(Canvas canvas, Size size, Offset offset) {
    canvas.drawRect(offset & size, Paint()..color = Colors.black);
  }
}