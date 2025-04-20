import 'package:flutter/material.dart';

class MyAppBarr extends StatefulWidget {

  @override
  State<MyAppBarr> createState() => _MyAppBarrState();
}

class _MyAppBarrState extends State<MyAppBarr> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(onPressed: () {}, icon: Icon(Icons.arrow_back_ios)),
    );
  }
}
