// ignore_for_file: avoid_unnecessary_containers

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Brain tumor classification'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String result = "insert an image";
  var imgbytes = null;
  bool _isloading = false;
  Future<void> _sendImage() async {
    try {
      final pickedFile = await FilePicker.platform.pickFiles();
      var filepath = pickedFile?.files.first;
      var a = filepath!.bytes;

      String base64Image = base64Encode(a!);
      var url = Uri.parse('https://brain-clf-tumor-model.onrender.com');
      var response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            "img": base64Image,
          }));
      if (response.statusCode == 200) {
        print("JSON data sent successfully");
        print("response.body : ${response.body}");
      } else {
        print("Failed to send JSON data");
        print("Response status code: ${response.statusCode}");
      }

      var res = response.body;
      setState(() {
        result = res;
        imgbytes = a;
        _isloading = false;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Brain Tumor classifier"),
        ),
        body: Center(
          child: Column(
            children: [
              imgbytes == null
                  ? const SizedBox(
                      height: 250,
                    )
                  : Container(
                      child: Image.memory(imgbytes),
                    ),
              Text(
                result,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              ),
              MaterialButton(
                  color: Colors.blue,
                  child: _isloading
                      ? const CircularProgressIndicator()
                      : const Text("Pick Image",
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold)),
                  onPressed: () {
                    setState(() {
                      _isloading = true;
                    });
                    _sendImage();
                  }),
            ],
          ),
        ));
  }
}
