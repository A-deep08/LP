import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_mate/app/modules/login/views/login_view.dart';

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
    setUsername();
  }

  Future<void> setUsername() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      username = prefs.getString('username') ?? 'Username';
    });
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktopMode =
        kIsWeb || MediaQuery.of(context).size.width >= 900;

    final Widget sidebarContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/EMbg.jpg'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Text(
                      'View Profile',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const Divider(),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
            children: [
              const ListTile(title: Text('Recent files')),
              const ListTile(title: Text('Theme')),
              const ListTile(title: Text('Starred')),
              const ListTile(title: Text('Account settings')),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.help_center),
                title: Text('Help and feedback'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Logout'),
                onTap: logout,
              ),
            ],
          ),
        ),
      ],
    );

    
    if (isDesktopMode) {
      return Material(
        elevation: 8,
        shadowColor: Colors.black26,
        child: SizedBox(
          width: 260,
          height: MediaQuery.of(context).size.height,
          child: sidebarContent,
        ),
      );
    }

    
    return Drawer(child: sidebarContent);
  }
}
