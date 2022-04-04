import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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
      title: 'Flutter photoReader',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {
  File? image;

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() => this.image = imageTemporary);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future sendToServer() async {
    try{
      //var request = http.MultipartRequest("POST", Uri.parse("https://gourmet.hopto.org:5000/meals"));
      //request.fields["mealName"] = jsonEncode("XD");
      //create multipart using filepath, string or bytes
        //print(request.url.host); // 10.0.0.1
        //print(request.url.port); // 6100
        //print(request.url.path); // get_status
        //request.fields["mealPhoto"] = jsonEncode( image!.toString() );
      //var pic = await http.MultipartFile.fromPath("mealPhoto", image!.path );
      //add multipart to request
      //request.files.add(pic);

      //Map<String, String> requestHeaders = {
       //'Content-type': 'application/json',
       //'Accept': 'application/json'
      //};

      //request.headers.addAll(requestHeaders);

      //var response = await request.send();

      //Get the response from the server
      //var responseData = await response.stream.toBytes();
      //var responseString = String.fromCharCodes(responseData);

        final uri = Uri.parse("https://gourmet.hopto.org:5000/meals");
        final headers = {'Content-Type': 'application/json'};
        Map<String, dynamic> body = {'mealName': "super", 'mealPhoto': image!.toString()};
        String jsonBody = json.encode(body);
        final encoding = Encoding.getByName('utf-8');

  var response = await http.post(
    uri,
    headers: headers,
    body: jsonBody,
    encoding: encoding,
  );

  int statusCode = response.statusCode;
  String responseBody = response.body;



      print(responseBody);
      print(statusCode);

      print("OK");

  } on PlatformException catch (e) {
      print('Failed to send to server: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            image != null 
            ? ClipOval(
              child: Image.file(
                image!,
                width: 160,
                height: 160,
                fit: BoxFit.cover,
              ),
            )
              : FlutterLogo(size: 160),
            const SizedBox(height: 24),
            Text(
              'Gourmet',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48), 
            buildButton(
              title: 'Pick Gallery',
              icon: Icons.image_outlined,
              onClicked: () => pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 24), 
            buildButton(
              title: 'Pick Camera',
              icon: Icons.camera_alt_outlined,
              onClicked: () => pickImage(ImageSource.camera),
            ),
            const SizedBox(height: 24), 
            buildButton(
              title: 'Submit',
              icon: Icons.send,
              onClicked: () => sendToServer(),
            ),
          ],
        ),
      ),
    );
  }
    Widget buildButton({
    required String title,
    required IconData icon,
    required VoidCallback onClicked,
  }) =>
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(56),
          primary: Colors.white,
          onPrimary: Colors.black,
          textStyle: TextStyle(fontSize: 20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 16),
            Text(title),
          ],
        ),
        onPressed: onClicked,
      );
}
