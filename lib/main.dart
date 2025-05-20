import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tubes_diskrit/controller/map_controller.dart';
import 'app.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CovidMapController(),
      child: const App(),
    ),
  );
}
