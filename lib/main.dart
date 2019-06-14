import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import './ListOfPhotos.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Unsplash Images'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _fetchedData;
  bool _errorWhileLoading = false;
  bool _isLoading;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.black87),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchData,
                child: ListOfPhotos(
                  errorWhileLoading: _errorWhileLoading,
                  fetchedData: _fetchedData,
                ),
              ));
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var response = await http.get(
          'http://api.unsplash.com/photos/?client_id=cf49c08b444ff4cb9e4d126b7e9f7513ba1ee58de7906e4360afc1a33d1bf4c0');
      var decodedResponse = json.decode(response.body);
      setState(() {
        _fetchedData = decodedResponse;
        _errorWhileLoading = false;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorWhileLoading = true;
        _isLoading = false;
      });
      Scaffold.of(context).showSnackBar(new SnackBar(content: Text(error.toString())));
    }
  }
}
