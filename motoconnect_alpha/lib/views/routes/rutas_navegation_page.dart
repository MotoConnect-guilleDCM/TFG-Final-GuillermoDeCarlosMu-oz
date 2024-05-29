import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteLoader extends StatefulWidget {
  final int routeId;

  const RouteLoader({Key? key, required this.routeId}) : super(key: key);

  @override
  _RouteLoaderState createState() => _RouteLoaderState();
}

class _RouteLoaderState extends State<RouteLoader> {
  List<LatLng> _routeCoordinates = [];
  List<LatLng> _shortRouteCoordinates = [];
  Set<Marker> _routeMarkers = {};
  late GoogleMapController _mapController;
  bool _isMapReady = false;
  MapType _mapType = MapType.satellite;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    final url = 'http://10.0.2.2:3000/api/rutas/rutas/${widget.routeId}/coordenadas';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        _routeCoordinates = data.map((coord) {
          return LatLng(coord['Latitud'], coord['Longitud']);
        }).toList();

        if (_routeCoordinates.isNotEmpty) {
          final firstMarker = Marker(
            markerId: MarkerId('firstMarker'),
            position: _routeCoordinates.first,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          );

          _routeMarkers.add(firstMarker);

          if (_routeCoordinates.length > 1) {
            final lastMarker = Marker(
              markerId: MarkerId('lastMarker'),
              position: _routeCoordinates.last,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            );

            _routeMarkers.add(lastMarker);
          }

          _routeCoordinates.removeAt(0);
          if (_routeCoordinates.isNotEmpty) {
            _routeCoordinates.removeLast();
          }
        }
      });

      if (_routeMarkers.isNotEmpty && _mapController != null) {
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_routeMarkers.first.position, 14),
        );
      }
    } else {
      print('Error al cargar las coordenadas de la ruta.');
    }
  }

  Future<void> _traceRoute() async {
    _showLoadingDialog();
    try {
      if (_routeMarkers.length >= 2) {
        final firstMarkerPosition = _routeMarkers.first.position;
        final secondMarkerPosition = _routeCoordinates.first;

        final directionsUrl =
            'https://maps.googleapis.com/maps/api/directions/json?origin=${firstMarkerPosition.latitude},${firstMarkerPosition.longitude}&destination=${secondMarkerPosition.latitude},${secondMarkerPosition.longitude}&key=AIzaSyAKgJ6GXXEbaYZsog78LLrIj0qKtyN868g';

        final response = await http.get(Uri.parse(directionsUrl));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['routes'].isNotEmpty) {
            final points = data['routes'][0]['overview_polyline']['points'];
            _shortRouteCoordinates = _decodePolyline(points);

            setState(() {});
          }
        } else {
          print('Error al obtener la ruta.');
        }
      }
    } finally {
      Navigator.of(context).pop();
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Preparando ruta...'),
            ],
          ),
        );
      },
    );
  }

  List<LatLng> _decodePolyline(String poly) {
    List<LatLng> polylineCoordinates = [];
    int index = 0, len = poly.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      LatLng position = LatLng(lat / 1E5, lng / 1E5);
      polylineCoordinates.add(position);
    }
    return polylineCoordinates;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _isMapReady = true;
    });
  }

  void _goToFirstMarker() {
    if (_mapController != null && _routeMarkers.isNotEmpty) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_routeMarkers.first.position, 16),
      );
    }
  }

  void _changeMapType() {
    setState(() {
      _mapType = _mapType == MapType.satellite
          ? MapType.terrain
          : _mapType == MapType.terrain
          ? MapType.normal
          : MapType.satellite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ruta'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(40.4168, -3.7038),
          zoom: 5,
        ),
        mapType: _mapType,
        markers: _routeMarkers,
        polylines: {
          if (_routeCoordinates.isNotEmpty)
            Polyline(
              polylineId: PolylineId('route'),
              points: _routeCoordinates,
              color: Colors.blue,
              width: 5,
            ),
          if (_shortRouteCoordinates.isNotEmpty)
            Polyline(
              polylineId: PolylineId('shortRoute'),
              points: _shortRouteCoordinates,
              color: Colors.pink,
              width: 5,
            ),
        },
        onMapCreated: _onMapCreated,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _goToFirstMarker,
            child: Icon(Icons.location_on),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _traceRoute,
            child: Icon(Icons.directions),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _changeMapType,
            child: Icon(Icons.map),
          ),
        ],
      ),
    );
  }
}
