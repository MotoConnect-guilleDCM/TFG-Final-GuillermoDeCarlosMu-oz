import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:motoconnect_alpha/views/routes/route_planner_page.dart';
import 'package:motoconnect_alpha/views/routes/rutas_navegation_page.dart';
import '../widgets/AppBottomNavigationBar.dart';
import '../widgets/CustomAppBar.dart';
import 'chats/chatMessages_page.dart';
import 'chats/createChat_page.dart';
import 'events/createEvent_page.dart';
import 'events/eventDetailed_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic> _motoDetails = {};
  List<dynamic> _recommendedRoutes = [];
  List<dynamic> _recommendedChats = [];
  List<dynamic> _recommendedEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchMotoDetails();
    _fetchRecommendedEvents();
    _fetchRecommendedChats();
    _fetchRecommendedRoutes();
  }

  Future<void> _fetchMotoDetails() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String? email = user.email;
        final response = await http.get(
            Uri.parse('http://10.0.2.2:3000/api/moto/motoByUserEmail/$email'));
        if (response.statusCode == 200) {
          final motoDetails = jsonDecode(response.body);
          setState(() {
            _motoDetails = motoDetails;
          });
        } else {
          print('Error al obtener detalles de la moto: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  Future<void> _fetchRecommendedEvents() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:3000/api/eventos/eventos'));
      if (response.statusCode == 200) {
        final recommendedEvents = jsonDecode(response.body);
        final filteredEvents = recommendedEvents
            .where((event) => event['tipoMoto'] == _motoDetails['type']);
        setState(() {
          _recommendedEvents = filteredEvents.toList();
        });
      } else {
        throw Exception('Error al cargar los eventos');
      }
    } catch (e) {
      print('Error al cargar los eventos: $e');
    }
  }

  Future<void> _fetchRecommendedChats() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:3000/api/chat/chats'));
      if (response.statusCode == 200) {
        final recommendedChats = jsonDecode(response.body);
        final filteredChats = recommendedChats
            .where((chat) => chat['tipoMoto'] == _motoDetails['type']);
        setState(() {
          _recommendedChats = filteredChats.toList();
        });
      } else {
        throw Exception('Error al cargar los chats: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al cargar los chats: $e');
    }
  }

  Future<void> _fetchRecommendedRoutes() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:3000/api/rutas/rutas'));
      if (response.statusCode == 200) {
        final recommendedRoutes = jsonDecode(response.body);
        if (_motoDetails.containsKey('type') && _motoDetails['type'] != null) {
          final filteredRoutes = recommendedRoutes
              .where((route) => route['tipoMoto'] == _motoDetails['type']);
          setState(() {
            _recommendedRoutes = filteredRoutes.toList();
          });
        }
      } else {
        throw Exception('Error al cargar las rutas');
      }
    } catch (e) {
      print('Error al cargar las rutas: $e');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Inicio',
        onProfilePressed: () {},
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            if (_motoDetails.isNotEmpty) ...[
              _buildMotoDetails(),
              SizedBox(height: 20),
            ],
            SizedBox(height: 20),
            _buildRoutesCarousel(
                "Rutas Recomendadas", _recommendedRoutes, Icons.map),
            SizedBox(height: 20),
            _buildChatCarousel(
                "Chats Recomendados", _recommendedChats, Icons.chat),
            SizedBox(height: 20),
            _buildEventCarousel(
                "Eventos Recomendados", _recommendedEvents, Icons.event),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildMotoDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade700,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetail('Marca', _motoDetails['make']),
            _buildDetail('Modelo', _motoDetails['model']),
            _buildDetail('Cilindrada', _motoDetails['displacement']),
            _buildDetail('Tipo', _motoDetails['type']),
            _buildDetail('Año', _motoDetails['year']),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCarousel(String title, List<dynamic> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.blueGrey.shade900),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade900),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        items.isNotEmpty
            ? Container(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final evento = items[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailedPage(evento: evento)),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                          child: Container(
                            width: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: Colors.blueGrey.shade700,
                            ),
                            child: Center(
                              child: Text(
                                evento['nombreEvento'],
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            : Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateEventPage()),
                    );
                  },
                  child: Text('Crear Evento'),
                ),
              ),
      ],
    );
  }

  Widget _buildRoutesCarousel(
      String title, List<dynamic> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.blueGrey.shade900),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade900,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        items.isNotEmpty
            ? Container(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final route = items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RouteLoader(routeId: route['id']),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                          child: Container(
                            width: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: Colors.blueGrey.shade700,
                            ),
                            child: Center(
                              child: Text(
                                route['NombreRuta'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            : Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RoutePlannerPage()),
                    );
                  },
                  child: Text('Crear Ruta'),
                ),
              ),
      ],
    );
  }

  Widget _buildChatCarousel(String title, List<dynamic> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.blueGrey.shade900),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade900),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        items.isNotEmpty
            ? Container(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final chat = items[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChatMessagesPage(groupId: chat['id']),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                          child: Container(
                            width: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: Colors.blueGrey.shade700,
                            ),
                            child: Center(
                              child: Text(
                                chat['nombreChat'],
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            : Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateChatPage()),
                    );
                  },
                  child: Text('Crear Chat'),
                ),
              ),
      ],
    );
  }
}
