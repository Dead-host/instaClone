import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta_clone/messagess/messages.dart';
import 'package:insta_clone/searchedUsers/searchedUserProfilePage.dart';
import 'package:insta_clone/story/postStory.dart';
import 'package:insta_clone/story/viewStoryPage.dart';
import 'package:readmore/readmore.dart';

class Userhome extends StatefulWidget {
  const Userhome({super.key});

  @override
  State<Userhome> createState() => _UserhomeState();
}

class _UserhomeState extends State<Userhome> {

  Future<void> addComment({required String postId, required String ownerUid, required String commentText,}) async {
    final user = FirebaseAuth.instance.currentUser!;
    final uid = user.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userName = userDoc.data()?['user_name'] ?? 'Anonymous';


    final newCommentBlock = {
      'users': {
        'id': uid,
        'name': userName,
      },
      'comment': [
        {
          'comment': commentText,
          'time': DateTime.now().toIso8601String(),
          'like': 0,
        }
      ]
    };

    final postRefGlobal = FirebaseFirestore.instance.collection('posts').doc(postId);
    final postRefUser = FirebaseFirestore.instance
        .collection('users')
        .doc(ownerUid)
        .collection('posts')
        .doc(postId);

    await postRefGlobal.update({
      'comments': FieldValue.arrayUnion([newCommentBlock])
    });

    await postRefUser.update({
      'comments': FieldValue.arrayUnion([newCommentBlock])
    });
  }

  void showCommentSheet({required String postId, required String ownerUid, }) {
    final TextEditingController _commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Post Preview
              Row(
                children: [
                  Text(
                    "Comments",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              SizedBox(height: 10),

              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('posts').doc(postId).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final comments = data['comments'] as List<dynamic>? ?? [];

                  List<Widget> commentWidgets = [];

                  for (var userComment in comments) {
                    final userName = userComment['users']['name'] ?? "Unknown";
                    final commentList = userComment['comment'] as List<dynamic>;

                    for (var c in commentList) {
                      commentWidgets.add(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.account_circle, color: Colors.white, size: 28),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: "$userName ",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: c['comment'] ?? '',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }
                  }

                  return Container(
                    height: 300,
                    child: ListView(
                      shrinkWrap: true,
                      children: commentWidgets,
                    ),
                  );
                },
              ),

              Divider(color: Colors.white24),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blue),
                    onPressed: () async {
                      final text = _commentController.text.trim();
                      if (text.isNotEmpty) {
                        await addComment(
                          postId: postId,
                          ownerUid: ownerUid,
                          commentText: text,
                        );
                        Navigator.pop(context);
                        showCommentSheet(
                          postId: postId,
                          ownerUid: ownerUid,
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  final currentUser = FirebaseAuth.instance.currentUser!;

  Future<void> toggleLike(String postId, String ownerUid) async {

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    final userPostRef = FirebaseFirestore.instance
        .collection('users')
        .doc(ownerUid)
        .collection('posts')
        .doc(postId);

    final snapshot = await postRef.get();

    final List likes = snapshot.data()?['likes'] ?? [];

    final isLiked = likes.contains(uid);

    if (isLiked) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([uid])
      });
      await userPostRef.update({
        'likes': FieldValue.arrayRemove([uid])
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([uid])
      });
      await userPostRef.update({
        'likes': FieldValue.arrayUnion([uid])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.black,
      body:SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 20),
              child: Row(
                children: [
                  Image(
                    image: AssetImage('assets/logo.jpeg'),
                    height: 50,
                  ),
        
                  Spacer(),
                  IconButton(
                    onPressed: (){},
                    icon: Icon(Icons.favorite_border),
                    color: Colors.white,
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Messages()));
                    },
                      child: Image.asset('assets/message.jpg',height: 50,)
                  ),
                ],
              ),
            ),
            SizedBox(height: 40,),
            //story
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage('assets/default.png'),
                        ),
                        Positioned(
                          bottom: 30,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => Poststory()));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: Colors.grey),
                              ),
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.add, size: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('stories').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Something went wrong'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      return Row(
                        children: docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final List stories = data['stories'] ?? [];
                          if (stories.isEmpty) return SizedBox();

                          final userName = data['user_name'];

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final storySnapshot = await FirebaseFirestore.instance.collection('stories').get();

                                    List<Map<String,dynamic>> allStories=[];
                                    int startIndex=0;
                                    int counter=0;

                                    for(var doc in storySnapshot.docs){
                                      final userData = doc.data() as Map<String,dynamic>;
                                      final userName = userData['user_name'];
                                      final List<dynamic> userStories= userData['stories']??[];

                                      for(var story in userStories){
                                        allStories.add({
                                          ...story,
                                          'user_name':userName,
                                        });

                                        if(userName==data['user_name']&& story==userStories.first){
                                          startIndex=counter;
                                        }
                                        counter++;
                                      }
                                    }
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Viewstorypage(stories: allStories,initialIndex: startIndex, )));
                                  },
                                  child: CircleAvatar(
                                    radius: 35,
                                    backgroundImage: AssetImage('assets/default.png'),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  userName,
                                  style: TextStyle(color: Colors.white, fontSize: 15),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
            //posts
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('posts').snapshots(),
                builder: (context,snapshot){
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }
            
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
            
                  final docs= snapshot.data!.docs;

            
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                      mainAxisSpacing: 10,
                      childAspectRatio:0.75,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context,index){
                      final data = docs[index].data()as Map<String,dynamic>;
            
                      return Container(
                        height: 500,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Searcheduserprofilepage(user: data)));
                                },
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: AssetImage('assets/default.png'),

                                    ),
                                    SizedBox(width: 10,),
                                    Text(
                                      data['user']['user_name']?? '',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            Expanded(
                                child:data['image'] != null && data['image'] != ""
                                    ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.memory(
                                        base64Decode(data['image'],),
                                        width: MediaQuery.of(context).size.width,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ):Icon(Icons.image),
                            ),
                            SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.only(left: 5,right: 10),
                              child: Row(
                                mainAxisAlignment : MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                          onPressed: (){
                                            toggleLike(data['postId'], data['user']['uid']);
                                          },
                                          icon: Icon(
                                            data['likes'] != null && data['likes'].contains(currentUser.uid)
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: data['likes'] != null && data['likes'].contains(currentUser.uid)
                                                ? Colors.red
                                                : Colors.white,
                                          )
                                      ),
                                      Text(
                                        data['likes'].length.toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: GestureDetector(
                                            child: Image.asset('assets/comment.png',height: 40,),
                                          onTap: (){
                                              showCommentSheet(
                                                postId: data['postId'],
                                                ownerUid: data['user']['uid'],
                                              );
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: GestureDetector(
                                            child: Image.asset('assets/share.png',height: 35,),
                                        ),
                                      ),

                                    ],
                                  ),
                                  IconButton(
                                      onPressed: (){},
                                      icon: Icon(Icons.bookmark_border_outlined,color: Colors.white,size: 25,)
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                children: [
                                  Text(
                                      data['user']['user_name']??"",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Text(
                                    data['description'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 40,),
                          ],
                        ),
                      );
                    },
                  );
            
                },
            )
          ],
        ),
      ),
    ));
  }
}
