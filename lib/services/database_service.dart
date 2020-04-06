import '../models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';

class DatabaseService {
  final auth = FirebaseAuth.instance;
  final _db = Firestore.instance;

  // Auth
  Future<AuthResult> login(String email, String password) async {
    return await auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<AuthResult> signup(String email, String password) async {
    return await auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  // User
  Stream<User> streamUser(String id) {
    return _db
        .collection('users')
        .document(id)
        .snapshots()
        .map((snap) => User.fromFirestore(snap));
  }

  Future<void> addUser(User user) async {
    await _db
        .collection('users')
        .document('user${DateTime.now().millisecondsSinceEpoch}')
        .setData(user.toMap());
  }

  // Books

  Stream<Book> streamBook(String id) {
    return _db
        .collection('books')
        .document(id)
        .snapshots()
        .map((snap) => Book.fromFirestore(snap));
  }

  Future<void> addBook(Book book) async {
    await _db
        .collection('books')
        .document('book${DateTime.now().millisecondsSinceEpoch}')
        .setData(book.toMap());
  }

  Future<void> deleteBook(String id) async {
    print(id);
    await _db.collection('books').document(id).delete();
  }

  Stream<List<Book>> streamBooks() {
    var ref = _db.collection('books');

    return ref.snapshots().map((list) =>
        list.documents.map((doc) => Book.fromFirestore(doc)).toList());
  }
}
