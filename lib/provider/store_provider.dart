import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mz_reservations/models/layout_item.dart';

class StoreProvider extends ChangeNotifier {
  Map<String, List<LayoutItem>> _layouts = {};
  String _currentSection = '';

  Map<String, List<LayoutItem>> get layouts => _layouts;
  String get currentSection => _currentSection;

  void setCurrentSection(String section) {
    _currentSection = section;
    notifyListeners();
  }

  void addLayout(String section, List<LayoutItem> items) {
    log('section : $section, item : ${items}');
    _layouts[section] = items;
    notifyListeners();
  }

  void updateLayout(String section, List<LayoutItem> items) {
    if (_layouts.containsKey(section)) {
      _layouts[section] = items;
      notifyListeners();
    }
  }

  List<LayoutItem>? getLayout(String section) {
    return _layouts[section];
  }
}
