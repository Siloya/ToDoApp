import 'package:flutter/material.dart';
import 'ToDoPage.dart';
import 'DatabaseHelper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

//void main() => runApp(MyApp());
/*void main() async {
// Initialize FFI
  sqfliteFfiInit();
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database factory
  databaseFactory = databaseFactoryFfi;
  runApp(MyApp());
}*/
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize SQLite FFI bindings
  //sqfliteFfiInit();
  // Initialize the database factory
 // databaseFactory = databaseFactoryFfi;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'IDO',
          style: TextStyle(
            color: Color(0xff4e3169), // Customize the text color
            fontSize: 24, // Adjust the font size to increase width
            fontWeight: FontWeight.bold, // Optionally adjust font weight
          ),
        ),
        backgroundColor: Colors.black, // Customize the app bar color
      ),
      body: Container(
        //color: Color(0xff4d034d),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'lib/images/doit.png'), // Replace 'background_image.jpg' with your image file path
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'i can do it!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  handleLogin(context);
                  // Handle login button press
                },
                child: Text('SIGN IN'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleLogin(BuildContext context) {
    if ((_usernameController.text == 'najah' &&
        _passwordController.text == 'najah123') ||
        true) {
      // Navigate to a new page or perform an action
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ToDoListPage()), //ToDoListPage
      );
    } else {
      // Handle incorrect username or password
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Invalid username or password'),
      ));
    }
  }
}