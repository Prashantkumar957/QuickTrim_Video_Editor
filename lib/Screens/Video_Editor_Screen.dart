import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';
class VideoEditorScreen extends StatefulWidget {
  const VideoEditorScreen({super.key});



  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
final ImagePicker _picker = ImagePicker();
VideoPlayerController? _videoPlayerController;
VideoEditorController? _videoEditorController;
bool show_ediitng = false;
bool Seeking  =false;
 List<String> VideoTrimTime = [];

  Future<void> _selectVideo () async {
   final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
   if(file!=null){
     _videoEditorController= VideoEditorController.file(File(file.path),
     minDuration: Duration(seconds: 3),
       maxDuration: Duration(seconds: 120),

     );

     _videoPlayerController= VideoPlayerController.file(File(file.path));
     try{
       await Future.wait([
         _videoPlayerController!.initialize(),
         _videoEditorController!.initialize(),


       ]);
       _videoEditorController!.addListener(() {
        if(_videoPlayerController!.value.position >= _videoEditorController!.endTrim){
          _videoPlayerController!.pause();
        }
       });
       setState(() {
         show_ediitng=true;
       });

     } catch(e){
       print("Error: $e");
     }
   }


  }

  @override



  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: Container(
        color: Colors.black,
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            if(show_ediitng && _videoPlayerController!.value.isInitialized &&_videoEditorController!.initialized)...[
              //video preview or video display with slider
               Expanded(
                 flex: 4,
                 child: Column(
                   children: [
                     Expanded(
                       child: Stack(
                         children: [
                           AspectRatio(aspectRatio: _videoPlayerController!.value.aspectRatio,
                           child:VideoPlayer(_videoPlayerController!),
                           ),
                           IconButton(
                               onPressed: (){
                                 setState(() {
                                   if(_videoPlayerController!.value.isPlaying){
                                     _videoPlayerController!.pause();
                                   }
                                   else{
                                     if(!Seeking){
                                       int StartTrimDur = _videoEditorController!.startTrim.inSeconds;
                                       _videoPlayerController!.seekTo(Duration(seconds: StartTrimDur));
                                     }
                                     _videoPlayerController!.play();
                                   }

                                 });


                               },
                               icon: Icon(_videoPlayerController!.value.isPlaying? Icons.pause : Icons.play_arrow,
                                 color: Colors.white,
                                 size: 48,

                               ),


                           )
                         ],
                       ),
                     ),
                     Slider(


                     value: _videoPlayerController!.value.position.inMilliseconds.toDouble(),
                       max: _videoPlayerController!.value.position.inMilliseconds.toDouble(),
                       onChangeStart: (value){
                         Seeking=true;
                        },
                     onChanged: (value){

                 _videoPlayerController!.seekTo(Duration(milliseconds: value.toInt()));

                         setState(() {

                         });

                      },

                      onChangeEnd: (value){
                       Seeking=false;
                       _videoPlayerController!.play();

                      },




                     )
                   ],
                 ),
               )


            ]
            else...[
              Expanded(child: Center(
                child: Text("Select a Video to Start Editing ",
                  style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: Colors.grey),
                ),


              )
              ),
              Padding(padding: EdgeInsets.only(bottom: 47),
                child: ElevatedButton(onPressed: _selectVideo,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent

                  ),

                  child: Text(
                    "Import Video",
                    style: TextStyle(
                      fontSize: 20, // Slightly larger for better visibility
                      fontWeight: FontWeight.w900, // Extra bold for emphasis
                      color: Colors.white,
                      letterSpacing: 1.5, // Adds spacing between letters for a sleek look
                      shadows: [
                        Shadow(
                          blurRadius: 5,
                          color: Colors.black.withOpacity(0.3), // Subtle text shadow
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center, // Ensures the text is well-aligned
                  ),

                ),

              ),
            ]

          ],
        ),

      ),
    );
  }
}
