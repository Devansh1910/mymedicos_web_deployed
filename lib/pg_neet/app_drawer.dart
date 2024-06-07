import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          ListTile(
            title: Text('Home', style: TextStyle(fontFamily: "Inter")),
            onTap: () {
              Navigator.pushNamed(context, '/homescreen');
            },
          ),
          ListTile(
            title: Text(
              'PG Neet',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontFamily: 'Inter',
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/pgneet');
            },
            tileColor: Colors.grey,
          ),
          ListTile(
            title: Text('FMGE', style: TextStyle(fontFamily: "Inter")),
            onTap: () {

            },
          ),
        ],
      ),
    );
  }
}

