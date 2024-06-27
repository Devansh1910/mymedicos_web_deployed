import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:mymedicosweb/login/components/login_check.dart';

import 'package:provider/provider.dart';
// Import the UserNotifier class

class SideDrawer extends StatefulWidget {
  final int initialIndex;

  SideDrawer({required this.initialIndex});

  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index, String routeName) {

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
    context.go('$routeName');
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
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
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
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Container(
      width: 200,
      decoration: isLargeScreen
          ? BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey, width: 1.0),
        ),
      )
          : null, // Only apply decoration if isLargeScreen is true
      child: Column(
        children: [
          // UserHeader(),
          ListTile(
            leading: Icon(Icons.home,color: Colors.black,),
            title: Text('Home',style: TextStyle(fontFamily: 'Inter',color: Colors.black),),
            selected: _selectedIndex == 0,
            selectedTileColor: Colors.grey[300],
            onTap: () => _onItemTapped(0, '/homescreen'),
          ),
          ListTile(
            leading: Icon(Icons.school,color: Colors.black,),
            title: Text('NEET PG',style: TextStyle(fontFamily: 'Inter',color: Colors.black),),
            selected: _selectedIndex == 1,
            selectedTileColor: Colors.grey[300],
            onTap: () => _onItemTapped(1, '/pgneet'),
          ),
          ListTile(
            leading: Icon(Icons.book,color: Colors.black,),
            title: Text('FMGE',style: TextStyle(fontFamily: 'Inter',color: Colors.black),),
            selected: _selectedIndex == 2,
            selectedTileColor: Colors.grey[300],
            onTap: () => _onItemTapped(2, '/fmge'),
          ),
          ListTile(
            leading: Icon(Icons.person,color: Colors.black,),
            title: Text('Profile',style: TextStyle(fontFamily: 'Inter',color: Colors.black),),
            selected: _selectedIndex == 3,
            selectedTileColor: Colors.grey[300],
            onTap: () => _onItemTapped(3, '/profile'),
          ),
          Expanded(child: Container()),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout,color: Colors.black,),
            title: Text('Logout',style: TextStyle(fontFamily: 'Inter',color: Colors.black),),
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
