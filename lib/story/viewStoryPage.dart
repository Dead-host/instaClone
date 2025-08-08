import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:percent_indicator/flutter_percent_indicator.dart';

class Viewstorypage extends StatefulWidget {

  final List<dynamic> stories;
  final int initialIndex;

  const Viewstorypage({super.key,required this.stories,this.initialIndex=0});

  @override
  State<Viewstorypage> createState() => _ViewstorypageState();
}

class _ViewstorypageState extends State<Viewstorypage> {

  late PageController pageController;
  int currentIndex = 0;
  Timer? timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController =PageController(initialPage: widget.initialIndex);
    startAutoPlay();
  }

  void startAutoPlay() {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 5), (_) {
      if (currentIndex < widget.stories.length - 1) {
          pageController.nextPage(
            duration: Duration(milliseconds: 300), curve: Curves.easeIn);
      } else {
        Navigator.pop(context);
      }
    });
  }

  void _onTapDown (TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapX = details.localPosition.dx;

    if(tapX<screenWidth/2){
      if(currentIndex>0){
        pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
      }
    }
    else{
      if(currentIndex<widget.stories.length-1){
        pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
      }else{
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: _onTapDown,
        child: Stack(
          children: [
            PageView.builder(
                controller: pageController,
              onPageChanged: (index){
                  setState(() {
                    currentIndex=index;
                  });
                  startAutoPlay();
              },
              itemBuilder: (context,index){
                  final story = widget.stories[index];
                  final image = story['image'];
                  return Center(
                    child: image!=null && image!=""?Image.memory(
                        base64Decode(image),
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    ):SizedBox(),
                  );
              },
            ),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                children: List.generate(widget.stories.length, (index) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: index == currentIndex
                          ? TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(seconds: 5),
                        onEnd: () {
                          if (currentIndex < widget.stories.length - 1) {
                            pageController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeIn);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        builder: (context, value, child) {
                          return LinearProgressIndicator(
                            value: value,
                            backgroundColor: Colors.white30,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          );
                        },
                      )
                          : LinearProgressIndicator(
                        value: index < currentIndex ? 1.0 : 0.0,
                        backgroundColor: Colors.white30,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  );
                }),
              ),
            ),

            Positioned(
                top: 20,
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage('assets/default.png'),
                        ),
                        SizedBox(width: 10,),
                        Text(
                          widget.stories[currentIndex]['user_name'],
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                    Spacer(),
                    IconButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close,size: 30,color: Colors.white,)
                    )
                  ],
                )
            )
          ],
        )
      ),
    ));
  }
}
