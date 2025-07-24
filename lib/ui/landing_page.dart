import 'dart:io' show Platform;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  String? _errorMessage;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();

    // Auto navigate setelah 8 detik jika video tidak bisa load
    _autoTimer = Timer(Duration(seconds: 8), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });

    print('Platform: ${Platform.isAndroid ? "Android" : "Windows"}');
    print('Starting video initialization...');

    _controller = VideoPlayerController.network(
      'https://tinagers.com/video/landing_page.mp4',
      httpHeaders: {
        'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
      },
    )..initialize().then((_) {
        print('Video initialized successfully');
        print('Video duration: ${_controller.value.duration}');
        print('Video size: ${_controller.value.size}');

        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.play();
          print('Video started playing');

          // Navigate setelah video selesai
          Timer(_controller.value.duration + Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          });
        }
      }).catchError((error) {
        print('Video Error Detail: $error');
        print('Error Type: ${error.runtimeType}');
        if (mounted) {
          setState(() {
            _errorMessage = 'Video loading failed:\n$error';
          });
        }
      });

    _controller.setLooping(false);

    // Listener untuk debug
    _controller.addListener(() {
      if (_controller.value.hasError) {
        print('Video Player Error: ${_controller.value.errorDescription}');
      }

      if (_controller.value.isCompleted) {
        print('Video completed');
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: _errorMessage != null
              ? Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text(
                        'Video Loading Failed',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.black, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/home'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Continue to App'),
                      ),
                    ],
                  ),
                )
              : _isInitialized
                  ? Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black, // Background hitam untuk video
                      child: Stack(
                        children: [
                          // Video Player dengan AspectRatio
                          Center(
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              child: VideoPlayer(_controller),
                            ),
                          ),
                          // Gradient Overlay
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blue.withOpacity(0.3),
                                  Colors.lightBlue.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                          // // Debug Info
                          // Positioned(
                          //   top: 50,
                          //   left: 20,
                          //   right: 20,
                          //   child: Container(
                          //     padding: EdgeInsets.all(8),
                          //     decoration: BoxDecoration(
                          //       color: Colors.red.withOpacity(0.8),
                          //       borderRadius: BorderRadius.circular(4),
                          //     ),
                          //     child: Text(
                          //       'Video Playing! ✅\n'
                          //       'Duration: ${_controller.value.duration}\n'
                          //       'Position: ${_controller.value.position}\n'
                          //       'Size: ${_controller.value.size}\n'
                          //       'Has Audio: ${_controller.value.hasError ? "Error" : "OK"}',
                          //       style: TextStyle(
                          //           color: Colors.white, fontSize: 12),
                          //     ),
                          //   ),
                          // ),
                          // Logo/Text overlay
                          Positioned(
                            bottom: 100,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Column(
                                children: [
                                  Text(
                                    '',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 10.0,
                                          color: Colors.black.withOpacity(0.7),
                                          offset: Offset(2.0, 2.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Contact Management App',
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 73, 148, 240),
                                      fontSize: 16,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 5.0,
                                          color: Colors.black.withOpacity(0.7),
                                          offset: Offset(1.0, 1.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.blue),
                        SizedBox(height: 20),
                        Text(
                          'Loading KuyKontak Video...',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Platform: ${Platform.isAndroid ? "Android" : "Windows"}',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
