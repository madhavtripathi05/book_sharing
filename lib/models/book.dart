import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  String title;
  String author;
  String bookUrl;
  String coverUrl;
  String uploader;
  String id;
  String description;
  int pages;

  Book(
      {this.author,
      this.bookUrl,
      this.coverUrl,
      this.pages,
      this.title,
      this.id});

  factory Book.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data ?? {};
    return Book(
      author: data['author'] ?? 'unknown',
      bookUrl: data['bookUrl'] ?? 'unknown',
      coverUrl: data['coverUrl'] ?? 'unknown',
      id: doc.documentID ?? 'unknown',
      pages: data['pages'] ?? 0,
      title: data['author'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'author': author ?? 'unknown',
      'coverUrl': coverUrl ?? 'unknown',
      'bookUrl': bookUrl ?? 'unknown',
      'pages': pages ?? 0,
      'title': title ?? 'unknown',
      'id': id ?? 'unknown',
    };
  }
}
