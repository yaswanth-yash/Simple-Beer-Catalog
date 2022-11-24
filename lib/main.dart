import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scrollController = ScrollController();

  bool isLoadingmore = false;
  int screen = 10;
  List beer = [];
  bool loading = true;
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListerner);
    getData();
  }

  Future<void> getData({bool isRefresh = false}) async {
    if (isRefresh) {}
    final Uri uri = Uri.parse(
        "https://random-data-api.com/api/v2/beers?size=10&response_type=json");
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List;
      setState(() {
        beer = beer + json;
      });
    } else {
      print("error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Beers",
          ),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                    (Route<dynamic> route) => false,
                  );
                },
                icon: Icon(Icons.refresh))
          ],
          backgroundColor: Color.fromARGB(255, 3, 4, 94),
          // backgroundColor: Colors.blueAccent,
        ),
        body: ListView.builder(
            padding: EdgeInsets.all(20),
            controller: scrollController,
            itemCount: isLoadingmore ? beer.length + 1 : beer.length,
            itemBuilder: ((context, index) {
              if (index < beer.length) {
                final beers = beer[index];
                final alcohol = beers['alcohol'];
                print(alcohol);
                final name = beers['name'];
                final brand = beers['brand'];
                final style = beers['style'];
                print(alcohol.runtimeType);

                String alc = alcohol.substring(0, 3);
                var r = double.parse(alc);
                return Column(
                  children: <Widget>[
                    ListTile(
                      tileColor: Colors.white38,
                      contentPadding: EdgeInsets.all(5),
                      title: Text(
                        '$name' '\t' 'by' '\t' '$brand',
                        style: TextStyle(
                          fontSize: 17,
                          color: (r > 5.0 ? Colors.redAccent : Colors.green),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      minVerticalPadding: 2,
                      subtitle: Text(
                        '$style',
                        style: TextStyle(color: Colors.black),
                      ),
                      trailing: Text('$alcohol' '\n' 'Alcohol',
                          style: TextStyle(
                            fontSize: 15,
                            // color: Colors.white,
                            color: (r > 5.0 ? Colors.redAccent : Colors.green),
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    Divider(),
                  ],
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            })));
  }

  Future<void> _scrollListerner() async {
    if (isLoadingmore) return;
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      setState(() {
        isLoadingmore = true;
      });
      screen = screen + 10;
      await getData();
      setState(() {
        isLoadingmore = false;
      });
    }
  }
}
