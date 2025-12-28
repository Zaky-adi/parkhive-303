import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ParkingSpot {
  final String name;
  final double lat;
  final double lng;
  final int usedSlots;
  final int totalSlots;

  const ParkingSpot({
    required this.name,
    required this.lat,
    required this.lng,
    required this.usedSlots,
    required this.totalSlots,
  });
}

class MapPage extends StatefulWidget {
  static const String routeName = '/map';
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final LatLng _center = const LatLng(1.1191557, 104.0483);

  final List<ParkingSpot> _allSpots = const [
    ParkingSpot(
      name: 'Parkiran GU',
      lat: 1.119257440362752,
      lng: 104.0488456936243,
      usedSlots: 13,
      totalSlots: 20,
    ),
    ParkingSpot(
      name: 'Parkiran TA',
      lat: 1.1189901346605966,
      lng: 104.047642933095,
      usedSlots: 14,
      totalSlots: 20,
    ),
    ParkingSpot(
      name: 'Parkiran Tekno',
      lat: 1.1191557266114684,
      lng: 104.04811173177801,
      usedSlots: 18,
      totalSlots: 20,
    ),
  ];

  String? _selectedSpotName;

  /// FILTER STATE
  Set<String> _selectedAreas = {};
  double _maxDistance = 250;
  String _availability = 'semua';

  List<ParkingSpot> get _filteredSpots {
    return _allSpots.where((spot) {
      if (_selectedAreas.isNotEmpty &&
          !_selectedAreas.contains(spot.name)) {
        return false;
      }

      final distance = _calculateDistance(
        _center.latitude,
        _center.longitude,
        spot.lat,
        spot.lng,
      );

      if (distance > _maxDistance) return false;

      final ratio = spot.usedSlots / spot.totalSlots;
      if (_availability == 'tersedia' && ratio > 0.75) return false;
      if (_availability == 'hampir' && ratio <= 0.75) return false;

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            /// SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black54),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Cari lokasi parkir...',
                        style:
                            TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showFilterSheet,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.filter_list, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// MAP + LIST
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _center,
                          initialZoom: 18,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          ),
                          MarkerLayer(
                            markers: _filteredSpots.map((spot) {
                              final selected =
                                  _selectedSpotName == spot.name;
                              return Marker(
                                point:
                                    LatLng(spot.lat, spot.lng),
                                width: 50,
                                height: 50,
                                child: GestureDetector(
                                  onTap: () =>
                                      _onSpotTapped(spot),
                                  child: Icon(
                                    Icons.location_on,
                                    size: selected ? 36 : 30,
                                    color: Colors.yellow[700],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// DRAGGABLE LIST
                  DraggableScrollableSheet(
                    initialChildSize: 0.28,
                    minChildSize: 0.18,
                    maxChildSize: 0.65,
                    builder: (_, controller) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: ListView.builder(
                          controller: controller,
                          itemCount: _filteredSpots.length,
                          itemBuilder: (_, i) =>
                              _buildSpotItem(_filteredSpots[i]),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FILTER SHEET
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Parkir',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  const Text('Area Parkir'),
                  Wrap(
                    spacing: 8,
                    children: _allSpots.map((spot) {
                      return ChoiceChip(
                        label: Text(spot.name),
                        selected:
                            _selectedAreas.contains(spot.name),
                        onSelected: (v) {
                          setModal(() {
                            v
                                ? _selectedAreas.add(spot.name)
                                : _selectedAreas.remove(spot.name);
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),
                  Text('Jarak Maksimal ${_maxDistance.toInt()}m'),
                  Slider(
                    value: _maxDistance,
                    min: 50,
                    max: 500,
                    onChanged: (v) =>
                        setModal(() => _maxDistance = v),
                  ),

                  const SizedBox(height: 12),
                  const Text('Ketersediaan'),
                  Wrap(
                    spacing: 8,
                    children: [
                      _availabilityChip('semua', 'Semua', setModal),
                      _availabilityChip('tersedia', 'Tersedia', setModal),
                      _availabilityChip(
                          'hampir', 'Hampir penuh', setModal),
                    ],
                  ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: const Text('Terapkan Filter'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  ChoiceChip _availabilityChip(
      String value, String label, Function setModal) {
    return ChoiceChip(
      label: Text(label),
      selected: _availability == value,
      onSelected: (_) => setModal(() => _availability = value),
    );
  }

  void _onSpotTapped(ParkingSpot spot) {
    setState(() => _selectedSpotName = spot.name);
    _mapController.move(LatLng(spot.lat, spot.lng), 18);
  }

  Widget _buildSpotItem(ParkingSpot spot) {
    return ListTile(
      title: Text(spot.name),
      trailing: Text('${spot.usedSlots}/${spot.totalSlots}'),
      onTap: () => _onSpotTapped(spot),
    );
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _deg2rad(double deg) => deg * pi / 180;
}
