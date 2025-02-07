import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  VideoPlayerScreen({required this.videoPath});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  double _playbackSpeed = 1.0;
  double _volume = 1.0;
  bool _isFullscreen = false;
  int _lastSavedPosition = 0;
  bool _isVideoPlayable = true;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _lastSavedPosition = await _getSavedPosition(widget.videoPath);

    try {
      _controller = VideoPlayerController.file(File(widget.videoPath))
        ..initialize().then((_) {
          setState(() {});

          if (_lastSavedPosition > 0) {
            _showResumeDialog();
          }
        }).catchError((error) {
          setState(() {
            _isVideoPlayable = false;
          });
          print("Error initializing video: $error");
        });
    } catch (e) {
      setState(() {
        _isVideoPlayable = false;
      });
      print("Error loading video: $e");
    }
  }

  @override
  void dispose() {
    _saveVideoProgress();
    _controller.dispose();
    if (_isFullscreen) {
      _exitFullscreen();
    }
    super.dispose();
  }

  Future<void> _saveVideoProgress() async {
    if (!_isVideoPlayable) return;

    final prefs = await SharedPreferences.getInstance();
    final key = "video_${widget.videoPath}";
    prefs.setInt(key, _controller.value.position.inSeconds);

    List<String> watchedVideos = prefs.getStringList('watchedVideos') ?? [];
    if (!watchedVideos.contains(widget.videoPath)) {
      watchedVideos.add(widget.videoPath);
      prefs.setStringList('watchedVideos', watchedVideos);
    }
  }

  Future<int> _getSavedPosition(String videoPath) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "video_$videoPath";
    return prefs.getInt(key) ?? 0;
  }

  void _showResumeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Resume Video?"),
        content: Text(
            "Would you like to resume the video from where you left off?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              _controller.seekTo(Duration(seconds: _lastSavedPosition));
              Navigator.pop(context);
            },
            child: Text("Yes"),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      _enterFullscreen();
    } else {
      _exitFullscreen();
    }
  }

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
  }

  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: isPortrait && !_isFullscreen
          ? AppBar(
        title: Text('Video Player'),
        backgroundColor: Colors.blueAccent,
      )
          : null,
      body: _isVideoPlayable
          ? _controller.value.isInitialized
          ? Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value:
                    _controller.value.position.inSeconds.toDouble(),
                    min: 0.0,
                    max: _controller.value.duration.inSeconds
                        .toDouble(),
                    onChanged: (value) {
                      setState(() {
                        _controller
                            .seekTo(Duration(seconds: value.toInt()));
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _volume > 0
                              ? Icons.volume_up
                              : Icons.volume_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _volume = _volume > 0 ? 0.0 : 1.0;
                            _controller.setVolume(_volume);
                          });
                        },
                      ),
                      DropdownButton<double>(
                        value: _playbackSpeed,
                        dropdownColor: Colors.black,
                        items: [
                          DropdownMenuItem(
                            value: 0.5,
                            child: Text('0.5x',
                                style:
                                TextStyle(color: Colors.white)),
                          ),
                          DropdownMenuItem(
                            value: 1.0,
                            child: Text('1.0x',
                                style:
                                TextStyle(color: Colors.white)),
                          ),
                          DropdownMenuItem(
                            value: 1.5,
                            child: Text('1.5x',
                                style:
                                TextStyle(color: Colors.white)),
                          ),
                          DropdownMenuItem(
                            value: 2.0,
                            child: Text('2.0x',
                                style:
                                TextStyle(color: Colors.white)),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _playbackSpeed = value!;
                            _controller
                                .setPlaybackSpeed(_playbackSpeed);
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _isFullscreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                          color: Colors.white,
                        ),
                        onPressed: _toggleFullscreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      )
          : Center(child: CircularProgressIndicator())
          : Center(
        child: Text(
          'Error: Unable to play this video format.',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
