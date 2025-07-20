import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class Userhome extends StatefulWidget {
  const Userhome({super.key});

  @override
  State<Userhome> createState() => _UserhomeState();
}

class _UserhomeState extends State<Userhome> {
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
                  IconButton(
                    onPressed: (){},
                    icon: Icon(Icons.messenger_outline),
                    color: Colors.white,
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
