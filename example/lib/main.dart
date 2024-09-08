import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_media_delete/flutter_media_delete.dart';

import 'services/media_utils.dart';
import 'services/permission_handler_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          headlineSmall:
              TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
      ),
      home: MediaListScreen(),
    );
  }
}

class MediaListScreen extends StatefulWidget {
  @override
  _MediaListScreenState createState() => _MediaListScreenState();
}

class _MediaListScreenState extends State<MediaListScreen> {
  List<File> _mediaFiles = [];
  List<Directory> _folders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final result = await PermissionHandlerService.requestPermissions();
    if (result) {
      _loadMedia();
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissions not granted')),
      );
    }
  }

  Future<void> _loadMedia() async {
    setState(() {
      _isLoading = true;
    });

    final mediaFiles = await MediaUtils.getMediaFiles(limit: 5);
    final folders = await MediaUtils.getMediaFolders(limit: 5);

    setState(() {
      _mediaFiles = mediaFiles;
      _folders = folders;
      _isLoading = false;
    });
  }

  Future<void> _deleteFile(String path) async {
    try {
      final result = await FlutterMediaDelete.deleteMediaFile(path);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result),
      ));
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    } finally {
      _loadMedia(); // Reload the list after deletion
    }
  }

  Future<void> _deleteFolder(String path) async {
    try {
      final result = await FlutterMediaDelete.deleteMediaFolder(path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result ?? 'Failed to delete folder contents'),
        ));
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));
      }
    } finally {
      _loadMedia(); // Reload the list after deletion
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Manager'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  "Media Files:",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                ..._mediaFiles.map((file) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(file.path),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteFile(file.path),
                        ),
                      ),
                    )),
                const SizedBox(height: 20),
                Text(
                  "Media Folders:",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                ..._folders.map((folder) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(folder.path),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteFolder(folder.path),
                        ),
                      ),
                    )),
              ],
            ),
    );
  }
}
