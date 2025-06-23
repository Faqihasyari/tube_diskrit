import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:latlong2/latlong.dart';

class MapNode {
  final String id;
  final LatLng position;
  bool visited;

  MapNode(this.position)
      : id = const Uuid().v4(),
        visited = false;
}

class MapEdge {
  final String fromId;
  final String toId;

  MapEdge(this.fromId, this.toId);
}

class CovidMapController extends ChangeNotifier {
  final List<MapNode> _nodes = [];
  final List<MapEdge> _edges = [];

  List<MapNode> get nodes => _nodes;
  List<MapEdge> get edges => _edges;
  List<MapEdge> _dfsPath = [];

  List<MapEdge> get dfsPath => _dfsPath;

  MapNode? _lastAddedNode;

  List<MapEdge> _shortestPathEdges = [];

  List<MapEdge> get shortestPathEdges => _shortestPathEdges;

  void addNode(LatLng position) {
    final newNode = MapNode(position);
    _nodes.add(newNode);

    _lastAddedNode = newNode;
    notifyListeners();
  }

  void autoConnectPathUsingDFS(String startId, String goalId) {
    final visited = <String>{};
    final parent = <String, String>{};
    bool found = false;

    void dfs(String currentId) {
      if (found) return;
      visited.add(currentId);

      if (currentId == goalId) {
        found = true;
        return;
      }

      final neighbors = _nodes
          .where((n) => n.id != currentId && !visited.contains(n.id))
          .toList();

      for (final neighbor in neighbors) {
        parent[neighbor.id] = currentId;
        dfs(neighbor.id);
        if (found) return;
      }
    }

    dfs(startId);

    // Bangun jalur dari parent map
    final path = <String>[];
    String? current = goalId;
    while (current != null && parent.containsKey(current)) {
      path.insert(0, current);
      current = parent[current];
    }
    if (current == startId) {
      path.insert(0, startId);
    }

    // Buat edge dari jalur
    for (int i = 0; i < path.length - 1; i++) {
      _edges.add(MapEdge(path[i], path[i + 1]));
    }

    notifyListeners();
  }

  void addEdge(String fromId, String toId) {
    _edges.add(MapEdge(fromId, toId));
    notifyListeners();
  }

  void reset() {
    _nodes.clear();
    _edges.clear();
    _dfsPath.clear();
    _lastAddedNode = null;
    notifyListeners();
  }

  List<MapNode> dfs(String startId) {
    final visited = <String>{};
    final result = <MapNode>[];

    void visit(String nodeId) {
      if (!visited.contains(nodeId)) {
        visited.add(nodeId);
        final node = _nodes.firstWhere((n) => n.id == nodeId);
        result.add(node);
        final neighbors =
            _edges.where((e) => e.fromId == nodeId).map((e) => e.toId).toList();
        for (final neighborId in neighbors) {
          visit(neighborId);
        }
      }
    }

    visit(startId);
    return result;
  }
}
