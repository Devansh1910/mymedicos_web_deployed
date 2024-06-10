import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppDrawer extends StatefulWidget {
  final int initialIndex;

  AppDrawer({required this.initialIndex});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index, String routeName) {
    if (_selectedIndex == index) {
      Fluttertoast.showToast(
        msg: "Already on this screen",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
      Navigator.pushReplacementNamed(context, routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // UserHeader(), // Uncomment this if you have a UserHeader widget
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            selected: _selectedIndex == 0,
            selectedTileColor: Colors.green,
            onTap: () => _onItemTapped(0, '/homescreen'),
          ),
          ListTile(
            leading: Icon(Icons.school),
            title: Text('PG Neet'),
            selected: _selectedIndex == 1,
            selectedTileColor: Colors.green,
            onTap: () => _onItemTapped(1, '/pgneet'),
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('FMGE'),
            selected: _selectedIndex == 2,
            selectedTileColor: Colors.green,
            onTap: () => _onItemTapped(2, '/fmge'),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            selected: _selectedIndex == 3,
            selectedTileColor: Colors.green,
            onTap: () => _onItemTapped(3, '/profile'),
          ),
        ],
      ),
    );
  }
}
