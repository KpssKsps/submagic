import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:submagic/models/theme_manager.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _usernameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  double _playbackSpeed = 1.0;
  double _volume = 1.0;
  bool _enableRotation = true;
  bool _enableZoom = true;

  List<String> _videoHistory = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPlaybackSettings();
    _loadHistory();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    String? savedPassword = prefs.getString('password');

    setState(() {
      _usernameController.text = savedUsername ?? '';
      _currentPasswordController.text = savedPassword ?? '';
    });
  }

  Future<void> _loadPlaybackSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _playbackSpeed = prefs.getDouble('playbackSpeed') ?? 1.0;
      _volume = prefs.getDouble('volume') ?? 1.0;
      _enableRotation = prefs.getBool('enableRotation') ?? true;
      _enableZoom = prefs.getBool('enableZoom') ?? true;
    });
  }

  Future<void> _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _videoHistory = prefs.getStringList('videoHistory') ?? [];
    });
  }

  Future<void> _updateThemePreference(ThemeMode mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    Provider.of<ThemeManager>(context, listen: false).setThemeMode(mode);
  }

  Future<void> _updateUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('password', _newPasswordController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User data updated successfully!')),
    );
  }

  Future<void> _updatePlaybackSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('playbackSpeed', _playbackSpeed);
    await prefs.setDouble('volume', _volume);
    await prefs.setBool('enableRotation', _enableRotation);
    await prefs.setBool('enableZoom', _enableZoom);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Playback settings updated successfully!')),
    );
  }

  Future<void> _clearHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('videoHistory');
    setState(() {
      _videoHistory.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Video history cleared!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Selection Section
            Text('Theme Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              title: Text('Light Theme'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.light,
                groupValue: Provider.of<ThemeManager>(context).themeMode,
                onChanged: (value) {
                  if (value != null) _updateThemePreference(value);
                },
              ),
            ),
            ListTile(
              title: Text('Dark Theme'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: Provider.of<ThemeManager>(context).themeMode,
                onChanged: (value) {
                  if (value != null) _updateThemePreference(value);
                },
              ),
            ),
            ListTile(
              title: Text('System Default'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.system,
                groupValue: Provider.of<ThemeManager>(context).themeMode,
                onChanged: (value) {
                  if (value != null) _updateThemePreference(value);
                },
              ),
            ),
            Divider(height: 40),

            // Username and Password Section
            Text('Account Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Current Password'),
            ),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'New Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserData,
              child: Text('Update User Data'),
            ),
            Divider(height: 40),

            // Playback Settings Section
            Text('Playback Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              children: [
                Text('Playback Speed: ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Slider(
                    value: _playbackSpeed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 3,
                    onChanged: (value) {
                      setState(() {
                        _playbackSpeed = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text('Volume: ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) {
                      setState(() {
                        _volume = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SwitchListTile(
              title: Text('Enable Rotation'),
              value: _enableRotation,
              onChanged: (value) {
                setState(() {
                  _enableRotation = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Enable Zoom'),
              value: _enableZoom,
              onChanged: (value) {
                setState(() {
                  _enableZoom = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: _updatePlaybackSettings,
              child: Text('Update Playback Settings'),
            ),
            Divider(height: 40),

            // Video History Section
            Text('Video History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _videoHistory.isNotEmpty
                ? Column(
              children: _videoHistory
                  .map((video) => ListTile(title: Text(video)))
                  .toList(),
            )
                : Center(child: Text('No videos in history')),
            ElevatedButton(
              onPressed: _clearHistory,
              child: Text('Clear History'),
            ),
          ],
        ),
      ),
    );
  }
}
