import 'package:flutter/material.dart';
import 'package:insta_clone/searchedUsers/thisUserPosts.dart';
import 'package:insta_clone/searchedUsers/thisUsersReels.dart';
import 'package:insta_clone/searchedUsers/thisUsersTag.dart';

class Searcheduserprofilepage extends StatefulWidget {

  final Map<String,dynamic> user;
  Searcheduserprofilepage({required this.user});

  @override
  State<Searcheduserprofilepage> createState() => _SearcheduserprofilepageState();
}

class _SearcheduserprofilepageState extends State<Searcheduserprofilepage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 40,right: 20,top: 10),
            child: Row(
              children: [
                Text(
                  widget.user['user_name'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(onPressed: (){}, icon: Icon(Icons.add_box_outlined,color: Colors.white,size: 30,)),
                IconButton(onPressed: (){}, icon: Icon(Icons.menu,color: Colors.white,size: 35,)),
              ],
            ),
          ),
          SizedBox(height: 30,),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/default.png'),
                  ),
                  SizedBox(width: 20,),
                  Container(
                    width: MediaQuery.of(context).size.width*0.6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user['name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 30,),
                        Row(
                          children: [
                            Expanded(
                              flex:2,
                              child: Column(
                                crossAxisAlignment:CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "0",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),Text(
                                    "Post",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment:CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "0",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),Text(
                                    "Followers",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment:CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "0",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ), Text(
                                    "Following",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.only(left: 20,right: 20),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white24,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: (){
                      },
                      child: Text(
                        "Follow",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5,),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white24,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: (){
                      },
                      child: Text(
                        "Message",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30,),
          DefaultTabController(
            length: 3,
            child: Expanded(
              child: Column(
                children: [
                  TabBar(
                    tabs:[
                      Tab(icon: Icon(Icons.grid_on_rounded,color: Colors.white,),),
                      Tab(icon: Icon(Icons.slow_motion_video_sharp,color: Colors.white,),),
                      Tab(icon: Icon(Icons.person_2_outlined,color: Colors.white,),),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                        children:[
                          Thisuserposts(user: widget.user,),
                          Thisusersreels(user: widget.user,),
                          Thisuserstag(),
                        ]
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }
}
