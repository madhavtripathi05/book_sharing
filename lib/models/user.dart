import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String name;
  String email;
  int noOfBooks;
  String phone;
  String uid;
  String id;

  User({this.name, this.email, this.noOfBooks, this.phone, this.uid, this.id});

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data ?? {};
    return User(
      name: data['name'] ?? 'unknown',
      email: data['email'] ?? 'unknown',
      noOfBooks: data['noOfBooks'] ?? 0,
      phone: data['phone'] ?? 'unknown',
      uid: data['uid'] ?? 'unknown',
      id: doc.documentID,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name ?? 'unknown',
      'email': email ?? 'unknown',
      'noOfBooks': noOfBooks ?? 0,
      'phone': phone ?? 'unknown',
      'uid': uid ?? 'unknown',
      'id': id ?? 'unknown',
    };
  }
}
