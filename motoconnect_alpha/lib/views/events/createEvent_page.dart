import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateEventPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Evento'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: CreateEventForm(),
      ),
    );
  }
}

class CreateEventForm extends StatefulWidget {
  @override
  _CreateEventFormState createState() => _CreateEventFormState();
}

class _CreateEventFormState extends State<CreateEventForm> {
  final TextEditingController _nombreEventoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  String? _tipoMotoValue;
  DateTime? _fechaEvento;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nombreEventoController,
            decoration: InputDecoration(labelText: 'Nombre del Evento'),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: _descripcionController,
            decoration: InputDecoration(labelText: 'Descripción'),
            maxLines: 3,
          ),
          SizedBox(height: 16.0),
          InkWell(
            onTap: () {
              _selectDate(context);
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Fecha del Evento',
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    _fechaEvento != null
                        ? DateFormat('dd/MM/yyyy').format(_fechaEvento!)
                        : 'Seleccionar fecha',
                  ),
                  Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.0),
          FutureBuilder<List<String>>(
            future: _fetchTipoMotoOptions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error al cargar los tipos de moto');
              } else {
                return DropdownButtonFormField<String>(
                  value: _tipoMotoValue,
                  items: snapshot.data!.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Tipo de Moto'),
                  onChanged: (String? value) {
                    setState(() {
                      _tipoMotoValue = value;
                    });
                  },
                );
              }
            },
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () => _crearEvento(context),
            child: Text('Crear Evento'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _fechaEvento ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _fechaEvento) {
      setState(() {
        _fechaEvento = pickedDate;
      });
    }
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

  Future<void> _crearEvento(BuildContext context) async {
    final String nombreEvento = _nombreEventoController.text;
    final String descripcion = _descripcionController.text;
    final String tipoMoto = _tipoMotoValue ?? '';
    final String fechaEvento = _fechaEvento != null
        ? DateFormat('yyyy-MM-dd').format(_fechaEvento!)
        : '';

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

        final createEventUrl =
            'http://10.0.2.2:3000/api/eventos/eventos/$userId';
        final createEventResponse = await http.post(
          Uri.parse(createEventUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'nombreEvento': nombreEvento,
            'descripcion': descripcion,
            'tipoMoto': tipoMoto,
            'fechaEvento': fechaEvento,
            'idCreador': userId,
          }),
        );
        if (createEventResponse.statusCode == 201) {
          Navigator.pop(context);
        } else {
        }
      } else {
      }
    } else {
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: CreateEventPage(),
  ));
}
