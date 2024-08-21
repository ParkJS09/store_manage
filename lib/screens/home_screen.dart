import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mz_reservations/provider/store_provider.dart';
import 'package:mz_reservations/widgets/grid_painter.dart';
import 'package:provider/provider.dart';
import 'package:mz_reservations/models/layout_item.dart';
import 'package:mz_reservations/utils/constants.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('메인 화면')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/editor'),
            child: Text('레이아웃 편집'),
          ),
          Expanded(
            child: Consumer<StoreProvider>(
              builder: (context, layoutProvider, child) {
                List<String> sections = layoutProvider.layouts.keys.toList();
                return Column(
                  children: [
                    SectionNavigator(
                      sections: sections,
                      onSectionChanged: (section) {
                        layoutProvider.setCurrentSection(section);
                      },
                    ),
                    Expanded(
                      child: LayoutPreview(
                        items: layoutProvider
                                .getLayout(layoutProvider.currentSection) ??
                            [],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SectionNavigator extends StatefulWidget {
  final List<String> sections;
  final Function(String) onSectionChanged;

  SectionNavigator({required this.sections, required this.onSectionChanged});

  @override
  _SectionNavigatorState createState() => _SectionNavigatorState();
}

class _SectionNavigatorState extends State<SectionNavigator> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            setState(() {
              currentIndex = (currentIndex - 1 + widget.sections.length) %
                  widget.sections.length;
            });
            widget.onSectionChanged(widget.sections[currentIndex]);
          },
        ),
        Text(
          widget.sections.isNotEmpty ? widget.sections[currentIndex] : '섹션 없음',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward_ios),
          onPressed: () {
            setState(() {
              currentIndex = (currentIndex + 1) % widget.sections.length;
            });
            widget.onSectionChanged(widget.sections[currentIndex]);
          },
        ),
      ],
    );
  }
}

class LayoutPreview extends StatelessWidget {
  final List<LayoutItem> items;

  LayoutPreview({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text('이 섹션에 아이템이 없습니다.'));
    }

    double maxX = 0;
    double maxY = 0;
    for (var item in items) {
      maxX = max(maxX, item.position.dx + item.widthInGrids * GRID_SIZE);
      maxY = max(maxY, item.position.dy + item.heightInGrids * GRID_SIZE);
    }

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: EdgeInsets.all(20),
      minScale: 0.1,
      maxScale: 4,
      child: Container(
        width: maxX,
        height: maxY,
        color: Colors.grey[200],
        child: Stack(
          children: [
            CustomPaint(
              painter: GridPainter(gridSize: GRID_SIZE),
              size: Size(maxX, maxY),
            ),
            ...items
                .map((item) => Positioned(
                      left: item.position.dx,
                      top: item.position.dy,
                      child: Container(
                        width: item.widthInGrids * GRID_SIZE,
                        height: item.heightInGrids * GRID_SIZE,
                        decoration: BoxDecoration(
                          color:
                              item.type == 'table' ? Colors.brown : Colors.grey,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(
                          child: Text(
                            item.name,
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}
