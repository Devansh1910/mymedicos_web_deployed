import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mymedicosweb/login/components/login_check.dart';
import 'package:provider/provider.dart';
// Import the UserNotifier class

class sideDrawer extends StatefulWidget {
  final int initialIndex;

  sideDrawer({required this.initialIndex});

  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<sideDrawer> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index, String routeName) {
    if (index == 2) { // Check if FMGE is tapped
      Fluttertoast.showToast(
        msg: "This feature is currently not available",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return; // Don't change the selected index or navigate
    }

    if (_selectedIndex == index) {
      Fluttertoast.showToast(
        msg: "You are already on this page",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
    Navigator.pushReplacementNamed(context, routeName);
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    final userNotifier = Provider.of<UserNotifier>(context, listen: false);
    userNotifier.logOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.white,
      child: Column(
        children: [
          // UserHeader(),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            selected: _selectedIndex == 0,
            selectedTileColor: Colors.green,
            onTap: () => _onItemTapped(0, '/homescreen'),
          ),
          ListTile(
            leading: Icon(Icons.school),
            title: Text('NEET PG'),
            selected: _selectedIndex == 1,
            selectedTileColor: Colors.green,
            onTap: () => _onItemTapped(1, '/pgneet'),
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('FMGE'),
            selected: _selectedIndex == 2,
            selectedTileColor: Colors.green,
            onTap: () => _onItemTapped(2, ''), // Pass an empty string for routeName
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            selected: _selectedIndex == 3,
            selectedTileColor: Colors.green,
            onTap: () => _onItemTapped(3, '/profile'),
          ),
          Expanded(child: Container()), // Takes up the remaining space
          Divider(), // Optional: adds a divider before the logout button
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: _confirmLogout,
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
