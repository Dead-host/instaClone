import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Viewpostofthisuser extends StatefulWidget {
  final Map<String,dynamic> user;
  const Viewpostofthisuser({super.key,required this.user});

  @override
  State<Viewpostofthisuser> createState() => _ViewpostofthisuserState();
}

class _ViewpostofthisuserState extends State<Viewpostofthisuser> {

  String? uid;

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
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back,color: Colors.white,)),
        title: Text(
          "Posts",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('posts').snapshots(),
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
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('assets/default.png'),

                          ),
                          SizedBox(width: 10,),
                          Text(
                            data['user_name'],
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          )
                        ],
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
                              IconButton(onPressed: (){}, icon: Icon(Icons.favorite_border,color: Colors.white,)),
                              IconButton(onPressed: (){}, icon: Icon(Icons.comment,color: Colors.white,)),
                              IconButton(onPressed: (){}, icon: Icon(Icons.share,color: Colors.white,)),
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
                            data['user_name']??"",
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
                    SizedBox(height: 10,),
                  ],
                ),
              );
            },
          );

        },
      ),
    ));
  }
}
