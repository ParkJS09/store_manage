import 'package:flutter/material.dart';
import 'package:mz_reservations/provider/store_provider.dart';
import 'package:provider/provider.dart';
import 'package:mz_reservations/models/layout_item.dart';
import 'package:mz_reservations/utils/constants.dart';
import 'package:mz_reservations/widgets/grid_painter.dart';
import 'dart:math' as math;

class CustomStoreLayoutEditor extends StatefulWidget {
  @override
  _CustomStoreLayoutEditorState createState() =>
      _CustomStoreLayoutEditorState();
}

class _CustomStoreLayoutEditorState extends State<CustomStoreLayoutEditor> {
  List<LayoutItem> layoutItems = [];
  String selectedItemType = 'table';
  String currentSection = '';
  TransformationController _transformationController =
      TransformationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('매장 레이아웃 편집')),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: InteractiveViewer(
              transformationController: _transformationController,
              boundaryMargin: EdgeInsets.all(20.0),
              minScale: 0.5,
              maxScale: 4.0,
              child: GestureDetector(
                onTapUp: (details) {
                  final Offset gridPosition =
                      _getGridPosition(details.localPosition);
                  _showAddItemDialog(gridPosition);
                },
                child: Stack(
                  children: [
                    Container(
                      width: 2000,
                      height: 2000,
                      color: Colors.grey[200],
                      child: CustomPaint(
                        painter: GridPainter(gridSize: GRID_SIZE),
                      ),
                    ),
                    ...layoutItems.map((item) => Positioned(
                          left: item.position.dx,
                          top: item.position.dy,
                          child: GestureDetector(
                            onTap: () => _showEditItemDialog(item),
                            child: _buildItem(item),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[300],
              child: Column(
                children: [
                  ListTile(
                    title: Text('테이블'),
                    selected: selectedItemType == 'table',
                    onTap: () => setState(() => selectedItemType = 'table'),
                  ),
                  ListTile(
                    title: Text('벽'),
                    selected: selectedItemType == 'wall',
                    onTap: () => setState(() => selectedItemType = 'wall'),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: '섹션 이름',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) =>
                          setState(() => currentSection = value),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveLayout,
                    child: Text('레이아웃 저장'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(LayoutItem item) {
    return Container(
      width: item.widthInGrids * GRID_SIZE,
      height: item.heightInGrids * GRID_SIZE,
      decoration: BoxDecoration(
        color: item.type == 'table' ? Colors.brown : Colors.grey,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Center(
        child: Text(
          item.type == 'table' ? item.name : '벽',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showAddItemDialog(Offset position) {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        int widthInGrids = 2;
        int heightInGrids = 2;

        return AlertDialog(
          title: Text('아이템 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: '이름'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: '너비'),
                keyboardType: TextInputType.number,
                onChanged: (value) => widthInGrids = int.tryParse(value) ?? 2,
              ),
              TextField(
                decoration: InputDecoration(labelText: '높이'),
                keyboardType: TextInputType.number,
                onChanged: (value) => heightInGrids = int.tryParse(value) ?? 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  layoutItems.add(LayoutItem(
                    id: DateTime.now().toString(),
                    type: selectedItemType,
                    name: name,
                    position: position,
                    widthInGrids: widthInGrids,
                    heightInGrids: heightInGrids,
                  ));
                });
                Navigator.of(context).pop();
              },
              child: Text('추가'),
            ),
          ],
        );
      },
    );
  }

  void _showEditItemDialog(LayoutItem item) {
    showDialog(
      context: context,
      builder: (context) {
        String name = item.name;
        int widthInGrids = item.widthInGrids;
        int heightInGrids = item.heightInGrids;

        return AlertDialog(
          title: Text('아이템 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: '이름'),
                controller: TextEditingController(text: name),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: '너비'),
                keyboardType: TextInputType.number,
                controller:
                    TextEditingController(text: widthInGrids.toString()),
                onChanged: (value) =>
                    widthInGrids = int.tryParse(value) ?? widthInGrids,
              ),
              TextField(
                decoration: InputDecoration(labelText: '높이'),
                keyboardType: TextInputType.number,
                controller:
                    TextEditingController(text: heightInGrids.toString()),
                onChanged: (value) =>
                    heightInGrids = int.tryParse(value) ?? heightInGrids,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  int index = layoutItems
                      .indexWhere((element) => element.id == item.id);
                  if (index != -1) {
                    layoutItems[index] = LayoutItem(
                      id: item.id,
                      type: item.type,
                      name: name,
                      position: item.position,
                      widthInGrids: widthInGrids,
                      heightInGrids: heightInGrids,
                    );
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text('수정'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  layoutItems.removeWhere((element) => element.id == item.id);
                });
                Navigator.of(context).pop();
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  void _saveLayout() {
    if (currentSection.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('섹션 이름을 입력해주세요.')),
      );
      return;
    }

    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    storeProvider.addLayout(currentSection, List.from(layoutItems));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('레이아웃이 저장되었습니다.')),
    );

    Navigator.pop(context); // 메인 화면으로 돌아가기
  }

  Offset _getGridPosition(Offset localPosition) {
    final Matrix4 matrix = _transformationController.value;

    final double scale = math.sqrt(matrix.entry(0, 0) * matrix.entry(0, 0) +
        matrix.entry(0, 1) * matrix.entry(0, 1));
    final double dx = (localPosition.dx - matrix.entry(0, 3)) / scale;
    final double dy = (localPosition.dy - matrix.entry(1, 3)) / scale;
    return _snapToGrid(Offset(dx, dy));
  }

  Offset _snapToGrid(Offset position) {
    return Offset(
      (position.dx / GRID_SIZE).round() * GRID_SIZE,
      (position.dy / GRID_SIZE).round() * GRID_SIZE,
    );
  }
}
