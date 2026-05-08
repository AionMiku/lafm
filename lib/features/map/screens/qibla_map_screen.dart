import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';

class QiblaMapScreen extends StatefulWidget {
  const QiblaMapScreen({super.key});

  @override
  State<QiblaMapScreen> createState() => _QiblaMapScreenState();
}

class _QiblaMapScreenState extends State<QiblaMapScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  double _distanceToKaaba = 0;
  String _locationStatus = "Determining Location...";

  // Kaaba Coordinates
  final LatLng _kaabaPos = const LatLng(21.4225, 39.8262);

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _locationStatus = "GPS Disabled");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _locationStatus = "Permission Denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _locationStatus = "Permission Denied Permanently");
      return;
    }

    try {
      // 1. Instantly Check Cache / Last Known Position
      Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && mounted) {
        setState(() {
          _currentPosition = lastKnown;
          _distanceToKaaba = Geolocator.distanceBetween(
            lastKnown.latitude, lastKnown.longitude,
            _kaabaPos.latitude, _kaabaPos.longitude,
          ) / 1000;
        });
        _fitBounds();
      }

      // 2. Fetch fresh online position in background
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _distanceToKaaba = Geolocator.distanceBetween(
            position.latitude, position.longitude,
            _kaabaPos.latitude, _kaabaPos.longitude,
          ) / 1000;
        });
        _fitBounds();
      }
    } catch (_) {
      if (mounted && _currentPosition == null) {
        setState(() => _locationStatus = "Unable to find location. Unreachable.");
      }
    }
  }

  void _fitBounds() {
    if (_currentPosition == null) return;
    
    LatLng userPos = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    final bounds = LatLngBounds.fromPoints([userPos, _kaabaPos]);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50.0)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Qibla & Location')),
      body: Column(
        children: [
          // TOP HALF: BORDERED MAP
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                // If location is null, show placeholder map text
                child: _currentPosition == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map, size: 48, color: theme.dividerColor),
                            const SizedBox(height: 16),
                            Text(
                              _locationStatus,
                              style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                            ),
                            const SizedBox(height: 8),
                            const CircularProgressIndicator(strokeWidth: 2),
                          ],
                        ),
                      )
                    : FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                          initialZoom: 4, // More zoomed out to see both initially
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.lafm_app',
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [
                                  LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                  _kaabaPos,
                                ],
                                color: theme.colorScheme.primary.withOpacity(0.7),
                                strokeWidth: 3.0,
                              ),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                width: 36,
                                height: 36,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.blueAccent, width: 2),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                                    ],
                                    image: const DecorationImage(
                                      image: NetworkImage('https://ui-avatars.com/api/?name=User&background=0D8ABC&color=fff'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Marker(
                                point: _kaabaPos,
                                width: 40,
                                height: 40,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.green, width: 2),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                                    ],
                                    image: const DecorationImage(
                                      image: NetworkImage('https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?auto=format&fit=crop&q=80&w=150'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ),
          
          // BOTTOM HALF: INFO CONTAINERS
          Expanded(
            flex: 6,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // ROW: DISTANCE & COMPASS
                SizedBox(
                  height: 140,
                  child: Row(
                    children: [
                      Expanded(child: _buildDistanceCard(theme)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildCompassCard(theme)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // NEW DEALS BOX (always visible if they loaded)
                _buildDealsCard(theme),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mosque, size: 24, color: Colors.green),
          ),
          const SizedBox(height: 12),
          Text(
            "To Kaaba",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            _currentPosition == null ? "Calculating..." : "${_distanceToKaaba.toStringAsFixed(1)} KM",
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: _currentPosition == null ? 14 : 18,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompassCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          double? direction = snapshot.data?.heading;

          // Non-blocking placeholder if location isn't fetched yet or compass is waiting
          if (_currentPosition == null || snapshot.connectionState == ConnectionState.waiting) {
            return _CompassPlaceholder(theme: theme);
          }

          if (snapshot.hasError || direction == null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Sensor Error", style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600)),
                const Spacer(),
                Icon(Icons.explore_off, size: 60, color: Colors.grey.shade300),
                const Spacer(),
              ],
            );
          }
          
          final lat1 = _currentPosition!.latitude * math.pi / 180;
          final lon1 = _currentPosition!.longitude * math.pi / 180;
          final lat2 = _kaabaPos.latitude * math.pi / 180;
          final lon2 = _kaabaPos.longitude * math.pi / 180;

          final dLon = lon2 - lon1;
          final y = math.sin(dLon) * math.cos(lat2);
          final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
          
          double qiblaBearing = math.atan2(y, x) * 180 / math.pi;
          qiblaBearing = (qiblaBearing + 360) % 360; 
          
          final qiblaRotation = ((qiblaBearing - direction) * math.pi / 180);

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Qibla: ${qiblaBearing.toStringAsFixed(1)}°",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: (direction * (math.pi / 180) * -1),
                    child: Icon(Icons.explore_outlined, size: 65, color: Colors.grey.shade300),
                  ),
                  Transform.rotate(
                    angle: qiblaRotation,
                    child: const Icon(Icons.navigation, size: 30, color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Nearly Accurate",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontStyle: FontStyle.italic),
              ),
              const Spacer(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDealsCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        image: DecorationImage(
          image: const NetworkImage('https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?auto=format&fit=crop&w=800&q=80'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.65), BlendMode.darken),
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "PROMOTED",
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Travel & Tours",
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            "Book Flights to Mecca",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Exclusive deals for Umrah & Hajj bookings. Find the best affordable packages.",
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("View Deals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          )
        ],
      ),
    );
  }
}

class _CompassPlaceholder extends StatelessWidget {
  final ThemeData theme;
  
  const _CompassPlaceholder({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Calibrating...",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        SizedBox(
          height: 65,
          width: 65,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.explore_outlined, size: 65, color: Colors.grey.shade300),
              const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Please wait",
          style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontStyle: FontStyle.italic),
        ),
        const Spacer(),
      ],
    );
  }
}
