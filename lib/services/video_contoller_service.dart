import 'dart:io';
import 'package:camera/camera.dart';
import 'package:guardians_app/config/base_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class VideoCaptureController {
  CameraController? _cameraController;
  bool _isRecording = false;
  String webhookUrl = "${DevConfig().sosReportingServiceBaseUrl}/sos"; // Set your webhook URL

  // Initializes the camera
  Future<void> initializeCamera() async {
    try {
      List<CameraDescription> cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras[0], // Use the first available camera
          ResolutionPreset.medium,
          enableAudio: true, // Ensure audio is captured
        );
        await _cameraController!.initialize();
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  // Starts video recording for 30 seconds and sends it to the webhook
  Future<void> captureAndSendVideo() async {
    if (_cameraController == null || _isRecording) return;

    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // Start video recording
      await _cameraController!.startVideoRecording();
      _isRecording = true;
      print("Recording started...");

      // Wait for 30 seconds (or whatever duration you choose)
      await Future.delayed(Duration(seconds: 30));

      // Stop recording after 30 seconds
      final XFile videoFile = await _cameraController!.stopVideoRecording();
      _isRecording = false;
      print("Recording stopped. File saved at: ${videoFile.path}");

      // Send the video to the webhook
      await _sendVideoToWebhook(videoFile.path);
    } catch (e) {
      print("Error during video capture: $e");
    }
  }

  // Updated _sendVideoToWebhook function

  Future<void> _sendVideoToWebhook(String videoPath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(webhookUrl));

      // Make sure the file has the .mp4 extension
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
      var videoFile = File(videoPath);
      request.files.add(http.MultipartFile(
        'video',
        videoFile.readAsBytes().asStream(),
        videoFile.lengthSync(),
        filename: fileName,  // Explicitly set filename to .mp4
      ));

      // Send the request
      var response = await request.send();

      // Check server response
      if (response.statusCode == 200) {
        print("Video uploaded successfully!");
      } else {
        print("Failed to upload video. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error uploading video: $e");
    }
  }


  // Disposes the camera controller when no longer needed
  void dispose() {
    _cameraController?.dispose();
  }
}
