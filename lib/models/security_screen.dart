import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityScreen extends StatefulWidget {
  @override
  _SecurityScreenState createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isFirstLaunch = false;
  bool _isPasswordCorrect = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstLaunch = prefs.getBool('isFirstLaunch');
    if (isFirstLaunch == null || isFirstLaunch) {
      setState(() {
        _isFirstLaunch = true;
      });
    } else {
      setState(() {
        _isFirstLaunch = false;
      });
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _usernameController.clear(); // Ensure the username field is always empty
    _passwordController.clear(); // Ensure the password field is always empty
  }

  Future<void> _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('password', _passwordController.text);
    await prefs.setBool('isFirstLaunch', false);
    Navigator.pushReplacementNamed(context, '/videoSelection');
  }

  Future<void> _verifyPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPassword = prefs.getString('password');

    if (_passwordController.text == storedPassword) {
      setState(() {
        _isPasswordCorrect = true;
      });
      Navigator.pushReplacementNamed(context, '/videoSelection');
    } else {
      setState(() {
        _isPasswordCorrect = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isFirstLaunch ? 'Create Account' : 'Verify Password'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isFirstLaunch) ...[
              Icon(Icons.account_circle, size: 100, color: Colors.blueAccent),
              SizedBox(height: 20),
              Text(
                'Welcome! Please create a username and password.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ] else ...[
              Icon(Icons.lock, size: 100, color: Colors.blueAccent),
              SizedBox(height: 20),
              Text(
                'Welcome back! Please verify your password.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
            SizedBox(height: 20),
            if (_isFirstLaunch)
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            if (_isFirstLaunch) SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_isFirstLaunch) {
                  _saveUserData();
                } else {
                  _verifyPassword();
                }
              },
              child: Text(_isFirstLaunch ? 'Create Account' : 'Verify Password'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (!_isPasswordCorrect)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Incorrect Password',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
