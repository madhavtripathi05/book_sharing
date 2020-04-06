import '../services/database_service.dart';

import '../constants/constants.dart';
import 'package:flutter/material.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final db = DatabaseService();
  String _password, _email;

  bool _obscureText = true;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        padding: EdgeInsets.all(27),
        child: Center(
          child: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Login',
                      style: TextStyle(fontSize: 32),
                    ),
                    _emailField(),
                    _passwordField(),
                    _authButtons(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      _loginUser();
      print(' password:$_password,email:$_email');
    } else {
      print('invalid form');
    }
  }

  void _successSnackBar() {
    final snackbar = SnackBar(
      backgroundColor: Colors.grey[900],
      content: Text(
        'successfully Logged in: $_email ',
        style: TextStyle(color: Colors.green),
      ),
    );

    _scaffoldKey.currentState.showSnackBar(snackbar);
    _formKey.currentState.reset();
  }

  void _errorSnackBar(String message) {
    final snackbar = SnackBar(
      backgroundColor: Colors.grey[900],
      content: Text(
        'Error: $message',
        style: TextStyle(color: Colors.red),
      ),
    );

    _scaffoldKey.currentState.showSnackBar(snackbar);
    // _formKey.currentState.reset();
    // throw Exception('Error in registration :$message');
  }

  void _redirect() {
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/dashboard');
    });
  }

  void _loginUser() async {
    setState(() => _isSubmitting = true);
    await db.login(_email, _password).then((u) {
      if (u.user != null) {
        setState(() => _isSubmitting = false);
        print('login successful');
        print(u.toString());
        setState(() => _isSubmitting = false);
        _redirect();
        _successSnackBar();
      } else
        print('error in logging in');
    }).catchError((e) {
      _errorSnackBar('Error: $e');
      setState(() => _isSubmitting = false);
      return;
    });
  }

  InputDecoration decor(String label, String hint, IconData icon,
      [bool pass = false]) {
    return InputDecoration(
      suffixIcon: pass
          ? InkWell(
              child:
                  Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
              onTap: () => setState(() => _obscureText = !_obscureText),
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      labelText: label,
      hintText: hint,
      icon: Icon(icon),
    );
  }

  Padding _authButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 17),
      child: Column(children: [
        _isSubmitting
            ? CircularProgressIndicator()
            : RaisedButton(
                onPressed: _submit,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('submit'),
                color: Theme.of(context).accentColor,
              ),
        Hero(
          tag: 'auth_animation',
          child: FlatButton(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, SignupScreen.routeName),
            child: Text('New user? Register'),
          ),
        ),
      ]),
    );
  }

  Padding _passwordField() {
    return Padding(
      padding: kTopPad,
      child: TextFormField(
        onSaved: (val) => _password = val,
        validator: (val) => (val.length < 6 ? 'Enter a valid Password' : null),
        decoration: decor(
            'Password', 'Enter a password, min 6 characters', Icons.lock, true),
        obscureText: _obscureText,
      ),
    );
  }

  Padding _emailField() {
    return Padding(
      padding: kTopPad,
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        onSaved: (val) => _email = val,
        validator: (val) =>
            (val.length < 6 || !val.contains('@') || !val.contains('.'))
                ? 'invalid Email'
                : null,
        decoration: decor('Email', 'Enter a valid Email', Icons.mail),
      ),
    );
  }
}
