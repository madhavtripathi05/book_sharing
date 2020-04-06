import 'dart:math';

import 'package:book_sharing/constants/constants.dart';
import 'package:book_sharing/models/book.dart';
import 'package:book_sharing/services/database_service.dart';
import 'package:book_sharing/widgets/add_book.dart';
import 'package:book_sharing/widgets/profile.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'book_description.dart';

class Dashboard extends StatefulWidget {
  static const routeName = '/dashboard';
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Book> books = [];
  bool isLoading = false;
  int currentIndex = 0;

  final db = DatabaseService();

  getAndSetData() {
    setState(() {
      isLoading = true;
    });
  }

  void selectWidget(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildBottomBar() {
      return BottomNavigationBar(
        selectedItemColor: Colors.grey.shade800,
        unselectedItemColor: Colors.grey,
        currentIndex: currentIndex,
        onTap: selectWidget,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.format_align_left),
              title: Text("Books"),
              backgroundColor: Colors.white),
          BottomNavigationBarItem(
              title: Text("Add book"),
              icon: Icon(Icons.add_circle_outline),
              backgroundColor: Colors.white),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              title: Text("Profile"),
              backgroundColor: Colors.white),
        ],
      );
    }

    Widget buildList(int index, List<Book> booksToDisplay) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: ExpansionTileCard(
          leading: CircleAvatar(
              //  maxRadius: 50,
              backgroundImage:
                  NetworkImage('${booksToDisplay[index].coverUrl}')),
          title: Text(
            '${booksToDisplay[index].title}',
            style: TextStyle(color: Colors.blue),
          ),
          subtitle: Text(
            'Tap to see more info',
            style: TextStyle(color: Colors.amberAccent, fontSize: 10),
          ),
          children: <Widget>[
            Divider(
              thickness: 1.0,
              height: 1.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                'Author: ${booksToDisplay[index].author}',
                textAlign: TextAlign.start,
                softWrap: true,
                style: TextStyle(fontSize: 15, color: Colors.green),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                'pages: ${booksToDisplay[index].pages}',
                style: TextStyle(fontSize: 15, color: Colors.deepOrangeAccent),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                'Description: ${booksToDisplay[index].description}',
                style: TextStyle(fontSize: 15, color: Colors.cyan),
                softWrap: true,
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceAround,
              buttonHeight: 52.0,
              buttonMinWidth: 90.0,
              children: <Widget>[
                FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0)),
                  onPressed: () {},
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.star),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      Text('Save'),
                    ],
                  ),
                ),
                FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDescription(
                        book: booksToDisplay[index],
                      ),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.open_in_browser),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      Text('Open'),
                    ],
                  ),
                ),
                FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0)),
                  onPressed: () {
                    DatabaseService().deleteBook(booksToDisplay[index].id);
                  },
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      Text(
                        'delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    var user = Provider.of<FirebaseUser>(context);
    bool loggedIn = user != null;
    bookList(context) {
      return Column(
        children: [
          SizedBox(height: 20),
          Text('Books', style: kBigText),
          SizedBox(height: 20),
          if (loggedIn) ...[
            StreamBuilder<List<Book>>(
              initialData: [Book(title: 'unknown')],
              stream: db.streamBooks(),
              builder: (context, snapshot) {
                var data = snapshot.data;
                print(data[0].author);
                return Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: data.length,
                    itemBuilder: (context, index) => data.length != 0
                        ? buildList(index, data)
                        : Text('Loading'),
                  ),
                );
              },
            )
          ],
          if (!loggedIn) ...[
            Center(
              child: Text('not logged in'),
            ),
          ]
        ],
      );
    }

    final List<Map<String, Object>> _widgets = [
      {'widget': bookList(context), 'title': 'Books'},
      {'widget': AddBook(), 'title': 'add Book'},
      {'widget': Profile(), 'title': 'Profile'},
    ];
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: _buildBottomBar(),
        body: _widgets[currentIndex]['widget'],
      ),
    );
  }
}
