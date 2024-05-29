import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoutePlannerPage extends StatefulWidget {
  const RoutePlannerPage({Key? key}) : super(key: key);

  @override
  _RoutePlannerPageState createState() => _RoutePlannerPageState();
}

class _RoutePlannerPageState extends State<RoutePlannerPage> {
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  List<LatLng> _polylineCoordinates = [];
  Polyline? _polyline;
  bool _isLoading = true;
  TextEditingController _rutaController = TextEditingController();
  TextEditingController _descripcionController = TextEditingController();
  String? _selectedTipoMoto;
  List<String> _tipoMotoOptions = [];

  final LatLng _fixedLocation = LatLng(42.46980421526713, -2.429245928938415);

  @override
  void initState() {
    super.initState();
    _setFixedLocation();
    _fetchTipoMotoOptions().then((options) {
      setState(() {
        _tipoMotoOptions = options;
      });
    }).catchError((error) {
      _mostrarMensaje(context, 'Error al cargar los tipos de moto: $error');
    });
  }

  Future<List<String>> _fetchTipoMotoOptions() async {
    try {
      final response =
      await http.get(Uri.parse('http://10.0.2.2:3000/api/moto/types'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      } else {
        throw Exception('Error al cargar los tipos de moto');
      }
    } catch (e) {
      throw Exception('Error al cargar los tipos de moto: $e');
    }
  }

  void _setFixedLocation() {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('fixed_location'),
          position: _fixedLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: '¡Estás aquí!'),
          draggable: false,
        ),
      );
      _isLoading = false;
    });
  }

  void _moveToFixedLocation() {
    if (_mapController != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          _fixedLocation,
          15.0,
        ),
      );
    }
  }

  void _addMarker(LatLng position) {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        infoWindow: InfoWindow(title: 'Marker at ${position.latitude}, ${position.longitude}'),
        onTap: () {
          _removeMarker(position);
        },
      ));
    });
    _createRoute();
  }

  void _removeMarker(LatLng position) {
    setState(() {
      if (position != _fixedLocation) {
        _markers.removeWhere((marker) => marker.position == position);
        _createRoute();
      }
    });
  }

  void _clearLastMarker() {
    if (_markers.isNotEmpty) {
      setState(() {
        if (_markers.last.position != _fixedLocation) {
          _markers.remove(_markers.last);
          _createRoute();
        }
      });
    }
  }

  Future<void> _createRoute() async {
    if (_markers.length < 2) return;

    List<LatLng> markerPositions = _markers.map((marker) => marker.position).toList();

    markerPositions.removeWhere((position) => position == _fixedLocation);

    String waypoints = markerPositions.map((latlng) => '${latlng.latitude},${latlng.longitude}').join('|');

    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${markerPositions.first.latitude},${markerPositions.first.longitude}&destination=${markerPositions.last.latitude},${markerPositions.last.longitude}&waypoints=$waypoints&key=AIzaSyAKgJ6GXXEbaYZsog78LLrIj0qKtyN868g';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      setState(() {
        _polylineCoordinates.clear();
        for (var route in data['routes']) {
          for (var leg in route['legs']) {
            for (var step in leg['steps']) {
              _polylineCoordinates.add(LatLng(step['start_location']['lat'], step['start_location']['lng']));
              _polylineCoordinates.add(LatLng(step['end_location']['lat'], step['end_location']['lng']));
            }
          }
        }
        _polyline = Polyline(
          polylineId: PolylineId('route'),
          points: _polylineCoordinates,
          color: Colors.blue,
          width: 5,
        );
      });
    }
  }

  void _mostrarMensaje(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _saveRoute(BuildContext context) async {
    if (_markers.length < 2) {
      _mostrarMensaje(context, 'Debe haber al menos dos marcadores para guardar la ruta.');
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _mostrarMensaje(context, 'No hay usuario autenticado.');
      return;
    }

    final String? email = user.email;
    final assignUrl = 'http://10.0.2.2:3000/api/usuarios/usuarios/obtener-id?email=$email';
    final response = await http.get(
      Uri.parse(assignUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final userId = data['id'];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Guardar Ruta"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _rutaController,
                  decoration: InputDecoration(hintText: "Nombre de la ruta"),
                ),
                TextField(
                  controller: _descripcionController,
                  decoration: InputDecoration(hintText: "Descripción"),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedTipoMoto,
                  items: _tipoMotoOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedTipoMoto = newValue;
                    });
                  },
                  decoration: InputDecoration(hintText: "Tipo de moto"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  String rutaNombre = _rutaController.text;
                  String descripcion = _descripcionController.text;
                  String? tipoMoto = _selectedTipoMoto;

                  if (tipoMoto == null) {
                    _mostrarMensaje(context, 'Por favor, selecciona un tipo de moto.');
                    return;
                  }

                  List<Map<String, double>> coordenadas = _markers.map((marker) {
                    return {
                      'latitude': marker.position.latitude,
                      'longitude': marker.position.longitude,
                    };
                  }).toList();

                  final response = await http.post(
                    Uri.parse('http://10.0.2.2:3000/api/rutas/rutas'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(<String, dynamic>{
                      'nombre': rutaNombre,
                      'descripcion': descripcion,
                      'tipoMoto': tipoMoto,
                      'userId': userId,
                      'coordenadas': coordenadas,
                    }),
                  );

                  if (response.statusCode == 201) {
                    Navigator.pop(context);
                  } else {
                    _mostrarMensaje(context, 'Error al guardar la ruta. Inténtalo de nuevo más tarde.');
                  }
                },
                child: Text('Guardar'),
              ),
            ],
          );
        },
      );
    } else {
      _mostrarMensaje(context, 'Error al obtener el ID de usuario. Inténtalo de nuevo más tarde.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Creador de Rutas'),
      ),
      body: Stack(
        children: [
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _fixedLocation,
                    zoom: 14,
                  ),
                  mapType: MapType.hybrid,
                  compassEnabled: true,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  onMapCreated: (controller) {
                    _controller.complete(controller);
                    _mapController = controller;
                  },
                  markers: _markers,
                  polylines: _polyline != null
                      ? Set<Polyline>.of([_polyline!])
                      : Set(),
                  onTap: (position) {
                    _addMarker(position);
                  },
                ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FloatingActionButton(
                  onPressed: _moveToFixedLocation,
                  child: Icon(Icons.location_on),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _clearLastMarker,
                  child: Icon(Icons.delete),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () => _saveRoute(context),
                  child: Icon(Icons.save),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
