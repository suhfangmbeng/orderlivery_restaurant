

import 'package:Restaurant/drawer.dart';
import 'package:Restaurant/users.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';

class RatingsPage extends StatefulWidget {
  _RatingsPageState createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  @override

  Widget build(BuildContext context) {
    // TODO: implement build
    return DrawerScaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(),
            Text('RATINGS'),
            Padding(
              padding: EdgeInsets.all(10),
              child: Icon(LineIcons.bell),
            )
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}