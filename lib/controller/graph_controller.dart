import 'package:tubes_diskrit/utils/dfs_algoritma.dart';

import '../models/graph_model.dart';
import '../models/node_model.dart';

class GraphController {
  final graph = Graph();
  final visitedNodes = <Node>[];

  void setup() {
    // Contoh data dummy
    var a = Node("A");
    var b = Node("B");
    var c = Node("C");

    graph.addNode(a);
    graph.addNode(b);
    graph.addNode(c);

    graph.addEdge(a, b);
    graph.addEdge(a, c);
  }

  void startDFS(Node start) {
    visitedNodes.clear();
    DFS.traverse(start, graph, visitedNodes);
  }
}
