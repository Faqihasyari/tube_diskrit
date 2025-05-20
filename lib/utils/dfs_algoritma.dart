import '../models/node_model.dart';
import '../models/graph_model.dart';

class DFS {
  static void traverse(Node start, Graph graph, List<Node> visited) {
    start.visited = true;
    visited.add(start);

    for (final neighbor in graph.adjacencyList[start] ?? []) {
      if (!neighbor.visited) {
        traverse(neighbor, graph, visited);
      }
    }
  }
}
