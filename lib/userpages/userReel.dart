import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Userreel extends StatefulWidget {
  const Userreel({super.key});

  @override
  State<Userreel> createState() => _UserreelState();
}

class _UserreelState extends State<Userreel> {

  final currentUser = FirebaseAuth.instance.currentUser!;


  Future<void> toggleLike(String postId, String ownerUid) async {

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final postRef = FirebaseFirestore.instance.collection('reels').doc(postId);
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
      body: Stack(
        children: [

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('reels').snapshots(),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "Reels",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                              ),
                            ),
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
                                            data['user']['user_name']?? '',
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
                                          IconButton(onPressed: (){}, icon: Icon(Icons.comment,color: Colors.white,)),
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
                                  padding: const EdgeInsets.only(bottom: 10),
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
