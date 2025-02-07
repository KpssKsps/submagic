import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:submagic/screens/video_player_screen.dart';
import 'package:submagic/services/watchedvideosscreen.dart'; // Assuming you have this screen

class VideoSelectionScreen extends StatefulWidget {
  @override
  _VideoSelectionScreenState createState() => _VideoSelectionScreenState();
}

class _VideoSelectionScreenState extends State<VideoSelectionScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _videoFile;

  // Function to pick a video
  Future<void> _selectVideo() async {
    final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFile = pickedFile;
      });
      Navigator.pushNamed(context, '/videoPlayer', arguments: {'videoPath': _videoFile!.path});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Video'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // "Choose Video" button
            ElevatedButton(
              onPressed: _selectVideo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Background color
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Padding
                textStyle: TextStyle(fontSize: 18), // Text size
              ),
              child: Text('Choose Video'),
            ),
            SizedBox(height: 20), // Space between buttons
            // "View Watched Videos" button
            ElevatedButton(
              onPressed: () async {
                final watchedVideo = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WatchedVideosScreen(),
                  ),
                );

                if (watchedVideo != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(videoPath: watchedVideo),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Background color
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text("View Watched Videos"),
            ),
          ],
        ),
      ),
    );
  }
}
