import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../widgets/AppBottomNavigationBar.dart';
import '../../widgets/CustomAppBar.dart';
import 'chatMessages_page.dart';
import 'createChat_page.dart';

class ChatsPage extends StatefulWidget {
  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  List<dynamic> _chats = [];
  List<dynamic> _filteredChats = [];
  bool _isLoading = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchChats();
    Timer.periodic(Duration(seconds: 5), (Timer t) => _fetchChats());
  }

  Future<void> _fetchChats() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/chat/chats'));

      if (response.statusCode == 200) {
        final List<dynamic> chats = json.decode(response.body);
        setState(() {
          _chats = chats;
          _filteredChats = chats;
        });
      } else {
        print('Error al obtener los chats: ${response.statusCode}');
      }
    } catch (error) {
      print('Error al obtener los chats: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterChats(String searchText) {
    setState(() {
      _filteredChats = _chats.where((chat) => chat['nombreChat'].toLowerCase().contains(searchText.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Chats',
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
                  onChanged: (value) {
                    _filterChats(value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Buscar chat',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        _filterChats(_searchController.text);
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildChatsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateChatPage()),
          );
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: AppBottomNavigationBar(currentIndex: 2),
    );
  }

  Widget _buildChatsList() {
    return ListView.builder(
      itemCount: _filteredChats.length,
      itemBuilder: (BuildContext context, int index) {
        final chat = _filteredChats[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatMessagesPage(groupId: chat['id']),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Colors.blueGrey.shade800,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat['nombreChat'] ?? '',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  chat['tipoMoto'] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
