import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:insta_clone/searchedUsers/searchedUserProfilePage.dart';

class Searchusers extends StatefulWidget {
  const Searchusers({super.key});

  @override
  State<Searchusers> createState() => _SearchusersState();
}

class _SearchusersState extends State<Searchusers> {
  TextEditingController searchController = TextEditingController();

  List<Map<String,dynamic>> users=[

  ];


  void searchUser(String searchText)async{


    if(searchText.isEmpty){
      print("Search field is empty");
    }
    try{
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('user_name',isGreaterThanOrEqualTo: searchText)
          .where('user_name',isLessThan: searchText+'z')
          .get();

      for(int i = 0;i<snapshot.docs.length;i++){
        final data = snapshot.docs[i].data()as Map<String,dynamic>;
       if(users.contains(data)){
         continue;
       }else if(searchText==""){
         setState(() {
           users.clear();
         });
       }else{
         setState(() {
           users.add(data);
         });
       }
      }
      log(users.toString());
    }catch(e){
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10,right: 10,top: 30),
            child: Row(
              children: [
                IconButton(onPressed: (){
                  Navigator.pop(context);
                },
                    icon: Icon(Icons.arrow_back,color: Colors.white,)),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: searchController,
                    style: TextStyle(color: Colors.white),
                    onChanged: (value){
                      setState(() {
                        searchUser(value);
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 2),
                        prefixIcon: Icon(Icons.search,color: Colors.white30,),
                        hintText: "search",
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
              ],
            ),
          ),
          SizedBox(height: 20,),
          Expanded(

            child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context,index){
                  final data = users[index] as Map<String,dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(left: 40,bottom: 20),
                    child: ListTile(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Searcheduserprofilepage(user: data)));
                      },
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage('assets/default.png'),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['user_name'],
                            style: TextStyle(
                              color: Colors.white
                            ),
                          ),Text(
                            data['name'],
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
            ),
          ),


        ],
      ),
    ));
  }
}
