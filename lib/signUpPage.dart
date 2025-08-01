import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:insta_clone/homePage.dart';
import 'package:insta_clone/loginPage.dart';

class Signuppage extends StatefulWidget {
  const Signuppage({super.key});

  @override
  State<Signuppage> createState() => _SignuppageState();
}

class _SignuppageState extends State<Signuppage> {

  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  bool see=true;
  bool passSee=true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<void> registerUse()async{
    try{
      final UserCredential userCredential =await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
      );
      final User ? user = userCredential.user;

      if(user!=null){
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'name':fullNameController.text,
          'user_name':userNameController.text,
          'phone': phoneController.text,
          'followers':0,
          'following':0,
          'post':0,
        });
        Fluttertoast.showToast(
          msg: "Registered user successfully",
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }

    }catch(e,stacktrace){
      print("Registration Error: $e");
      print("StackTrace: $stacktrace");
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Text(
                "Create an Account",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 50,),
            Padding(
              padding: const EdgeInsets.only(left: 40,right: 40),
              child: TextFormField(
                controller: userNameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: "User Name",
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
            Padding(
              padding: const EdgeInsets.only(left: 40,right: 40),
              child: TextFormField(
                controller: fullNameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: "Full Name",
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
            Padding(
              padding: const EdgeInsets.only(left: 40,right: 40),
              child: TextFormField(
                controller: emailController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: "Email address",
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
            Padding(
              padding: const EdgeInsets.only(left: 40,right: 40),
              child: TextFormField(
                obscureText: see,
                controller: passwordController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(color: Colors.grey),
                    suffixIcon: IconButton(
                      onPressed: (){
                        setState(() {
                          see=!see;
                        });
                      },
                      icon:Icon(see?Icons.visibility:Icons.visibility_off),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.white30)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    )
                ),
              ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.only(left: 40,right: 40),
              child: TextFormField(
                obscureText: passSee,
                controller: confirmPasswordController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: "Confirm Password",
                    hintStyle: TextStyle(color: Colors.grey),
                    suffixIcon: IconButton(
                      onPressed: (){
                        setState(() {
                          passSee=!passSee;
                        });
                      },
                      icon:Icon(passSee?Icons.visibility:Icons.visibility_off),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.white30)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    )
                ),
              ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.only(left: 40,right: 40),
              child: TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: "Phone number",
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
            Container(
              height: 50,
              width: 330,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: (){
                  registerUse();
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Homepage()));
                  userNameController.clear();
                  emailController.clear();
                  passwordController.clear();
                  confirmPasswordController.clear();
                  phoneController.clear();
                  fullNameController.clear();
                },  
                child: Text(
                  "Register",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            //Spacer(),
            SizedBox(height: 180,),
            Divider(color: Colors.white30,),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Loginpage()));
                    },
                    child: Text(
                      "Login In",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),

    ));
  }
}
