import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:motoconnect_alpha/views/auth/login.dart';
import 'package:motoconnect_alpha/views/auth/register.dart';
import 'package:motoconnect_alpha/views/chats/chat_page.dart';
import 'package:motoconnect_alpha/views/events/eventDetailed_page.dart';
import 'package:motoconnect_alpha/views/home_page.dart';
import 'package:motoconnect_alpha/views/auth/motoSelect_page.dart';
import 'package:motoconnect_alpha/views/routes/rutas_page.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotoConnect',
      theme: ThemeData(
        primaryColor: Color(0xFF1A3E50),
        scaffoldBackgroundColor: Color(0xFFD0D0DA),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1A3E50),
        ),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF1A3E50),
          secondary: Color(0xFFD0D0DA),
        ),
      ),
      home: AuthenticationWrapper(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/chat': (context) => ChatsPage(),
        '/rutas': (context) => RutasPage(),
        '/eventos': (context) => EventosPage(),
        '/motorcycles': (context) => MotorcycleScreen(),
      },
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return LoginPage();
          }
        }
      },
    );
  }
}
