import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta_clone/messagess/chatPage.dart';
import 'package:insta_clone/messagess/requestPage.dart';

class Messages extends StatefulWidget {

  const Messages({super.key});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {

  String? name;
  FirebaseAuth auth = FirebaseAuth.instance;

  void getName() async {
    final User? user = auth.currentUser!;
    final uid=user!.uid;
    DocumentSnapshot data = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      name=data.get('user_name');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getName();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back,color: Colors.white,)
        ),
        title: Text(
          name == null ? "":name!,
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                height: 45,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white12,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Icon(Icons.search,color: Colors.white,),
                    ),
                    SizedBox(width: 20,),
                    Text(
                      "Ask Meta AI or Search",
                      style: TextStyle(
                          color: Colors.white54,
                        fontSize: 15
                      ),
                    ),

                  ],
                ),
              ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Messages",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Requestpage()));
                    },
                    child: Text(
                      "Requests",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context,snapshot){
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs= snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                  itemBuilder: (context,index){
                      final data= docs[index].data() as Map<String,dynamic>;
                      return auth.currentUser!.uid != data['uid']
                          ? Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage('assets/default.png'),
                            radius: 30,
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['user_name'],
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(height: 25),
                            ],
                          ),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>Chatpage(
                              receiverUserName: data['user_name'],
                              receiverUserID: data['uid'],
                              receiverName: data['name'],
                            )));
                          },
                        ),
                      ) : SizedBox(height: 0,);
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
