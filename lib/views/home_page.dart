import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:tubes_diskrit/controller/map_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LatLng _center = LatLng(-6.1751, 106.8650); // Jakarta
  String? selectedNodeId;

  @override
  Widget build(BuildContext context) {
    final mapCtrl = Provider.of<CovidMapController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracer Covid - DFS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.route),
            onPressed: () {
              if (selectedNodeId != null) {
                final result = mapCtrl.dfs(selectedNodeId!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          "DFS mengunjungi: ${result.map((e) => e.id.substring(0, 5)).join(', ')}")),
                );
              }
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 400,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 13.0,
                onLongPress: (tapPosition, latlng) {
                  mapCtrl.addNode(latlng);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.tubes_diskrit',
                ),
                MarkerLayer(
                  markers: mapCtrl.nodes
                      .map((node) => Marker(
                            point: node.position,
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedNodeId = node.id;
                                });
                              },
                              child: Icon(
                                Icons.location_on,
                                color: node.id == selectedNodeId
                                    ? Colors.green
                                    : Colors.red,
                                size: 36,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                PolylineLayer(
                  polylines: mapCtrl.edges.map((edge) {
                    final from =
                        mapCtrl.nodes.firstWhere((n) => n.id == edge.fromId);
                    final to =
                        mapCtrl.nodes.firstWhere((n) => n.id == edge.toId);
                    return Polyline(
                      points: [from.position, to.position],
                      strokeWidth: 4,
                      color: Colors.blue,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Builder(
              builder: (context) {
                if (selectedNodeId == null) {
                  return const Text('Node belum dipilih');
                }
                final result = mapCtrl.dfs(selectedNodeId!);
                return Container(
                    child: Text(
                        result.map((e) => e.id.substring(0, 5)).join(', ')));
              },
            ),
          )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed:
              selectedNodeId != null ? () => _showEdgeDialog(mapCtrl) : null,
          child: const Text("Hubungkan Node ke Lainnya"),
        ),
      ),
    );
  }

  void _showEdgeDialog(CovidMapController mapCtrl) {
    showDialog(
      context: context,
      builder: (context) {
        final otherNodes =
            mapCtrl.nodes.where((n) => n.id != selectedNodeId).toList();
        String? selectedTarget;

        return AlertDialog(
          title: const Text("Pilih Node Tujuan"),
          content: DropdownButtonFormField<String>(
            items: otherNodes
                .map((n) => DropdownMenuItem(
                    value: n.id, child: Text(n.id.substring(0, 5))))
                .toList(),
            onChanged: (val) => selectedTarget = val,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (selectedTarget != null && selectedNodeId != null) {
                  mapCtrl.addEdge(selectedNodeId!, selectedTarget!);
                  Navigator.pop(context);
                }
              },
              child: const Text("Hubungkan"),
            )
          ],
        );
      },
    );
  }
}
