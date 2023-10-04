import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class VideoRecorder extends StatefulWidget {
  const VideoRecorder({super.key});

  @override
  State<VideoRecorder> createState() => _VideoRecorderState();
}

class _VideoRecorderState extends State<VideoRecorder> {
  late final CameraController _cameraController;
  bool _isLoading = true;
  bool _isRecording = false;
  bool? _isRecordingComplete;

  String? _filePath;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back);
    _cameraController = CameraController(front, ResolutionPreset.max);
    await _cameraController.initialize();
    setState(() => _isLoading = false);
  }

  _recordVideo() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _isRecordingComplete = true;
      });
      _filePath = file.path;
      print('recording complete, $_filePath');
    } else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('카메라를 불러오는 중입니다.'),
          ],
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: _buildCameraPreview()),
            _buildCameraButton(),
            _buildStatusText(),
            _buildCompleteButton(),
          ],
        ),
      );
    }
  }

  Widget _buildCameraPreview() {
    return CameraPreview(_cameraController);
  }

  Widget _buildCameraButton() {
    return Column(
      children: [
        const SizedBox(height: 16.0),
        FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          child: Icon(
            _isRecording ? Icons.stop : Icons.circle,
            size: 24,
          ),
          onPressed: () {
            _recordVideo();
          },
        ),
      ],
    );
  }

  Widget _buildStatusText() {
    return Column(
      children: [
        const SizedBox(height: 16.0),
        SizedBox(
          width: double.infinity,
          child: Text(
            _isRecordingComplete == true ? "촬영이 완료되었습니다." : "",
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context, _filePath);
              },
              child: const Text(
                '완료',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
