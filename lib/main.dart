import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => BreadCrumbProvider(),
      child: MaterialApp(
        title: 'Flutter_provider',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(),
        routes: {
          '/new': (context) => const NewBreadCrumbScreen(),
        },
      ),
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
  UnmodifiableListView<BreadCrumb> get items => UnmodifiableListView(_items);

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
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Consumer<BreadCrumbProvider>(builder: (context, value, child) {
                return BreadCrumbWidget(
                  breadCrumb: value.items,
                );
              }),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/new');
                  },
                  child: const Text("Add a bread crumb")),
              TextButton(
                  onPressed: () {
                    //here we are communicating to the provider and asking it to
                    //perform the specified task
                    // the BuildContext is needed to give the provider access to
                    // the widget's surrounding environment.
                    context.read<BreadCrumbProvider>().removeBreadCrumb();

                    //read() is used to grab a widget instance from the widget
                    //tree so you need to give it a sort of map to find it,
                    //context has that info so that's why you invoke read() on it
                  },
                  child: const Text("Reset"))
            ],
          ),
        ],
      ),
    );
  }
}

class NewBreadCrumbScreen extends StatefulWidget {
  const NewBreadCrumbScreen({super.key});

  @override
  State<NewBreadCrumbScreen> createState() => _NewBreadCrumbScreenState();
}

class _NewBreadCrumbScreenState extends State<NewBreadCrumbScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new bread crumb"),
      ),
      body: Column(children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: "Enter a new bread crumb",
          ),
        ),
        TextButton(
          onPressed: () {
            final name = _controller.text;
            if (name.isNotEmpty) {
              final breadCrumb = BreadCrumb(isActive: false, name: name);
              context.read<BreadCrumbProvider>().addBreadCrumb(breadCrumb);
            }
            Navigator.pop(context);
          },
          child: const Text("Add"),
        ),
      ]),
    );
  }
}
