import 'package:flutter/material.dart';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    bool isLight;
    isLight = DynamicTheme.of(context).brightness == Brightness.light;

    var user = Provider.of<FirebaseUser>(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Email:${user.email}'),
          Text('uid:${user.uid}'),
          IconButton(
            icon: isLight
                ? Icon(Icons.wb_incandescent, color: Colors.black)
                : Icon(Icons.lightbulb_outline),
            onPressed: () => setState(
              () {
                if (isLight) {
                  // brightness = Brightness.dark;
                  isLight = !isLight;
                  DynamicTheme.of(context).setBrightness(Brightness.dark);
                } else if (!isLight) {
                  isLight = !isLight;
                  // brightness = Brightness.light;
                  DynamicTheme.of(context).setBrightness(Brightness.light);
                } else {
                  isLight = DynamicThemeState().brightness == Brightness.light;
                  // brightness = Brightness.dark;
                  DynamicTheme.of(context).setBrightness(Brightness.dark);
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
