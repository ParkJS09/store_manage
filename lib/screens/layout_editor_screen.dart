import 'package:flutter/material.dart';
import 'package:mz_reservations/models/layout_item.dart';
import 'package:mz_reservations/utils/constants.dart';
import 'package:mz_reservations/widgets/grid_painter.dart';

class CustomStoreLayoutEditor extends StatefulWidget {
  @override
  _CustomStoreLayoutEditorState createState() =>
      _CustomStoreLayoutEditorState();
}

class _CustomStoreLayoutEditorState extends State<CustomStoreLayoutEditor> {
  List<LayoutItem> layoutItems = [];
  String selectedItemType = 'table';
  String currentSection = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('매장 레이아웃 편집')),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: InteractiveViewer(
              boundaryMargin: EdgeInsets.all(20.0),
              minScale: 0.5,
              maxScale: 4.0,
              child: GestureDetector(
                onTapUp: (details) {
                  Offset gridPosition = _snapToGrid(details.localPosition);
                  print('Tapped at grid position: $gridPosition');
                  _showAddItemDialog(gridPosition);
                },
                child: Stack(
                  children: [
                    Container(
                      width: 2000,
                      height: 2000,
                      color: Colors.grey[200],
                      child: CustomPaint(
                        painter: GridPainter(),
                      ),
                    ),
                    ...layoutItems.map((item) => Positioned(
                          left: item.position.dx,
                          top: item.position.dy,
                          child: GestureDetector(
                            onTap: () {
                              print('Item tapped: ${item.id}');
                              _showEditItemDialog(item);
                            },
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
        int widthInGrids = 2;
        int heightInGrids = 2;
        String name = '';

        return AlertDialog(
          title: Text(selectedItemType == 'table' ? '테이블 추가' : '벽 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: '너비 (격자 단위)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => widthInGrids = int.tryParse(value) ?? 2,
              ),
              TextField(
                decoration: InputDecoration(labelText: '높이 (격자 단위)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => heightInGrids = int.tryParse(value) ?? 2,
              ),
              if (selectedItemType == 'table')
                TextField(
                  decoration: InputDecoration(labelText: '테이블 이름'),
                  onChanged: (value) => name = value,
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
                    type: selectedItemType,
                    position: position,
                    id: DateTime.now().toString(),
                    widthInGrids: widthInGrids,
                    heightInGrids: heightInGrids,
                    name: name,
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
        int widthInGrids = item.widthInGrids;
        int heightInGrids = item.heightInGrids;
        String name = item.name;

        return AlertDialog(
          title: Text(item.type == 'table' ? '테이블 수정' : '벽 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: '너비 (격자 단위)'),
                keyboardType: TextInputType.number,
                controller:
                    TextEditingController(text: widthInGrids.toString()),
                onChanged: (value) =>
                    widthInGrids = int.tryParse(value) ?? widthInGrids,
              ),
              TextField(
                decoration: InputDecoration(labelText: '높이 (격자 단위)'),
                keyboardType: TextInputType.number,
                controller:
                    TextEditingController(text: heightInGrids.toString()),
                onChanged: (value) =>
                    heightInGrids = int.tryParse(value) ?? heightInGrids,
              ),
              if (item.type == 'table')
                TextField(
                  decoration: InputDecoration(labelText: '테이블 이름'),
                  controller: TextEditingController(text: name),
                  onChanged: (value) => name = value,
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
                      type: item.type,
                      position: item.position,
                      id: item.id,
                      widthInGrids: widthInGrids,
                      heightInGrids: heightInGrids,
                      name: name,
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

  void _saveLayout() async {
    if (currentSection.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('섹션 이름을 입력해주세요.')),
      );
      return;
    }

    // final supabase = Supabase.instance.client;

    try {
      // await supabase.from('layouts').insert({
      //   'section': currentSection,
      //   'items': layoutItems
      //       .map((item) => {
      //             'type': item.type,
      //             'position_x': item.position.dx,
      //             'position_y': item.position.dy,
      //             'width_in_grids': item.widthInGrids,
      //             'height_in_grids': item.heightInGrids,
      //             'name': item.name,
      //           })
      //       .toList(),
      // });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('레이아웃이 저장되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')),
      );
    }
  }

  Offset _snapToGrid(Offset position) {
    return Offset(
      (position.dx / GRID_SIZE).round() * GRID_SIZE,
      (position.dy / GRID_SIZE).round() * GRID_SIZE,
    );
  }
}
