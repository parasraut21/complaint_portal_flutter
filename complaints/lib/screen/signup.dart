import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class SignUp extends StatefulWidget {
  SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedUserRole = 'User';

  Future<void> _createAccount() async {
    final String username = usernameController.text;
    final String password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> storedUsernames = prefs.getStringList('usernames') ?? [];
      List<String> storedPasswords = prefs.getStringList('passwords') ?? [];
      List<String> storedUserRoles = prefs.getStringList('userRoles') ?? [];

      storedUsernames.add(username);
      storedPasswords.add(password);
      storedUserRoles.add(selectedUserRole!);

      await prefs.setStringList('usernames', storedUsernames);
      await prefs.setStringList('passwords', storedPasswords);
      await prefs.setStringList('userRoles', storedUserRoles);

      print('Account created: username=$username, password=$password, role=$selectedUserRole');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account successfully created!')),
      );


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LogIn()),
      );
    } catch (e) {
      print('Error saving account: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create account. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            DropdownButtonFormField<String>(
              value: selectedUserRole,
              onChanged: (String? newValue) {
                setState(() {
                  selectedUserRole = newValue;
                });
              },
              items: ['User', 'Admin']
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ),
              )
                  .toList(),
              decoration: InputDecoration(labelText: 'Role'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _createAccount,
              child: Text('Create Account'),
            ),
            SizedBox(height: 8.0),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => LogIn(),
                  ),
                );
              },
              child: Text('Already have an account? Log in'),
            ),
          ],
        ),
      ),
    );
  }
}
