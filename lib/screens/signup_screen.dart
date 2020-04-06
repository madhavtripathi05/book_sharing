import '../models/user.dart';
import '../services/database_service.dart';

import '../constants/constants.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/signup_screen';
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _password, _email, _name, _phone;
  final db = DatabaseService();

  bool _obscureText = true;
  bool _isSubmitting = false;

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
                      'Sign Up',
                      style: TextStyle(fontSize: 32),
                    ),
                    _nameField(),
                    _phoneField(),
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
      _signupUser();
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

  void _signupUser() async {
    setState(() => _isSubmitting = true);
    await db.signup(_email, _password).then((u) {
      if (u.user != null) {
        db.addUser(User(
          email: _email,
          phone: _phone,
          uid: u.user.uid,
          noOfBooks: 0,
          name: _name,
        ));
        print('signup successful');
        _redirect();
        _successSnackBar();
        setState(() => _isSubmitting = false);
      } else
        print('error in registering');
    }).catchError((e) {
      setState(() => _isSubmitting = false);
      _errorSnackBar('Error: $e ');
      return;
    });

    setState(() => _isSubmitting = false);
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
                Navigator.pushReplacementNamed(context, LoginScreen.routeName),
            child: Text('already a user? Login'),
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

  Padding _nameField() {
    return Padding(
      padding: kTopPad,
      child: TextFormField(
        onSaved: (val) => _name = val,
        validator: (val) => (val.length < 3 ? 'Enter a valid name' : null),
        decoration: decor('Name', 'Enter your password, min 3 characters',
            Icons.account_circle),
      ),
    );
  }

  Padding _phoneField() {
    return Padding(
      padding: kTopPad,
      child: TextFormField(
        onSaved: (val) => _phone = val,
        validator: (val) =>
            (val.length < 10 ? 'Enter a valid phone number' : null),
        decoration:
            decor('Phone Number', 'Enter your phone number', Icons.phone),
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
