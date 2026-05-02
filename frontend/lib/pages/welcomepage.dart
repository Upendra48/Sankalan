import 'package:flutter/material.dart';
import 'package:trash_map/pages/homepage.dart';
import 'package:trash_map/pages/mappage.dart';
import 'package:trash_map/screens/mapbox.dart';
import 'package:trash_map/screens/options.dart';
import 'package:trash_map/pages/registerpage.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        actionsIconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        titleSpacing: 10.0,
        leading: IconButton(
          icon: Icon(Icons.home),
          iconSize: 30.0,
          color: Colors.white,
          tooltip: 'Refresh',
          onPressed: () {},
        ),
        title: Text('Trash Map'),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.map),
                iconSize: 30.0,
                color: Colors.white,
                tooltip: 'Map',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapScreen()),
                  );
                },
              ),
              SizedBox(width: 20.0),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Registerpage()),
                  );
                },
                icon: Icon(Icons.person_add),
                iconSize: 30.0,
                color: Colors.white,
                tooltip: 'Register',
              ),
            ],
          )
        ],
      ),
      body: Row(
        children: [
          Expanded(flex: 1, child: Options()),
          Expanded(flex: 4, child: Mapbox()),
        ],
      ),
    );
  }
}
