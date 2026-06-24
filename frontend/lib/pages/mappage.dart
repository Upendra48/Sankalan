import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:trash_map/bin/bin_fetch.dart';
import 'package:trash_map/bin/bin_map.dart';

class MapScreen extends StatefulWidget {
  final double? targetLat;
  final double? targetLng;

  const MapScreen({super.key, this.targetLat, this.targetLng});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Future<List<Bin>> futureBins;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  
  List<LatLng> routePoints = [];
  bool showRoute = false;
  double totalDistance = 0.0;
  bool loadingRoute = false;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    futureBins = fetchBins();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    // Check for target coordinates to automatically pan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.targetLat != null && widget.targetLng != null) {
        _mapController.move(LatLng(widget.targetLat!, widget.targetLng!), 18.0);
      }
    });
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.targetLat != null && widget.targetLng != null &&
        (widget.targetLat != oldWidget.targetLat || widget.targetLng != oldWidget.targetLng)) {
      _mapController.move(LatLng(widget.targetLat!, widget.targetLng!), 18.0);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _toggleRoute() async {
    if (showRoute) {
      setState(() {
        showRoute = false;
        routePoints.clear();
        totalDistance = 0.0;
      });
      return;
    }

    setState(() {
      loadingRoute = true;
    });

    try {
      double defaultLat = 28.261336;
      double defaultLng = 83.971944;
      
      OptimizedRoute routeData = await fetchOptimizedRoute(defaultLat, defaultLng);
      
      if (!mounted) return;
      
      List<LatLng> points = [LatLng(defaultLat, defaultLng)];
      for (var bin in routeData.route) {
        points.add(LatLng(bin.latitude, bin.longitude));
      }

      setState(() {
        routePoints = points;
        totalDistance = routeData.totalDistance;
        showRoute = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Optimized Route calculated: ${routeData.route.length} bins, ${routeData.totalDistance} km"),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching optimized route: $e"),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      setState(() {
        loadingRoute = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Waste Bin Console',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          if (loadingRoute)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: ElevatedButton.icon(
                onPressed: _toggleRoute,
                icon: Icon(
                  showRoute ? Icons.close : Icons.navigation_outlined,
                  size: 18,
                ),
                label: Text(
                  showRoute ? 'Clear (${totalDistance}km)' : 'Optimize Route',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: showRoute ? Colors.red : const Color(0xFF059669),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: FutureBuilder<List<Bin>>(
        future: futureBins,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading bins'));
          } else {
            final allBins = snapshot.data!;
            final filteredBins = allBins.where((bin) {
              return bin.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                     bin.fillLevel.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            if (isDesktop) {
              return Row(
                children: [
                  // Sidebar Bin Console list
                  Container(
                    width: 320,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(right: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: "Search waste bins...",
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () => _searchController.clear(),
                                    )
                                  : null,
                              filled: true,
                              fillColor: const Color(0xFFF1F5F9),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: filteredBins.isEmpty
                              ? const Center(
                                  child: Text(
                                    "No bins match your query",
                                    style: TextStyle(color: Color(0xFF94A3B8)),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredBins.length,
                                  itemBuilder: (context, index) {
                                    final bin = filteredBins[index];
                                    Color levelColor = bin.fillLevel == 'Empty'
                                        ? const Color(0xFF059669)
                                        : bin.fillLevel == 'Half-Filled'
                                            ? Colors.amber
                                            : Colors.red;
                                    return ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      leading: CircleAvatar(
                                        radius: 6,
                                        backgroundColor: levelColor,
                                      ),
                                      title: Text(
                                        bin.name,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                      ),
                                      subtitle: Text(
                                        "Status: ${bin.fillLevel}",
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                      ),
                                      onTap: () {
                                        _mapController.move(LatLng(bin.latitude, bin.longitude), 18.0);
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Main Map panel
                  Expanded(
                    child: BinMap(
                      bins: allBins,
                      routePoints: showRoute ? routePoints : null,
                      mapController: _mapController,
                    ),
                  ),
                ],
              );
            } else {
              // Mobile layout: Stack view with overlay search bar
              return Stack(
                children: [
                  BinMap(
                    bins: allBins,
                    routePoints: showRoute ? routePoints : null,
                    mapController: _mapController,
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: "Search bins...",
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          }
        },
      ),
    );
  }
}
