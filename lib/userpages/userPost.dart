import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:insta_clone/homePage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_clone/userpages/userHome.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:insta_clone/userpages/userPostReel.dart';
import 'package:popover/popover.dart';

class Userpost extends StatefulWidget {
  const Userpost({super.key});

  @override
  State<Userpost> createState() => _UserpostState();
}

class _UserpostState extends State<Userpost> {

  TextEditingController description = TextEditingController();
  String? base64Image;
  String? userName;
  String? userId;
  int? posts;
  String postId="";



  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> postInUser()async{
    try{
      await getUser();
      final User? user = _auth.currentUser;
      final uid = user!.uid;
      await _firestore.collection('users').doc(uid).collection('posts').doc(postId).set({
        'description': description.text,
        'image': base64Image,
        'user_name':userName,
        'likes':[],
        'comments':[
          {
            'users':{
              "id":"",
              "name":"",
            },
            "comment":[
              {
                "comment":"",
                "time":"",
                "like":0,
              }
            ]
          }
        ],
        'shares':0,
        'postId':postId,
      });
      updatePost();
    }catch(e){
      print(e);
    }
  }

  Future<void> getUser()async{
    try{
      postId=DateTime.now().millisecondsSinceEpoch.toString();
      final User? user = _auth.currentUser;
      final uid=user!.uid;
      DocumentSnapshot data = await _firestore.collection('users').doc(uid).get();
      setState(() {
        userName=data.get('user_name');
        userId=data.get('uid');
        posts=data.get('post');
      });
      log(userName!);

    }catch(e){print(e);}
  }


  Future<void> updatePost()async{
    try{
      await getUser();
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'post': posts!+1,
      });
    }catch(e){
      print(e);
    }
  }


  Future<void> postItem()async{
    try{
     await getUser();

      await FirebaseFirestore.instance.collection('posts').doc(postId).set({

        'postId':postId,
        'description': description.text,
        'image': base64Image,
        'user':{
          'user_name':userName,
          'uid':userId,
        },
        'likes':[],
        'comments':[
          {
            'users':{
              "id":"",
              "name":"",
            },
            "comment":[
              {
                "comment":"",
                "time":"",
                "like":0,
              }
            ]
          }
        ],
        'shares':0,
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Homepage()));
      Fluttertoast.showToast(
       msg: "Posted successfully",
       toastLength: Toast.LENGTH_SHORT,
       backgroundColor: Colors.green,
       textColor: Colors.white,
      );
    }catch(e){
      print("Erroe: $e");
    }
  }
  Future<void> pickImage(ImageSource source)async{
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source,imageQuality: 80);

    if(pickedFile!=null){
      final compressed =await FlutterImageCompress.compressWithFile(
        pickedFile.path,
        quality: 80,
      );
      if(compressed!=null){
        setState(() {
          base64Image=base64Encode(compressed);
        });
      }
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
        title: PopupMenuButton(
          color: Colors.black,
          child: Text(
              "New Post",
            style: TextStyle(
              color: Colors.white,

            ),
          ),
            itemBuilder: (context)=>[
          PopupMenuItem(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Userpost()));
            },
              child: Text(
                "New Post",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
          ),
          PopupMenuItem(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Userpostreel()));
            },
              child: Text(
                "New Reel",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
          ),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: (){
                //getUser();
               postItem();
               postInUser();


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
            if(base64Image!=null)
            Container(
              color: Colors.white,
              height: 551,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Image.memory(base64Decode(base64Image!))
                ],
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
            Padding(
              padding: const EdgeInsets.only(left: 30,right: 30),
              child: TextFormField(
                controller: description,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: "Image description",
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    )
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
