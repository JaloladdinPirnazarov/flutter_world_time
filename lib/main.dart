import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_world_time/timesData.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World time',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String location = "";
  bool isLoading = false;
  TextEditingController _searchController = TextEditingController();
  List<String> allLocations = [
    'London',
    'Paris',
    'Rome',
    'Madrid',
    'Berlin',
    'Dublin',
    'Amsterdam',
    'Prague',
    'Budapest',
    'Stockholm',
    'Warsaw',
    'Copenhagen',
    'Brussels',
    'Bucharest',
    'Sofia',
    'Reykjavik',
    'Moscow',
    'Istanbul',
    'Zurich',
    'Geneva',
    'Edinburgh',
    'Barcelona',
    'Athens',
    'Belgrade',
    'Oslo',
    'Helsinki',
    'Vienna',
    'Riga',
    'Tallinn',
    'Vilnius',
    'Zagreb',
    'Ljubljana',
    'Valletta',
    'Created by Jaloladdin'
  ];

  List<String> locations = [];

  @override
  void initState() {
    locations = allLocations;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('World time'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 10, top: 20, right: 10),
              padding: EdgeInsets.symmetric(
                vertical: 3,
              ),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Row(
                children: [
                  SizedBox(width: 8),
                  // Промежуток между краем контейнера и иконкой
                  Icon(
                    Icons.search,
                    color: Colors.blue,
                    size: 34,
                  ),
                  // Иконка
                  SizedBox(width: 8),
                  // Промежуток между иконкой и TextFormField
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: TextFormField(
                        controller: _searchController,
                        textAlign: TextAlign.center,
                        onChanged: (searchText) {
                          search(searchText);
                          print(searchText);
                        },
                        style: TextStyle(color: Colors.black, fontSize: 32),
                        decoration: InputDecoration(
                          hintText: 'City name',
                          hintStyle:
                              TextStyle(fontSize: 32, color: Colors.black),
                          alignLabelWithHint: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                      onPressed: () {
                        _searchController.clear();
                        search("");
                      },
                      icon: Icon(
                        Icons.clear,
                        color: Colors.red,
                        size: 32,
                      ))
                ],
              ),
            ),
            Expanded(
                child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: locations.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            if (index != locations.length - 1 && !isLoading) {
                              location = locations[index];
                              fetchData();
                            }
                          },
                          child: Container(
                              margin:
                                  EdgeInsets.only(left: 10, top: 20, right: 10),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Center(
                                child: Text(
                                  locations[index],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 32,
                                  ),
                                ),
                              )),
                        );
                      }),
                ),
                Positioned(
                    child: Center(
                  child: isLoading ? CircularProgressIndicator() : Container(),
                ))
              ],
            ))
          ],
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  void search(String searchText) {
    print("search");
    List<String> similarWords = [];

    for (int i = 0; i < allLocations.length; i++) {
      if (lowerCase(allLocations[i]).contains(lowerCase(searchText)) &&
          i != allLocations.length - 1) {
        similarWords.add(allLocations[i]);
      }
    }

    similarWords.add(allLocations[allLocations.length - 1]);
    setState(() {
      locations = similarWords;
    });
  }

  String lowerCase(String word) {
    String lowerCasedWord = "";
    for (int i = 0; i < word.length; i++) {
      lowerCasedWord += word[i].toLowerCase();
    }
    return lowerCasedWord;
  }

  void showAlert(BuildContext context, Icon icon, String title, String message,
      bool isError) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              icon,
              SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            isError
                ? TextButton(
                    onPressed: () {
                      fetchData();
                      Navigator.of(context).pop();
                    },
                    child: Text("retry"))
                : Text(""),
            TextButton(
              child: Text('close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String formatter(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDateTime =
        DateFormat('hh:mm   dd.MM.yyyy').format(dateTime);
    return formattedDateTime;
  }

  void fetchData() async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(
        "https://timezone.abstractapi.com/v1/current_time/?api_key=b720a0fa090f46d0a0f56e955e93ccc3&location=$location");

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = TimeData.fromRawJson(response.body);
        showAlert(
            context,
            Icon(
              Icons.access_time,
              color: Colors.green,
            ),
            location,
            formatter(data.datetime.toString()),
            false);
        print("data ${data}");
      } else {
        showAlert(
            context,
            Icon(
              Icons.error,
              color: Colors.red,
            ),
            "Error",
            "Reason: $response\n\nStatus code: ${response.statusCode}",
            true);
        print('Ошибка запроса: ${response.statusCode}');
      }
    } catch (e) {
      showAlert(
          context,
          Icon(
            Icons.error,
            color: Colors.red,
          ),
          "Error",
          "Reason: $e\n\nCheck your internet connection",
          true);
      print('Произошла ошибка: $e\n\nCheck your internet connection');
    }

    setState(() {
      isLoading = false;
    });
  }
}
