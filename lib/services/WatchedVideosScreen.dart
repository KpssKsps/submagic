import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchedVideosScreen extends StatefulWidget {
  @override
  _WatchedVideosScreenState createState() => _WatchedVideosScreenState();
}

class _WatchedVideosScreenState extends State<WatchedVideosScreen> {
  List<Map<String, dynamic>> _watchedVideos = [];

  @override
  void initState() {
    super.initState();
    _loadWatchedVideos();
  }

  Future<void> _loadWatchedVideos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> watchedVideos = prefs.getStringList('watchedVideos') ?? [];
    List<Map<String, dynamic>> videosWithPositions = [];

    for (String videoPath in watchedVideos) {
      int? position = prefs.getInt("video_$videoPath");
      videosWithPositions.add({
        'path': videoPath,
        'position': position ?? 0,
      });
    }

    setState(() {
      _watchedVideos = videosWithPositions;
    });
  }

  // Format duration into mm:ss format
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Watched Videos"),
        backgroundColor: Colors.blueAccent,
      ),
      body: _watchedVideos.isEmpty
          ? Center(
        child: Text(
          "No watched videos found!",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: _watchedVideos.length,
        itemBuilder: (context, index) {
          final video = _watchedVideos[index];
          return ListTile(
            title: Text(video['path'].split('/').last), // Display file name
            subtitle: Text(
                "Last watched at: ${_formatDuration(video['position'])}"),
            onTap: () {
              Navigator.pop(context, video['path']); // Return video path
            },
          );
        },
      ),
    );
  }
}
