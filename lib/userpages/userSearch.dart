import 'package:flutter/material.dart';
import 'package:insta_clone/userpages/searchUsers.dart';

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20,right: 20,top: 40),
            child: GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Searchusers()));
              },
              child: Container(
                height: 35,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white24,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Icon(Icons.search,color: Colors.white,),
                    ),
                    SizedBox(width: 10,),
                    Text(
                      "Search",
                      style: TextStyle(color: Colors.white),
                    ),

                  ],
                ),
              )
            ),
          ),
        ],
      ),
    ));
  }
}
