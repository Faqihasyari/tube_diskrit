import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:tubes_diskrit/controller/map_controller.dart';
import 'package:tubes_diskrit/theme/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LatLng _center = LatLng(-6.7333, 108.5667); // Jakarta
  String? selectedNodeId;

  @override
  Widget build(BuildContext context) {
    final mapCtrl = Provider.of<CovidMapController>(context);

    return Scaffold(
      backgroundColor: Colors.teal[500],
      appBar: AppBar(
        backgroundColor: Colors.teal[500],
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
                  return Center(child: Text('Node belum dipilih'));
                }
                final result = mapCtrl.dfs(selectedNodeId!);
                final screenWidth = MediaQuery.of(context).size.width;
                final screenHeight = MediaQuery.of(context).size.height;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                      width: screenWidth,
                      height: screenHeight * 0.13,
                      decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          )),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.white,
                              child: Image.asset(
                                'assets/images/lokasi.png',
                                height: 48,
                                width: 48,
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Flexible(
                              child: Row(
                                children: [
                                  Text(
                                    'Kode lokasi',
                                    style: GoogleFonts.caveat(fontSize: 20),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: VerticalDivider(
                                      color: Colors.grey,
                                      thickness: 1,
                                      indent: 7,
                                      endIndent: 7,
                                      width: 0.0001,
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 100,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Text(
                                          result
                                              .map((e) => e.id.substring(0, 5))
                                              .join(', '),
                                          style: GoogleFonts.caveat(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                          softWrap: true,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                );
              },
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 7,
            endIndent: 7,
          )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(50, 0, 50, 5),
        child: ElevatedButton(
          onPressed:
              selectedNodeId != null ? () => _showEdgeDialog(mapCtrl) : null,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.location_on,
                color: Color(0xff4C7380),
              ),
              SizedBox(width: 8),
              Text(
                'Hubungkan ke node lainnya',
                style: TextStyle(color: Color(0xff4C7380)),
              ),
            ],
          ),
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
