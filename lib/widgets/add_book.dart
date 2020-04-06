import 'dart:io';

import '../models/book.dart';
import '../services/database_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class AddBook extends StatefulWidget {
  @override
  _AddBookState createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final db = DatabaseService();
  String title;
  String description;
  int pages;
  String author;
  String bookUrl;
  String coverUrl;
  bool isSubmitting = false;

  InputDecoration decor(String label, String hint, IconData icon) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      labelText: label,
      hintText: hint,
      icon: Icon(icon),
    );
  }

  void _successSnackBar() {
    final snackbar = SnackBar(
      content: Text(
        'successfully added book: $title',
        style: TextStyle(color: Colors.green),
      ),
    );

    _scaffoldKey.currentState.showSnackBar(snackbar);
    _formKey.currentState.reset();
  }

  void _errorSnackBar(String message) {
    final snackbar = SnackBar(
      content: Text(
        'Error: $message',
        style: TextStyle(color: Colors.red),
      ),
    );

    _scaffoldKey.currentState.showSnackBar(snackbar);
    // _formKey.currentState.reset();
    throw Exception('Error in adding product :$message');
  }

  Padding titleField() {
    return Padding(
      padding: const EdgeInsets.only(top: 17.0),
      child: TextFormField(
          onSaved: (val) => title = val,
          validator: (val) => (val.length < 3) ? 'invalid Name' : null,
          decoration:
              decor('Title', 'Enter title of the Book', Icons.text_fields)),
    );
  }

  Padding authorField() {
    return Padding(
      padding: const EdgeInsets.only(top: 17.0),
      child: TextFormField(
          onSaved: (val) => author = val,
          validator: (val) => (val.length < 3) ? 'invalid Name' : null,
          decoration: decor(
              'Author', 'Name of the Author', FontAwesomeIcons.addressCard)),
    );
  }

  Padding numOfPagesField() {
    return Padding(
      padding: const EdgeInsets.only(top: 17.0),
      child: TextFormField(
          onSaved: (val) => pages = int.parse(val),
          validator: (val) => (val.length < 1) ? 'invalid no. of page' : null,
          decoration: decor(
              'Pages', 'Number of pages', FontAwesomeIcons.sortNumericDown)),
    );
  }

  Padding descriptionField() {
    return Padding(
      padding: const EdgeInsets.only(top: 17.0),
      child: TextFormField(
          onSaved: (val) => description = val,
          validator: (val) => (val.length < 1) ? 'invalid description' : null,
          decoration: decor(
              'description',
              'Enter at least 20 characters about the book',
              FontAwesomeIcons.font)),
    );
  }

  _submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      setState(() => isSubmitting = true);
      db
          .addBook(Book(
        title: title,
        author: author,
        pages: pages,
        coverUrl: coverUrl,
        bookUrl: bookUrl,
      ))
          .catchError((e) {
        _errorSnackBar(e);
      });
      setState(() => isSubmitting = false);
      print('added Successfully!');
      _successSnackBar();
    } else {
      print('invalid form');
      setState(() => isSubmitting = false);
      _errorSnackBar('Error in adding data, please try again');
    }
  }

  Padding uploadCoverPic() {
    return Padding(
      padding: EdgeInsets.only(top: 17),
      child: coverUrl == null
          ? FlatButton.icon(
              onPressed: getImage,
              icon: Icon(Icons.cloud_upload),
              label: Text('Upload cover picture'))
          : Text(
              'Image Uploaded',
              style: TextStyle(color: Colors.green),
            ),
    );
  }

  Padding uploadBook() {
    return Padding(
      padding: EdgeInsets.only(top: 17),
      child: bookUrl == null
          ? FlatButton.icon(
              onPressed: getBook,
              icon: Icon(FontAwesomeIcons.cloudUploadAlt),
              label: Text('Upload Book (pdf,doc,word,epub)'))
          : Text(
              'Book Uploaded',
              style: TextStyle(color: Colors.green),
            ),
    );
  }

  Future getBook() async {
    File file = await FilePicker.getFile();
    var filePath = file.path;
    setState(() => isSubmitting = true);
    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(filePath);
    final StorageUploadTask task = firebaseStorageRef.putFile(file);
    await (await task.onComplete).ref.getDownloadURL().then((book) {
      var url = book.toString();
      setState(() {
        bookUrl = url;
      });
      setState(() => isSubmitting = false);
      print('Image book successfully: $bookUrl');
    });
  }

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    var filePath = (tempImage.path);

    setState(() => isSubmitting = true);
    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(filePath);

    final StorageUploadTask task = firebaseStorageRef.putFile(tempImage);

    await (await task.onComplete).ref.getDownloadURL().then((image) {
      var url = image.toString();
      setState(() {
        coverUrl = url;
      });

      setState(() => isSubmitting = false);
      print('Image uploaded successfully: $coverUrl');
    });
  }

  Padding _addBook(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 17),
      child: Column(children: [
        isSubmitting
            ? CircularProgressIndicator()
            : FlatButton(
                color: Colors.blueAccent,
                onPressed: _submit,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '+ Add Book',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        padding: EdgeInsets.all(17),
        child: Center(
          child: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset('assets/images/books.png'),
                    titleField(),
                    authorField(),
                    numOfPagesField(),
                    descriptionField(),
                    uploadCoverPic(),
                    uploadBook(),
                    _addBook(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
