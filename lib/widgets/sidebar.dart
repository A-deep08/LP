import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:study_mate/pages/signup_page.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String username = 'Username';
  @override
  void initState() {
    super.initState();
    setusername();
  }

  Future<void> setusername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Username';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
           Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/images/EMbg.jpg'),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text('View Profile'),
                ],
              ),
            ],
          ),
          const Divider(),
          const ListTile(title: Text('Recent files')),
          const ListTile(title: Text('Theme')),
          const ListTile(title: Text('Starred')),
          const ListTile(title: Text('Account settings')),
          const SizedBox(height: 10),
          const ListTile(
            leading: Icon(Icons.help_center),
            title: Text('Help and feedback'),
          ),
          const Divider(),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => SignupPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
