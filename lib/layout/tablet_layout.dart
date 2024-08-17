import 'package:flutter/material.dart';
import 'package:mz_reservations/seat_grid_widget.dart';

class TabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SeatGrid(rows: 3, columns: 3);
  }
}
