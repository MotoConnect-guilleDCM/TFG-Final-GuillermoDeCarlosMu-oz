import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:motoconnect_alpha/views/routes/route_planner_page.dart';
import 'package:motoconnect_alpha/views/routes/rutas_navegation_page.dart';
import '../../widgets/AppBottomNavigationBar.dart';
import '../../widgets/CustomAppBar.dart';

class RutasPage extends StatefulWidget {
  @override
  _RutasPageState createState() => _RutasPageState();
}

class _RutasPageState extends State<RutasPage> {
  List<dynamic> _rutas = [];
  List<dynamic> _rutasFiltradas = [];

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRutas();
    Timer.periodic(Duration(seconds: 10), (Timer t) => _fetchRutas());
  }

  Future<void> _fetchRutas() async {
    try {
      final response =
      await http.get(Uri.parse('http://10.0.2.2:3000/api/rutas/rutas'));
      if (response.statusCode == 200) {
        setState(() {
          _rutas = jsonDecode(response.body);
          _rutasFiltradas = _rutas;
        });
      } else {
        throw Exception('Error al cargar las rutas');
      }
    } catch (e) {
      print('Error al cargar las rutas: $e');
    }
  }

  void _filterRutas(String searchText) {
    setState(() {
      _rutasFiltradas = _rutas
          .where((ruta) => ruta['NombreRuta']
          .toLowerCase()
          .contains(searchText.toLowerCase()))
          .toList();
    });
  }

  Future<String> _fetchUserName(int userId) async {
    try {
      final response = await http.get(Uri.parse(
          'http://10.0.2.2:3000/api/usuarios/usuarios/obtener-username/$userId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String userName = data['username'];
        return userName;
      } else {
        throw Exception('Error al obtener el nombre de usuario');
      }
    } catch (e) {
      print('Error al obtener el nombre de usuario: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Rutas',
        automaticallyImplyLeading: false,
        onProfilePressed: () {},
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar ruta',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _filterRutas(_searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _rutasFiltradas.isEmpty
                ? Center(child: Text('No hay rutas disponibles'))
                : ListView.builder(
              itemCount: _rutasFiltradas.length,
              itemBuilder: (BuildContext context, int index) {
                final ruta = _rutasFiltradas[index];
                return FutureBuilder(
                  future: _fetchUserName(ruta['userId']),
                  builder: (BuildContext context,
                      AsyncSnapshot<String> snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text(
                          'Error al obtener el nombre del usuario');
                    } else {
                      final userName = snapshot.data ??
                          'Nombre de usuario no disponible';
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Colors.blueGrey.shade800,
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            title: Text(
                              ruta['NombreRuta'] ??
                                  'Nombre no disponible',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Descripción: ${ruta['descripcion'] ?? 'Descripción no disponible'}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Creador: $userName',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Tipo de Moto: ${ruta['tipoMoto'] ?? 'Tipo de moto no disponible'}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RouteLoader(
                                    routeId: ruta['id'],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RoutePlannerPage()),
          );
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: 1),
    );
  }
}
