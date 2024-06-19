import 'package:flutter/material.dart';

class User {
  String name;
  int points;

  User({required this.name, required this.points});
}

class PointCollection {
  Map<String, User> users = {};

  void addUser(String name) {
    users[name] = User(name: name, points: 0);
  }

  void addPoints(String name, int points) {
    if (users.containsKey(name)) {
      users[name]!.points += points;
    } else {
      print('User not found');
    }
  }

  int getPoints(String name) {
    if (users.containsKey(name)) {
      return users[name]!.points;
    } else {
      print('User not found');
      return 0;
    }
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final PointCollection pointCollection = PointCollection();

  @override
  Widget build(BuildContext context) {
    pointCollection.addUser('John');
    pointCollection.addPoints('John', 5);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Point Collection'),
        ),
        body: Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: Center(
              child: Text(
                '${pointCollection.getPoints('John')} Points',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
