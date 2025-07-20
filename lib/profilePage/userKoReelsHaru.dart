import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta_clone/profilePage/reelViewPage.dart';

class Userreels extends StatefulWidget {
  const Userreels({super.key});

  @override
  State<Userreels> createState() => _UserreelsState();
}

class _UserreelsState extends State<Userreels> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String? uid;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid=auth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.black,
      body:StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('reels').snapshots(),
        builder: (context,snapshot){
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs= snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              childAspectRatio:0.75,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final imageBytes = base64Decode(data['image']);

              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Reelviewpage()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: data['image'] != null && data['image'] != ""
                        ? Image.memory(
                      imageBytes,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                        : const Icon(Icons.image, color: Colors.white),
                  ),
                ),
              );
            },
          );

        },
      ),
    ));
  }
}
