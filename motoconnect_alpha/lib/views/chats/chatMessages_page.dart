import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMessagesPage extends StatefulWidget {
  final int groupId;

  ChatMessagesPage({required this.groupId});

  @override
  _ChatMessagesPageState createState() => _ChatMessagesPageState();
}

class _ChatMessagesPageState extends State<ChatMessagesPage> {
  List<Map<String, dynamic>> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  String? _userId;
  Timer? _timer;
  Map<String, String> _usernameCache = {};
  int? _lastMessageId;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _fetchUserId();
    _startMessageFetchTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startMessageFetchTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _fetchMessages());
  }

  Future<void> _fetchMessages() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/chat/chats/${widget.groupId}/mensajes'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final List<Map<String, dynamic>> newMessages = data.cast<Map<String, dynamic>>().toList();

      if (_lastMessageId == null || newMessages.isNotEmpty && newMessages.last['id'] != _lastMessageId) {
        setState(() {
          _messages = newMessages;
          _lastMessageId = newMessages.isNotEmpty ? newMessages.last['id'] : _lastMessageId;
        });
        // Fetch usernames for new messages
        _fetchUsernamesForMessages();
      }
    } else {
      print('Error fetching messages: ${response.statusCode}');
    }
  }

  Future<void> _fetchUsernamesForMessages() async {
    for (int i = 0; i < _messages.length; i++) {
      final message = _messages[i];
      final userId = message['userId'].toString();

      if (!_usernameCache.containsKey(userId)) {
        final response = await http.get(
          Uri.parse('http://10.0.2.2:3000/api/usuarios/usuarios/obtener-username/$userId'),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> userData = jsonDecode(response.body);
          final String? username = userData['username'];

          if (username != null) {
            setState(() {
              _usernameCache[userId] = username;
              _messages[i]['username'] = username;
            });
          } else {
            print('Error: Username is null');
          }
        } else {
          print('Error fetching username: ${response.statusCode}');
        }
      } else {
        setState(() {
          _messages[i]['username'] = _usernameCache[userId];
        });
      }
    }
  }

  Future<void> _fetchUserId() async {
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
        final userId = data['id'].toString();
        setState(() {
          _userId = userId;
        });
      } else {
        print('Error fetching user ID: ${response.statusCode}');
      }
    }
  }

  Future<void> _sendMessage(String message) async {
    if (_userId == null) {
      print('User ID is not available');
      return;
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/api/chat/chats/${widget.groupId}/mensajes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': _userId, 'mensaje': message}),
    );

    if (response.statusCode == 201) {
      _fetchMessages();
      _messageController.clear();
    } else {
      print('Error sending message: ${response.statusCode} - ${response.body}');
    }
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    bool isMe = message['userId'].toString() == _userId;
    String senderName = isMe ? 'Tú' : message['username'].toString();
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message['mensaje'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
              senderName,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mensajes del Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessage(message);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _sendMessage(value);
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _sendMessage(_messageController.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
