import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class CreateChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Chat'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: CreateChatForm(),
      ),
    );
  }
}

class CreateChatForm extends StatefulWidget {
  @override
  _CreateChatFormState createState() => _CreateChatFormState();
}

class _CreateChatFormState extends State<CreateChatForm> {
  final TextEditingController _nombreChatController = TextEditingController();
  String? _tipoMotoValue;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nombreChatController,
            decoration: InputDecoration(labelText: 'Nombre del Chat'),
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
            onPressed: () => _crearChat(context),
            child: Text('Crear Chat'),
          ),
        ],
      ),
    );
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

  Future<void> _crearChat(BuildContext context) async {
    final String nombreChat = _nombreChatController.text;
    final String tipoMoto = _tipoMotoValue ?? '';

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
        final userCreator = data['id'];

        final createChatUrl =
            'http://10.0.2.2:3000/api/chat/chats/$userCreator';
        final createResponse = await http.post(
          Uri.parse(createChatUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'nombreChat': nombreChat,
            'tipoMoto': tipoMoto,
            'userCreator': userCreator,
          }),
        );

        if (createResponse.statusCode == 201) {
          Navigator.pop(context);
        } else {
        }
      } else {
      }
    } else {
    }
  }
}