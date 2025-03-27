import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';

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

  Future<void> _trimVideo() async {
    if (_videoEditorController == null) return;
    final start = _videoEditorController!.startTrim.inSeconds;
    final end = _videoEditorController!.endTrim.inSeconds;
    final Directory tempDir = await getTemporaryDirectory();
    final String outputPath = path.join(tempDir.path, "trimmed_video.mp4");
    final String command = "-i ${_videoEditorController!.file.path} -ss $start -to $end -c copy $outputPath";

    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        setState(() {
          videoTrimTime.add(outputPath);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video trimmed and saved to: $outputPath')),
        );
      }
    });
  }

  Future<void> _mergeVideos(List<String> videoPaths) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String outputPath = path.join(tempDir.path, "merged_video.mp4");
    String inputFiles = videoPaths.map((e) => "-i $e").join(" ");
    final String command = "$inputFiles -filter_complex "[0:v:0][1:v:0]concat=n=2:v=1[outv]" -map "[outv]" $outputPath";

    await FFmpegKit.execute(command).then((session) async {
    final returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Videos merged and saved to: $outputPath')),
    );
    }
    });
  }

  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  Future<void> _cropVideo(String inputPath, String outputPath) async {
    String cropCommand = '-i $inputPath -filter:v "crop=400:400:100:50" -c:a copy $outputPath';

    int result = await _flutterFFmpeg.execute(cropCommand);
    if (result == 0) {
      print("Video cropped successfully: $outputPath");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video cropped successfully!')),
      );
    } else {
      print("Error cropping video");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to crop video')),
      );
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Editing Screen"),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            if (showEditing && _videoPlayerController!.value.isInitialized)...[
              Expanded(
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: _videoPlayerController!.value.aspectRatio,
                      child: VideoPlayer(_videoPlayerController!),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_videoPlayerController!.value.isPlaying) {
                            _videoPlayerController!.pause();
                          } else {
                            if (!seeking) {
                              _videoPlayerController!.seekTo(_videoEditorController!.startTrim);
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
                  ],
                ),
              ),
              TrimSlider(controller: _videoEditorController!, height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(onPressed: _trimVideo, icon: Icon(Icons.content_cut, color: Colors.white)),
                  IconButton(onPressed: _cropVideo, icon: Icon(Icons.crop, color: Colors.white)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.music_note, color: Colors.white)),
                ],
              ),
              ElevatedButton(
                onPressed: () => _mergeVideos(videoTrimTime),
                child: Text("Merge & Export Video"),
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Text("Select a Video to Start Editing", style: TextStyle(color: Colors.grey)),
                ),
              ),
              ElevatedButton(
                onPressed: _selectVideo,
                child: Text("Import Video"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
