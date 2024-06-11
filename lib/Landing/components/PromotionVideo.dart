import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Promotionvideo extends StatefulWidget {
  const Promotionvideo({super.key});

  @override
  State<Promotionvideo> createState() => _PromotionvideoState();
}

class _PromotionvideoState extends State<Promotionvideo> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize your video controller here with your network video URL
    // ignore: deprecated_member_use
    _controller = VideoPlayerController.network('https://www.example.com/video.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    _controller.setLooping(true);  // Optionally loop the video
    _controller.play();  // Optionally auto-play the video
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                // Fill the screen with the video player
                child: VideoPlayer(_controller),
              )
            : Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
