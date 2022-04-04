import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Flutter photoReader',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const MyHomePage(title: 'The Gourmet'),
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
  TextEditingController inputText = new TextEditingController();

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source, imageQuality: 10);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() => this.image = imageTemporary);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future sendToServer() async {
    try{
      

        final uri = Uri.parse("https://gourmet.hopto.org:5000/meals");
        final headers = {'Content-Type': 'application/json'};


        final bytes = File(image!.path).readAsBytesSync();
        String base64Image = base64Encode(bytes);


        Map<String, dynamic> body = {'mealName': inputText.text.toString(), 'mealPhoto': base64Image};
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


  Future categorizeThePhoto() async {
    try{
      

        final uri = Uri.parse("https://gourmet.hopto.org:5000/model");
        final headers = {'Content-Type': 'application/json'};


        final bytes = File(image!.path).readAsBytesSync();
        String base64Image = base64Encode(bytes);


        Map<String, dynamic> body = { 'mealPhoto': base64Image};
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
            ? ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.file(
                image!,
                width: 240,
                height: 240,
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


             Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TypeAheadField<Suggestions?>(
              hideSuggestionsOnKeyboardHide: true,
              debounceDuration: Duration(milliseconds: 500),
              textFieldConfiguration: TextFieldConfiguration(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  hintText: 'podaj nazwe potrawy',
                ),
                controller: this.inputText,
              ),


              suggestionsCallback: SuggestionsApi.getSuggestionsSuggestions,
              itemBuilder: (context, Suggestions? suggestion) {
                final hint = suggestion;
                return ListTile(
                  title: Text(hint!.suggest.toString()),
                );
              },
              noItemsFoundBuilder: (context) => Container(
                height: 40,
                child: Center(
                  child: Text(
                    'Brak potraw w bazie',
                  ),
                ),
              ),
              
              onSuggestionSelected: (Suggestions? suggestion){
                final potrawa = suggestion!;
                inputText.text = potrawa.suggest;
                ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text('Podano potrawe: ${potrawa.suggest}'),
                ));
                 child: TextField(
                controller: inputText,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'podaj nazwe potrawy',
                  ),  
                );
              },
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
             const SizedBox(height: 24), 
            buildButton(
              title: 'Recognize the photo',
              icon: Icons.cookie_sharp,
              onClicked: () => categorizeThePhoto(),
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

class SuggestionsApi {

  static Future <List<Suggestions>> getSuggestionsSuggestions(String query) async{
    final url = Uri.parse('https://gourmet.hopto.org:5000/suggestions');
    final response = await http.get(url);

    if(response.statusCode == 200){
      final List suggestions = json.decode( response.body );

      return suggestions.map((json) => Suggestions.fromJson(json)).where((suggestion) {
        final suggestionLower =suggestion.suggest.toString().toLowerCase();
        final queryLower =query.toString().toLowerCase();

        return suggestionLower.contains(queryLower);
      } ).toList();
    } else {
      throw Exception();
    }
  }

}

class Suggestions {
  String suggest = "";

  Suggestions({
    required this.suggest,
  });

  static Suggestions fromJson(String json) => Suggestions(
    suggest: json,
  );
}
