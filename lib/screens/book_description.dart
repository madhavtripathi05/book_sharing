import 'package:book_sharing/models/book.dart';
import 'package:flutter/material.dart';

class BookDescription extends StatefulWidget {
  static const routeName = '/book-description';
  final Book book;
  BookDescription({this.book});
  @override
  _BookDescriptionState createState() => _BookDescriptionState();
}

class _BookDescriptionState extends State<BookDescription> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('book description'),
    );
  }
}
