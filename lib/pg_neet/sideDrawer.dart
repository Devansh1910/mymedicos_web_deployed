import 'package:flutter/material.dart';

class sideDrawer extends StatefulWidget {
  final int initialIndex; // Add this line

  sideDrawer({required this.initialIndex}); // Add this constructor

  @override
  _sideDrawerState createState() => _sideDrawerState();
}

class _sideDrawerState extends State<sideDrawer> {
  late int _selectedIndex; // Change this line

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Add this line
  }

  void _onItemTapped(int index, String routeName) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.grey[200],
      child: Column(
        children: [
          UserHeader(),
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

class UserHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Replace with actual user image
          ),
          SizedBox(width: 8),
          Text(
            'Devansh Saxena',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
