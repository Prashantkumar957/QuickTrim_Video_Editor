import 'dart:io';
import 'package:ffmpeg_cli/ffmpeg_cli.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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
  bool showEditing = false;
  bool seeking = false;
  List<String> videoTrimTime = [];

  Future<void> _mergeVideo() async {
    // Merge video functionality to be implemented
  }

  Future<void> _trimVideo() async {
    if (_videoEditorController == null) return;

    final start = _videoEditorController!.startTrim.inSeconds;
    final end = _videoEditorController!.endTrim.inSeconds;

    final Directory tempDir = await getTemporaryDirectory();
    final String filename = "Trimmed_video_${DateTime.now().millisecondsSinceEpoch}.mp4";
    final String outputPath = path.join(tempDir.path, filename);
    final String inputPath = _videoEditorController!.file.path;

    List<String> args = [
      "-i", inputPath,
      "-ss", start.toString(),
      "-to", end.toString(),
      "-c", "copy",
      outputPath,
    ];

    try {
      final result = await Process.run("ffmpeg", args);

      if (result.exitCode == 0) {
        setState(() {
          videoTrimTime.add(outputPath);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Video exported to: $outputPath')),
        );
      } else {
        print("❌ FFmpeg Error: ${result.stderr}");
      }
    } catch (e) {
      print("❌ Unexpected error: $e");
    }
  }

  Future<void> _selectVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      _videoEditorController = VideoEditorController.file(
        File(file.path),
        minDuration: Duration(seconds: 3),
        maxDuration: Duration(seconds: 120),
      );

      _videoPlayerController = VideoPlayerController.file(File(file.path));
      try {
        await Future.wait([
          _videoPlayerController!.initialize(),
          _videoEditorController!.initialize(),
        ]);
        _videoEditorController!.addListener(() {
          if (_videoPlayerController!.value.position >= _videoEditorController!.endTrim) {
            _videoPlayerController!.pause();
          }
        });
        setState(() {
          showEditing = true;
        });
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  @override
  @override
  void initState() {
    super.initState();

    _videoPlayerController?.addListener(() {
      if (mounted) {
        setState(() {}); // Update slider as video plays
      }
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Video Editing Screen",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black,
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            if (showEditing && _videoPlayerController!.value.isInitialized && _videoEditorController!.initialized) ...[
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: _videoPlayerController!.value.aspectRatio,
                            child: VideoPlayer(_videoPlayerController!),
                          ),
                          Center(
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  if (_videoPlayerController!.value.isPlaying) {
                                    _videoPlayerController!.pause();
                                  } else {
                                    if (!seeking) {
                                      int startTrimDur = _videoEditorController!.startTrim.inSeconds;
                                      _videoPlayerController!.seekTo(Duration(seconds: startTrimDur));
                                    }
                                    _videoPlayerController!.play();
                                  }
                                });
                              },
                              icon: Icon(
                                _videoPlayerController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Slider(
                      value: _videoPlayerController!.value.position.inMilliseconds.toDouble(),
                      min: 0,
                      max: _videoPlayerController!.value.duration.inMilliseconds.toDouble(), // Ensure max value is full duration
                      activeColor: Colors.red, // Optional styling
                      onChangeStart: (value) {
                        seeking = true;
                      },
                      onChanged: (value) {
                        _videoPlayerController!.seekTo(Duration(milliseconds: value.toInt()));
                        setState(() {});
                      },
                      onChangeEnd: (value) {
                        seeking = false;
                        _videoPlayerController!.play(); // Resume video after seeking
                      },
                    )

                  ],
                ),
              ),
              TrimSlider(
                controller: _videoEditorController!,
                height: 60,
                horizontalMargin: 20,
                child: TrimTimeline(controller: _videoEditorController!),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(onPressed: _trimVideo, icon: Icon(Icons.content_cut, color: Colors.white)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.crop, color: Colors.white)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.speed, color: Colors.white)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.music_note, color: Colors.white)),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _mergeVideo,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text(
                    "Merge & Export Video",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Text(
                    "Select a Video to Start Editing",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 47),
                child: ElevatedButton(
                  onPressed: _selectVideo,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: Text("Import Video", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
