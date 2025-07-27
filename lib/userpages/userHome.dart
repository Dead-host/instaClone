import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta_clone/messages.dart';
import 'package:insta_clone/searchedUsers/searchedUserProfilePage.dart';
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

              // Add Comment Field
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
                        Navigator.pop(context); // Close sheet
                        showCommentSheet( // Re-open to refresh comments
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
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage('assets/default.png'),
        
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: (){},
                          child: Container(
                            decoration: BoxDecoration(
                              shape:BoxShape.circle,
                              color: Colors.white,
                              border:Border.all(color: Colors.grey),
                            ),
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.add,size: 10,),
                          ),
                        ),
                      ),
                    ],
                  ),
                  //here the stack of stories are stored
                ],
              ),
            ),
            SizedBox(height: 40,),
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
                                      IconButton(
                                        onPressed: () {
                                          showCommentSheet(
                                            postId: data['postId'],
                                            ownerUid: data['user']['uid'],
                                          );
                                        },
                                        icon: Icon(Icons.comment, color: Colors.white),
                                      ),

                                      IconButton(
                                          onPressed: (){},
                                          icon: Icon(Icons.share,color: Colors.white,)
                                      ),
                                    ],
                                  ),
                                  IconButton(onPressed: (){}, icon: Icon(Icons.save_alt,color: Colors.white,)),
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
