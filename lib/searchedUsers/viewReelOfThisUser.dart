import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Viewreelofthisuser extends StatefulWidget {
  final Map<String,dynamic> user;
  const Viewreelofthisuser({super.key,required this.user});

  @override
  State<Viewreelofthisuser> createState() => _ViewreelofthisuserState();
}

class _ViewreelofthisuserState extends State<Viewreelofthisuser> {

  String? uid;
  final currentUser = FirebaseAuth.instance.currentUser!;
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

    final postRefGlobal = FirebaseFirestore.instance.collection('reels').doc(postId);
    final postRefUser = FirebaseFirestore.instance
        .collection('users')
        .doc(ownerUid)
        .collection('reels')
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
                future: FirebaseFirestore.instance.collection('reels').doc(postId).get(),
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


  Future<void> toggleLike(String postId, String ownerUid) async {

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final postRef = FirebaseFirestore.instance.collection('reels').doc(postId);
    final userPostRef = FirebaseFirestore.instance
        .collection('users')
        .doc(ownerUid)
        .collection('reels')
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
  void initState() {
    // TODO: implement initState
    super.initState();
    uid=widget.user['uid'];
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('reels').snapshots(),
            builder: (context,snapshot){
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs= snapshot.data!.docs;

              return PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: docs.length,
                itemBuilder: (context,index){
                  final data = docs[index].data()as Map<String,dynamic>;

                  return Stack(
                    children: [
                      Image.memory(
                        base64Decode(data['image']),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20,right: 20),
                        child: Row(

                          children:  [
                            IconButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.arrow_back,color: Colors.white,)
                            ),
                            Text(
                              "Reels",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                              ),
                            ),
                            Spacer(),
                            Icon(Icons.camera_alt_outlined, color: Colors.white),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    //this row for dp and user name
                                    Expanded(
                                      flex: 3,
                                      child: Row(

                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundImage: AssetImage('assets/default.png'),
                                          ),
                                          SizedBox(width: 10,),
                                          Text(
                                            data['user_name']?? '',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 20,),
                                          OutlinedButton(onPressed: (){}, child: Text("Follow",style: TextStyle(color: Colors.white),)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex:1,
                                      child: Column(

                                        children: [
                                          IconButton(
                                              onPressed: (){
                                                toggleLike(data['postId'], data['uid']);
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
                                                ownerUid: data['uid'],
                                              );
                                            },
                                            icon: Icon(Icons.comment, color: Colors.white),
                                          ),
                                          IconButton(onPressed: (){}, icon: Icon(Icons.share,color: Colors.white,)),
                                          IconButton(onPressed: (){}, icon: Icon(Icons.more_vert,color: Colors.white,)),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 10,),
                                Text(
                                  data['description'],
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Text(
                                    data['hasTag'],
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      )

                    ],
                  );
                },
              );

            },
          ),
        ],
      ),
    ));
  }
}
