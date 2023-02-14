import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter_provider',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class BreadCrumb {
  bool isActive;
  final String name;
  final String uuid;

  BreadCrumb({required this.isActive, required this.name}) : uuid = Uuid().v4();

  void activate() {
    isActive = true;
  }

  @override
  bool operator ==(covariant BreadCrumb other) => uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  String get title => name + (isActive ? " > " : '');
}

class BreadCrumbProvider extends ChangeNotifier {
  final List<BreadCrumb> _items = [];
  UnmodifiableListView<BreadCrumb> get iitem => UnmodifiableListView(_items);

  void addBreadCrumb(BreadCrumb breadCrumb) {
    for (final item in _items) {
      item.activate();
    }
    _items.add(breadCrumb);
    notifyListeners();
  }

  void removeBreadCrumb() {
    _items.clear();
    notifyListeners();
  }
}

class BreadCrumbWidget extends StatelessWidget {
  final UnmodifiableListView<BreadCrumb> breadCrumb;
  const BreadCrumbWidget({super.key, required this.breadCrumb});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: breadCrumb.map(
        (breadCrumb) {
          return Text(
            breadCrumb.title,
            style: TextStyle(
                color: breadCrumb.isActive ? Colors.blue : Colors.grey),
          );
        },
      ).toList(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("HomePage")),
    );
  }
}
