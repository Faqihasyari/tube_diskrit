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

  void addNode(LatLng position) {
    _nodes.add(MapNode(position));
    notifyListeners();
  }

  void addEdge(String fromId, String toId) {
    _edges.add(MapEdge(fromId, toId));
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
