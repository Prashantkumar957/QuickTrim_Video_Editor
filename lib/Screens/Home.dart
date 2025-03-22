import 'package:flutter/material.dart';
import 'package:short_video_editor/Screens/Video_Editor_Screen.dart';
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Editing",style: TextStyle(
          fontWeight: FontWeight.bold,color: Colors.white
        ),),
        backgroundColor: Colors.blueAccent,







      ),
      body: Center(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: (){
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> VideoEditorScreen()));

            },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,

                ),

                child: Text("New Project")),
          ],
        ),
      ),
    );
  }
}
