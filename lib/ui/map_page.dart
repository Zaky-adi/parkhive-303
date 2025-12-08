import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'theme.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  static const LatLng _initialCenter =
      LatLng(1.1187269140088045, 104.04845278125411);
  static const double _initialZoom = 15;

  double _maxDistance = 250;
  String _availability = "semua";

  final List<_ParkingSpot> _spots = const [
    _ParkingSpot(
      name: 'Parkiran TA',
      status: '13/20',
      position: LatLng(1.1190137727259728, 104.04758294075532),
      desc: 'Parkiran TA • 13 terpakai dari 20 slot',
    ),
    _ParkingSpot(
      name: 'Parkiran GU Mobil',
      status: '14/20',
      position: LatLng(1.118830698462618, 104.0490094371955),
      desc: 'Parkiran Mobil Gedung Utama • 14 terpakai dari 20 slot',
    ),
    _ParkingSpot(
      name: 'Parkiran GU Motor',
      status: '15/20',
      position: LatLng(1.1192639127290753, 104.0488446401779),
      desc: 'Parkiran Motor Gedung Utama • 15 terpakai dari 20 slot',
    ),
  ];

  // ✅ OPEN FILTER SHEET
  void _openFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => _buildFilterSheet(),
    );
  }

  // ✅ FILTER BOTTOM SHEET
  Widget _buildFilterSheet() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Filter Parkir",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              Icon(Icons.close),
            ],
          ),

          const SizedBox(height: 4),
          const Text("Temukan parkir sesuai kebutuhanmu",
              style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 20),

          Row(
            children: const [
              Icon(Icons.location_on_outlined, color: Colors.amber),
              SizedBox(width: 6),
              Text("Area Parkir",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),

          const SizedBox(height: 12),
          _areaItem("Parkiran GU", 2),
          _areaItem("Parkiran TA", 1),
          _areaItem("Parkiran TA samping", 1),

          const SizedBox(height: 20),

          Row(
            children: [
              const Icon(Icons.swap_calls_rounded, color: Colors.amber),
              const SizedBox(width: 6),
              const Text("Jarak Maksimal",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text("${_maxDistance.toInt()}m",
                  style: const TextStyle(
                      color: Colors.amber, fontWeight: FontWeight.bold)),
            ],
          ),

          Slider(
            value: _maxDistance,
            min: 50,
            max: 500,
            activeColor: Colors.amber,
            onChanged: (v) => setState(() => _maxDistance = v),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("50m"), Text("500m"),
            ],
          ),

          const SizedBox(height: 20),
          const Text("Ketersediaan",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          Row(
            children: [
              _availabilityButton("semua"),
              const SizedBox(width: 8),
              _availabilityButton("tersedia"),
              const SizedBox(width: 8),
              _availabilityButton("hampir penuh"),
            ],
          ),

          const SizedBox(height: 26),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _availability = "semua";
                      _maxDistance = 250;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Reset"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red),
                  child: const Text("Terapkan filter"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _areaItem(String name, int count) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text("$count",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _availabilityButton(String value) {
    final active = _availability == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _availability = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.amber : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: active ? Colors.amber : AppColors.cardBorder),
          ),
          child: Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : Colors.black)),
        ),
      ),
    );
  }

  // ✅ Marker icon
  Widget _markerIcon() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.cardBorder, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: const Icon(Icons.local_parking, size: 26, color: Colors.blue),
    );
  }

  void _onTapSpot(BuildContext context, _ParkingSpot spot) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3)))),

            const SizedBox(height: 16),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_parking,
                      size: 28, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(spot.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(spot.status,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                )
              ],
            ),

            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(spot.desc,
                  style: const TextStyle(color: Colors.black54)),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.grey[300]),
              child: const Text("Tutup",
                  style: TextStyle(color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }

  // ✅ Spot list item
  Widget _spotCardItem(_ParkingSpot s) {
    return InkWell(
      onTap: () => _onTapSpot(context, s),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(s.name),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                  color: AppColors.yellow,
                  borderRadius: BorderRadius.circular(6)),
              child: Text(s.status,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            )
          ],
        ),
      ),
    );
  }

  // ✅ FINAL UI (NO BOTTOM NAV HERE!)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,

      body: SafeArea(
        child: Stack(
          children: [
            // ✅ MAP + SEARCH
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3))
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(Icons.search, color: Colors.black45),
                        const SizedBox(width: 8),
                        const Expanded(
                            child: Text("Cari lokasi parkir...",
                                style: TextStyle(color: Colors.black54))),
                        IconButton(
                          onPressed: _openFilter,
                          icon: const Icon(Icons.filter_alt_rounded),
                        )
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                        initialCenter: _initialCenter,
                        initialZoom: _initialZoom),
                    children: [
                      TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                      MarkerLayer(
                        markers: _spots
                            .map((s) => Marker(
                                  width: 50,
                                  height: 50,
                                  point: s.position,
                                  child: GestureDetector(
                                      onTap: () => _onTapSpot(context, s),
                                      child: _markerIcon()),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ✅ CARD Spot parkir di peta
            Positioned(
              left: 12,
              right: 12,
              bottom: 20, // DIATAS bottom navigation luar
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4))
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Spot parkir di peta",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    ..._spots.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _spotCardItem(s),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// MODEL
class _ParkingSpot {
  final String name;
  final String status;
  final LatLng position;
  final String desc;

  const _ParkingSpot({
    required this.name,
    required this.status,
    required this.position,
    required this.desc,
  });
}
