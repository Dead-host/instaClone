import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../homePage.dart';

class Poststory extends StatefulWidget {
  const Poststory({super.key});

  @override
  State<Poststory> createState() => PoststoryState();
}

class PoststoryState extends State<Poststory> {

  String? base64Image;
  String? userName;
  String? userId;
  String storyId="";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<void> pickImage(ImageSource source)async{
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source,imageQuality: 60);

    if(pickedFile!=null){
      final compressed =await FlutterImageCompress.compressWithFile(
        pickedFile.path,
        quality: 50,
      );
      if(compressed!=null){
        setState(() {
          base64Image=base64Encode(compressed);
        });
      }
    }
  }
  Future<void> getUser()async{
    try{
      storyId=DateTime.now().millisecondsSinceEpoch.toString();
      final User? user = _auth.currentUser;
      final uid=user!.uid;
      DocumentSnapshot data = await _firestore.collection('users').doc(uid).get();
      setState(() {
        userName=data.get('user_name');
        userId=data.get('uid');

      });
      log(userName!);

    }catch(e){print(e);}
  }
  Future<void> postStory() async {
    try {
      final User? user = _auth.currentUser;
      final uid = user?.uid;
      final storyId = DateTime.now().millisecondsSinceEpoch.toString();
      final timestamp = Timestamp.now();


      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userName = userDoc.get('user_name');

      final storyData = {
        'storyId': storyId,
        'image': base64Image,
        'timestamp': timestamp,
      };

      final storyDoc = _firestore.collection('stories').doc(uid);

      await storyDoc.set({
        'uid': uid,
        'user_name': userName,
        'timestamp': timestamp,
        'stories': FieldValue.arrayUnion([storyData]),
      },SetOptions(merge: true));

      log(base64Image!);
      Fluttertoast.showToast(msg: "Story posted");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Homepage()));

    } catch (e) {
      print("Error: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20,top: 10),
          child: GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Homepage()));
            },
            child: Text(
              'X',
              style: TextStyle(
                color: Colors.white,
                fontSize:25,

              ),
            ),
          ),
        ),
        title: Text(
          "Add to story",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),

        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: (){
                postStory();
              },
              child: Text(
                'Post',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (base64Image != null)
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                width: double.infinity,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(base64Image!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            SizedBox(height: 50,),
            Container(
              color: Colors.white10,
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(left: 20,right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: (){
                        pickImage(ImageSource.gallery);
                      },
                      child: Text(
                        "Recent",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,

                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: (){
                        pickImage(ImageSource.camera);
                      },
                      icon: Icon(Icons.camera_alt_outlined,size: 20,color: Colors.white,),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 20,),


          ],
        ),
      ),

    ));
  }
}
