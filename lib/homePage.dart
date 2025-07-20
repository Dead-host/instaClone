import 'package:flutter/material.dart';
import 'package:insta_clone/userpages/userHome.dart';
import 'package:insta_clone/userpages/userPost.dart';
import 'package:insta_clone/userpages/userProfile.dart';
import 'package:insta_clone/userpages/userReel.dart';
import 'package:insta_clone/userpages/userSearch.dart';
import 'package:popover/popover.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  int selectedIndex = 0;

  void navigateBottomBar (int index){
    setState(() {
      selectedIndex=index;
    });
  }

  final List<Widget> _pages = [
    Userhome(),
    Usersearch(),
    Userpost(),
    Userreel(),
    Userprofile(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.black,
      body: _pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: navigateBottomBar,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined,size: 30,),
              label: '',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.search,size: 30,),
              label: ''
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined,size: 30,),
              label: ''
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.smart_display_outlined,size: 30,),
              label: '',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline,size: 30,),
              label: ''
          ),

        ],
      ),
    ));
  }
}
