import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  List<Complaint> complaints = [];
  String userRole = 'User';
  String username = '';

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    _getComplaintsForUser();
  }

  Future<void> _getUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedUserRole = prefs.getString('loggedInUserRole');
    final String? storedUsername = prefs.getString('loggedInUsername');
    if (storedUserRole != null) {
      setState(() {
        userRole = storedUserRole;
      });
    }
    if (storedUsername != null) {
      setState(() {
        username = storedUsername;
      });
    }
  }

  Future<void> _getComplaintsForUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? complaintsJson = prefs.getStringList('userComplaints_$username');
    if (complaintsJson != null) {
      setState(() {
        complaints = complaintsJson.map((json) => Complaint.fromJson(jsonDecode(json))).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaint Portal - $userRole'),
      ),
      body: ListView.builder(
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        if (userRole == 'Admin') {
          return _buildComplaintCard(complaints[index]);
        } else if (complaints[index].username == username) {
          return _buildComplaintCard(complaints[index]);
        } else {
          return SizedBox();
        }
      },
    ),
      floatingActionButton: userRole != 'Admin' ? FloatingActionButton(
        onPressed: () {
          _showComplaintForm();
        },
        child: const Icon(Icons.add),
      ) : null,
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    return Card(
      child: ListTile(
        title: Text(complaint.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(complaint.summary),
            Text('Severity: ${complaint.severity}'),
          ],
        ),
      ),
    );
  }

  void _showComplaintForm() {
    String title = '';
    String summary = '';
    String severity = 'Low';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submit Complaint'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => title = value,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                onChanged: (value) => summary = value,
                decoration: InputDecoration(labelText: 'Summary'),
              ),
              DropdownButtonFormField<String>(
                value: severity,
                onChanged: (value) {
                  if (value != null) {
                    severity = value;
                  }
                },
                items: ['Low', 'Medium', 'High']
                    .map((severity) => DropdownMenuItem(
                  value: severity,
                  child: Text(severity),
                ))
                    .toList(),
                decoration: InputDecoration(labelText: 'Severity'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  final newComplaint = Complaint(
                    title: title,
                    summary: summary,
                    severity: severity,
                    username: username, // Use the username for the Complaint
                  );
                  complaints.add(newComplaint);
                  _saveComplaintsToSharedPreferences();
                });
                Navigator.of(context).pop();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveComplaintsToSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> complaintsJson = complaints.map((complaint) => json.encode(complaint.toJson())).toList();
    await prefs.setStringList('userComplaints_$username', complaintsJson);
  }
}

class Complaint {
  final String title;
  final String summary;
  final String severity;
  final String username;

  Complaint({
    required this.title,
    required this.summary,
    required this.severity,
    required this.username,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'severity': severity,
      'username': username,
    };
  }

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      title: json['title'],
      summary: json['summary'],
      severity: json['severity'],
      username: json['username'],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: WelcomePage(),
  ));
}
