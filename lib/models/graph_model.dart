import 'node_model.dart';

class Graph {
  final Map<Node, List<Node>> adjacencyList = {};

  void addNode(Node node) {
    adjacencyList[node] = [];
  }

  void addEdge(Node a, Node b) {
    adjacencyList[a]?.add(b);
  }
}
