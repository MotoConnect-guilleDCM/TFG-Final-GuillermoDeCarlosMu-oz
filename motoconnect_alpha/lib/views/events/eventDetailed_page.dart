import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../widgets/AppBottomNavigationBar.dart';
import '../../widgets/CustomAppBar.dart';
import 'createEvent_page.dart';


class EventosPage extends StatefulWidget {
  @override
  _EventosPageState createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  List<dynamic> _eventos = [];
  List<dynamic> _eventosFiltrados = [];

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEventos();
    Timer.periodic(Duration(seconds: 10), (Timer t) => _fetchEventos());
  }

  Future<void> _fetchEventos() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/eventos/eventos'));
      if (response.statusCode == 200) {
        setState(() {
          _eventos = jsonDecode(response.body);
          _eventosFiltrados = _eventos;
        });
      } else {
        throw Exception('Error al cargar los eventos');
      }
    } catch (e) {
      print('Error al cargar los eventos: $e');
    }
  }

  void _filterEvents(String searchText) {
    setState(() {
      _eventosFiltrados = _eventos.where((evento) => evento['nombreEvento'].toLowerCase().contains(searchText.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Eventos',
        automaticallyImplyLeading: false,
        onProfilePressed: () {},
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar evento',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        _filterEvents(_searchController.text);
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
          Expanded(
            child: _eventosFiltrados.isEmpty
                ? Center(child: Text('No hay eventos disponibles'))
                : ListView.builder(
              itemCount: _eventosFiltrados.length,
              itemBuilder: (context, index) {
                final evento = _eventosFiltrados[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailedPage(evento: evento),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.blueGrey.shade800,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            evento['nombreEvento'],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            evento['descripcion'],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Tipo de moto: ${evento['tipoMoto']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Creador: ${evento['username']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Fecha del evento: ${_formatFecha(evento['fechaEvento'])}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Inscritos: ${evento['inscritos']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
            MaterialPageRoute(builder: (context) => CreateEventPage()),
          );
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: 3),
    );
  }

  String _formatFecha(String fecha) {
    DateTime dateTime = DateTime.parse(fecha);
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return formattedDate;
  }
}

class EventDetailedPage extends StatelessWidget {
  final dynamic evento;

  EventDetailedPage({required this.evento});

  Future<void> _inscribirUsuario(BuildContext context) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String? email = user.email;
      final assignUrl =
          'http://10.0.2.2:3000/api/usuarios/usuarios/obtener-id?email=$email';
      final response = await http.get(
        Uri.parse(assignUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final userId = data['id'];

        final userEventUrl =
            'http://10.0.2.2:3000/api/eventos/usuario-inscrito/$userId/${evento['id']}';
        final userEventResponse = await http.get(
          Uri.parse(userEventUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        await _inscribirEvento(
            context, userId.toString(), evento['id'].toString());
      } else {
        _mostrarMensaje(context, 'Error al obtener el ID del usuario');
      }
    }
  }

  Future<void> _desinscribirUsuario(BuildContext context) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String? email = user.email;
      final assignUrl =
          'http://10.0.2.2:3000/api/usuarios/usuarios/obtener-id?email=$email';
      final response = await http.get(
        Uri.parse(assignUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final userId = data['id'];

        final desinscribirUrl =
            'http://10.0.2.2:3000/api/eventos/desinscribirse/$userId/${evento['id']}';
        final desinscribirResponse = await http.delete(
          Uri.parse(desinscribirUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        if (desinscribirResponse.statusCode == 200) {
          _mostrarMensaje(
              context, 'Usuario desinscrito del evento exitosamente');
        } else {
          _mostrarMensaje(
              context, 'Error al desinscribir al usuario del evento');
        }
      } else {
        _mostrarMensaje(context, 'Error al obtener el ID del usuario');
      }
    }
  }

  Future<void> _inscribirEvento(
      BuildContext context, String userId, String eventId) async {
    final inscribirUrl =
        'http://10.0.2.2:3000/api/eventos/inscribirse/$userId/$eventId';
    final response = await http.post(
      Uri.parse(inscribirUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 201) {
      _mostrarMensaje(context, 'Usuario inscrito al evento exitosamente');
    } else if (response.statusCode == 409) {
      _mostrarMensaje(context, 'El usuario ya está inscrito en este evento');
    } else {
      _mostrarMensaje(context, 'Error al inscribir al usuario en el evento');
    }
  }

  Future<void> _eliminarEvento(BuildContext context) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final String? email = user.email;
      final assignUrl =
          'http://10.0.2.2:3000/api/usuarios/usuarios/obtener-id?email=$email';
      final response = await http.get(
        Uri.parse(assignUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final userId = data['id'];

        if (userId == evento['idCreador']) {
          final eventId = evento['id'].toString();

          final deleteUrl = 'http://10.0.2.2:3000/api/eventos/eventos/$eventId';

          final deleteResponse = await http.delete(
            Uri.parse(deleteUrl),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
          );

          if (deleteResponse.statusCode == 200) {
            _mostrarMensaje(context, 'Evento eliminado exitosamente');
          } else {
            _mostrarMensaje(context, 'Error al eliminar el evento');
          }
        } else {
          _mostrarMensaje(
              context, 'Solo el creador del evento puede eliminarlo');
        }
      } else {
        _mostrarMensaje(context, 'Error al obtener el ID del usuario');
      }
    }
  }

  void _mostrarMensaje(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del evento'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Nombre del evento:',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  evento['nombreEvento'],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Descripción:',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  evento['descripcion'],
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Tipo de moto:',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  evento['tipoMoto'],
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Creador:',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  evento['username'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Fecha del evento:',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Fecha del evento: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(evento['fechaEvento']))}',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirmar inscripción'),
                                content: Text(
                                    '¿Estás seguro de que quieres inscribirte en este evento?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _inscribirUsuario(context);
                                    },
                                    child: Text('Confirmar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('Inscribirse'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirmar desinscripción'),
                                content: Text(
                                    '¿Estás seguro de que quieres desinscribirte en este evento?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _desinscribirUsuario(context);
                                    },
                                    child: Text('Confirmar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('Desinscribirse'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InscritosPage(
                                  idEvento: evento['id'].toString()),
                            ),
                          );
                        },
                        child: Text('Ver inscritos'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirmar eliminación'),
                                content: Text(
                                    '¿Estás seguro de que quieres eliminar este evento?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _eliminarEvento(context);
                                    },
                                    child: Text('Confirmar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('Eliminar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InscritosPage extends StatelessWidget {
  final String idEvento;

  InscritosPage({required this.idEvento});

  Future<List<String>> _fetchInscritos() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/eventos/nombresInscritos/$idEvento'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<String>();
    } else {
      throw Exception('Error al obtener los nombres de los inscritos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inscritos en el evento'),
      ),
      body: FutureBuilder<List<String>>(
        future: _fetchInscritos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    elevation: 4.0,
                    child: ListTile(
                      title: Text(
                        snapshot.data![index],
                        style: TextStyle(fontSize: 18.0),
                      ),
                      leading: CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
