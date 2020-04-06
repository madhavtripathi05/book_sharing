import './models/book.dart';
import './screens/dashboard.dart';
import './screens/login_screen.dart';
import './screens/signup_screen.dart';
import './services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => ThemeData(
        brightness: brightness,
        fontFamily: 'google',
        primarySwatch: Colors.blue,
      ),
      themedWidgetBuilder: (context, theme) => MultiProvider(
        providers: [
          StreamProvider<FirebaseUser>.value(
              value: FirebaseAuth.instance.onAuthStateChanged),
          StreamProvider<List<Book>>.value(
              value: DatabaseService().streamBooks()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'book_sharing',
          theme: theme,
          home: LoginScreen(),
          routes: {
            LoginScreen.routeName: (context) => LoginScreen(),
            SignupScreen.routeName: (context) => SignupScreen(),
            Dashboard.routeName: (context) => Dashboard(),
          },
        ),
      ),
    );
  }
}
