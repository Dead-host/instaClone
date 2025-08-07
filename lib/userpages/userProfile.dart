import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta_clone/profilePage/userKoReelsHaru.dart';
import 'package:insta_clone/profilePage/userKoTagsHaru.dart';

import '../profilePage/userKoPostHaru.dart';

class Userprofile extends StatefulWidget {
  const Userprofile({super.key});

  @override
  State<Userprofile> createState() => _UserprofileState();
}

class _UserprofileState extends State<Userprofile> {

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? userName;
  String? fullName;
  int? post;
  List followers=[];
  List following=[];


  Future<void> getUser()async{
    try{
      final User? user = auth.currentUser;
      final uid = user!.uid;
      DocumentSnapshot data = await firestore.collection('users').doc(uid).get();
      setState(() {
        userName=data.get('user_name');
        fullName=data.get('name');
        post=data.get('post');
        followers=data.get('followers');
        following=data.get('following');
      });
    }catch(e){print(e);}
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     getUser();
  }

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
                  userName.toString(),
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
                            fullName.toString(),
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
                                      post.toString(),
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
                                      followers.isEmpty?"0":followers!.length.toString(),
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
                                      following.isEmpty?"0":following!.length.toString(),
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
                            Userposts(),
                            Userreels(),
                            Usertags(),
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
