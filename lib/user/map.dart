import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mechconnect/user/register.dart';

class MechanicTrackingScreen extends StatefulWidget {
  final String passid;

  const MechanicTrackingScreen({super.key, required this.passid});

  @override
  State<MechanicTrackingScreen> createState() => _MechanicTrackingScreenState();
}

class _MechanicTrackingScreenState extends State<MechanicTrackingScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final Dio _dio = Dio();
  final Distance _distance = const Distance();

  Timer? _timer;

  /// USER (STATIC)
  LatLng? userLocation;

  /// AGENT (LIVE) - Could be mechanic or pickup agent
  LatLng? agentLocation;

  /// ROAD ROUTE
  List<LatLng> routePoints = [];

  /// ANIMATION
  late AnimationController _animationController;
  Animation<LatLng>? _latLngAnimation;

  /// REROUTE CONFIG
  static const double deviationThresholdMeters = 40;
  static const int rerouteCooldownSeconds = 10;
  DateTime? _lastRerouteTime;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _fetchLiveData();

    /// Poll every 4 seconds
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      _fetchLiveData();
    });
    print(widget.passid);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  /// ================= FETCH LIVE DATA =================
  Future<void> _fetchLiveData() async {
    try {
      final response = await _dio.get('$baseurl/api/user/live-location/${widget.passid}');
      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        LatLng? newAgentLocation;
        LatLng? userLoc;

        if (data['bookingType'] == 'pickup' && data['pickupAgent'] != null) {
          // Pickup booking
          newAgentLocation = LatLng(
            data['pickupAgent']['location']['lat'],
            data['pickupAgent']['location']['lng'],
          );

          userLoc = LatLng(
            data['pickupAgent']['user']['location']['lat'],
            data['pickupAgent']['user']['location']['lng'],
          );
        } else if (data['bookingType'] == 'service' && data['mechanic'] != null) {
          // Service booking
          newAgentLocation = LatLng(
            data['mechanic']['location']['lat'],
            data['mechanic']['location']['lng'],
          );

          userLoc = LatLng(
            data['mechanic']['user']['location']['lat'],
            data['mechanic']['user']['location']['lng'],
          );
        }

        if (userLocation == null && userLoc != null) {
          userLocation = userLoc;
        }

        if (newAgentLocation != null) {
          if (agentLocation == null) {
            agentLocation = newAgentLocation;
            await _fetchRoute();
            _fitMapBounds();
            setState(() {});
          } else {
            _animateMarker(agentLocation!, newAgentLocation);
          }
        }
      }
    } catch (e) {
      debugPrint('Tracking error: $e');
    }
  }

  /// ================= FETCH ROUTE =================
  Future<void> _fetchRoute() async {
    if (userLocation == null || agentLocation == null) return;

    final url =
        'https://router.project-osrm.org/route/v1/driving/'
        '${agentLocation!.longitude},${agentLocation!.latitude};'
        '${userLocation!.longitude},${userLocation!.latitude}'
        '?overview=full&geometries=geojson';

    final response = await _dio.get(url);
    final coords = response.data['routes'][0]['geometry']['coordinates'];

    routePoints = coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
  }

  /// ================= ANIMATE MARKER =================
  void _animateMarker(LatLng from, LatLng to) {
    _latLngAnimation = LatLngTween(begin: from, end: to).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() async {
        agentLocation = _latLngAnimation!.value;

        _trimRouteFromCurrentPosition(agentLocation!);
        await _rerouteIfNeeded(agentLocation!);

        setState(() {});
      });

    _animationController.forward(from: 0);
  }

  /// ================= TRIM ROUTE =================
  void _trimRouteFromCurrentPosition(LatLng currentPosition) {
    if (routePoints.length < 2) return;

    int closestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < routePoints.length; i++) {
      final d = _distance(currentPosition, routePoints[i]);
      if (d < minDistance) {
        minDistance = d;
        closestIndex = i;
      }
    }

    // Keep at least 2 points to prevent disappearing
    int buffer = 1;
    if (closestIndex - buffer > 0) {
      routePoints = routePoints.sublist(closestIndex - buffer);
    }
  }

  /// ================= CHECK DEVIATION =================
  bool _hasDeviatedFromRoute(LatLng position) {
    if (routePoints.isEmpty) return false;

    double minDistance = double.infinity;

    for (final point in routePoints) {
      final d = _distance(position, point);
      if (d < minDistance) minDistance = d;
    }

    return minDistance > deviationThresholdMeters;
  }

  /// ================= AUTO REROUTE =================
  Future<void> _rerouteIfNeeded(LatLng position) async {
    if (userLocation == null) return;

    if (_lastRerouteTime != null &&
        DateTime.now().difference(_lastRerouteTime!).inSeconds < rerouteCooldownSeconds) {
      return;
    }

    if (_hasDeviatedFromRoute(position)) {
      debugPrint('🔄 Rerouting…');

      _lastRerouteTime = DateTime.now();

      agentLocation = position;
      routePoints.clear();

      await _fetchRoute();
    }
  }

  /// ================= FIT MAP =================
  void _fitMapBounds() {
    if (userLocation == null || agentLocation == null) return;

    final bounds = LatLngBounds.fromPoints([
      userLocation!,
      agentLocation!,
    ]);

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(80),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(initialZoom: 14),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.mechconnect',
              ),

              /// 🧭 ROAD NAVIGATION
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 5,
                      color: Colors.blue,
                    ),
                  ],
                ),

              /// 📍 MARKERS
              MarkerLayer(
                markers: [
                  if (userLocation != null)
                    Marker(
                      point: userLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  if (agentLocation != null)
                    Marker(
                      point: agentLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.build_circle,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ],
          ),

          /// ================= INFO =================
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(blurRadius: 10, color: Colors.black26),
                ],
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Live Navigation",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Auto reroute & smooth tracking enabled",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
