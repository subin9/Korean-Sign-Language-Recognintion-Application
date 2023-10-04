import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:subin_model_demo/pages/video_recorder.dart';
import 'package:video_player/video_player.dart';

class VideoDemoScreen extends StatefulWidget {
  final int demoNum;
  final VoidCallback onBackPressed;
  final VoidCallback onNextPressed;

  static const apiUrl = 'http://oc.kykint.com:19980';

  // static const apiUrl = 'http://10.0.2.2:19980';

  const VideoDemoScreen({
    super.key,
    required this.demoNum,
    required this.onBackPressed,
    required this.onNextPressed,
  });

  @override
  State<VideoDemoScreen> createState() => _VideoDemoScreenState();
}

class _VideoDemoScreenState extends State<VideoDemoScreen> {
  late final VideoPlayerController _videoController;

  String? _videoPath;
  String? _status;
  String? _result;

  @override
  void initState() {
    super.initState();
    _videoController =
        VideoPlayerController.asset('assets/videos/video${widget.demoNum}.mkv')
          ..initialize().then((_) {
            _videoController.addListener(_videoListener);
            setState(() {});
          });
  }

  @override
  void dispose() {
    _videoController.removeListener(_videoListener);
    _videoController.dispose();
    super.dispose();
  }

  void _videoListener() {
    print('notified');
    if (_videoController.value.position == _videoController.value.duration) {
      print('done');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPlayerBody(),
            _buildPlayPauseButton(),
            _buildCameraButton(),
            _buildResultBody(),
          ],
        ),
      ),
      bottomNavigationBar: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton(
                onPressed: widget.onBackPressed,
                child: const Text('Back'),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton(
                onPressed: widget.onNextPressed,
                child: const Text('Next'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerBody() {
    return _videoController.value.isInitialized
        ? AspectRatio(
            aspectRatio: _videoController.value.aspectRatio,
            child: VideoPlayer(_videoController))
        : _buildVideoLoading();
  }

  Widget _buildPlayPauseButton() {
    return _videoController.value.isInitialized
        ? Column(
            children: [
              const SizedBox(height: 16),
              IconButton(
                onPressed: () {
                  setState(() {
                    _videoController.value.isPlaying
                        ? _videoController.pause()
                        : _videoController.play();
                  });
                },
                icon: Icon(
                  _videoController.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  size: 48,
                ),
              ),
            ],
          )
        : const SizedBox();
  }

  Widget _buildCameraButton() {
    return Column(
      children: [
        const SizedBox(height: 16.0),
        FilledButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VideoRecorder()),
            ).then((value) {
              setState(() {
                _videoPath = value;
              });
            });
          },
          child: const Text('동영상 촬영'),
        ),
        if (_videoPath != null) ...[
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              await _runModel();
            },
            child: const Text('모델 실행'),
          )
        ]
      ],
    );
  }

  _runModel() async {
    assert(_videoPath != null);
    final request = MultipartRequest(
        'POST', Uri.parse('${VideoDemoScreen.apiUrl}/classify'))
      ..fields['num'] = '${widget.demoNum + 1}'
      ..files.add(
        await MultipartFile.fromPath(
          'file',
          _videoPath!,
          contentType: MediaType('video', '*'),
        ),
      );
    try {
      setState(() {
        _status = '모델 응답 대기 중...';
      });
      final streamedResponse = await request.send();
      final response = await Response.fromStream(streamedResponse);
      final responseJson =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode != 200 || responseJson['result'] is! String) {
        print('responseJson: $responseJson');
        throw Exception('Failed to run model');
      }
      setState(() {
        _status = '성공';
        _result = responseJson['result'];
      });
    } on Exception catch (e) {
      print('Exception: $e');
      setState(() {
        _status = '오류 발생';
      });
    }
  }

  Widget _buildResultBody() {
    return Column(
      children: [
        if (_result == null && _status != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '$_status',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        if (_result != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '결과: ${_result!}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoLoading() {
    return const SizedBox(
      height: 128,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('동영상 로드 중'),
          ],
        ),
      ),
    );
  }
}
