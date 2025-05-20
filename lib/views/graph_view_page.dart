import 'package:flutter/material.dart';
import 'package:tubes_diskrit/controller/graph_controller.dart';

class GraphViewPage extends StatelessWidget {
  final GraphController controller;

  const GraphViewPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil DFS')),
      body: ListView.builder(
        itemCount: controller.visitedNodes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(controller.visitedNodes[index].name),
          );
        },
      ),
    );
  }
}
