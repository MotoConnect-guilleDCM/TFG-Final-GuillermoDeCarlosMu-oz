import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MotorcycleScreen extends StatefulWidget {
  @override
  _MotorcycleScreenState createState() => _MotorcycleScreenState();
}

class _MotorcycleScreenState extends State<MotorcycleScreen> {
  TextEditingController makeTextController = TextEditingController();
  TextEditingController modelTextController = TextEditingController();
  List<Motorcycle> motorcycles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar Motos'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background_image.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: makeTextController,
                decoration: InputDecoration(
                  labelText: 'Marca',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: modelTextController,
                decoration: InputDecoration(
                  labelText: 'Modelo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  fetchMotorcycles(
                    makeTextController.text,
                    modelTextController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Buscar'),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: motorcycles.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        saveMotorcycleToDatabase(motorcycles[index]);
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Marca: ${motorcycles[index].make}',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text('Modelo: ${motorcycles[index].model}'),
                              SizedBox(height: 8),
                              Text('Desplazamiento: ${motorcycles[index].displacement}'),
                              SizedBox(height: 8),
                              Text('Tipo: ${motorcycles[index].type}'),
                              SizedBox(height: 8),
                              Text('Año: ${motorcycles[index].year}'),
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
        ),
      ),
    );
  }

  Future<void> fetchMotorcycles(String searchMake, String searchModel) async {
    final apiKey = 'zgmA8vsHDCW1ZA6AkHbvGw==PGRljc5bQeaF7OPq';
    String url = 'https://api.api-ninjas.com/v1/motorcycles?make=$searchMake';
    if (searchModel.isNotEmpty) {
      url += '&model=$searchModel';
    }
    final response = await http.get(Uri.parse(url), headers: {
      'x-api-key': apiKey,
    });

    if (response.statusCode == 200) {
      print('Response JSON: ${response.body}');

      List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(json.decode(response.body));
      setState(() {
        motorcycles = data.map((json) => Motorcycle.fromJson(json)).toList();
      });
    } else {
      throw Exception('Error al cargar las motocicletas');
    }
  }

  Future<void> saveMotorcycleToDatabase(Motorcycle motorcycle) async {
    try {
      final apiUrl = 'http://10.0.2.2:3000/api/moto/motos';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'make': motorcycle.make,
          'model': motorcycle.model,
          'displacement': motorcycle.displacement,
          'type': motorcycle.type,
          'year': motorcycle.year,
        }),
      );
      if (response.statusCode == 201) {
        print('Moto guardada en la base de datos');

        final motoId = await getMotorcycleIdFromDatabase(motorcycle);
        if (motoId != null) {
          final User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
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

              final assignMotoUrl = 'http://10.0.2.2:3000/api/usuarios/usuarios/$userId/asignar-moto/$motoId';
              final userResponse = await http.put(
                Uri.parse(assignMotoUrl),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
              );
              if (userResponse.statusCode == 200) {
                print('Moto asociada al usuario');
                Navigator.pushReplacementNamed(context, '/');
              } else {
                throw Exception('Error al asociar la moto al usuario');
              }
            } else {
              throw Exception('No se ha iniciado sesión');
            }
          }
        } else {
          throw Exception('Error al guardar la moto en la base de datos');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<String?> getMotorcycleIdFromDatabase(Motorcycle motorcycle) async {
    final apiUrl = 'http://10.0.2.2:3000/api/moto/buscar-moto';

    final response = await http.get(
      Uri.parse('$apiUrl?make=${motorcycle.make}&model=${motorcycle.model}&displacement=${motorcycle.displacement}&type=${motorcycle.type}&year=${motorcycle.year}'),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final motoId = responseData['id'].toString();

      return motoId;
    } else if (response.statusCode == 404) {
      throw Exception('No se encontró ninguna moto con los detalles proporcionados');
    } else {
      throw Exception('Error al obtener el ID de la moto desde el servidor');
    }
  }
}

class Motorcycle {
  final String make;
  final String model;
  final String displacement;
  final String type;
  final String year;

  Motorcycle({required this.make, required this.model, required this.displacement, required this.type, required this.year});

  factory Motorcycle.fromJson(Map<String, dynamic> json) {
    return Motorcycle(
      make: json['make'],
      model: json['model'],
      displacement: json['displacement'],
      type :json['type'],
      year: json['year'],
    );
  }
}
