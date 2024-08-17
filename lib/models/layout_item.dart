import 'package:flutter/material.dart';

class LayoutItem {
  final String type;
  final Offset position;
  final String id;
  final int widthInGrids;
  final int heightInGrids;
  final String name;

  LayoutItem({
    required this.type,
    required this.position,
    required this.id,
    required this.widthInGrids,
    required this.heightInGrids,
    this.name = '',
  });
}
