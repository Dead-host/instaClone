import 'package:flutter/material.dart';

class Usersearch extends StatefulWidget {
  const Usersearch({super.key});

  @override
  State<Usersearch> createState() => _UsersearchState();
}

class _UsersearchState extends State<Usersearch> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("search page"),),
    ));
  }
}
