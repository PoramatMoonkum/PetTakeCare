// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// class VideoCallScreen extends StatefulWidget {
//   final String chatUserId;

//   VideoCallScreen({required this.chatUserId});

//   @override
//   _VideoCallScreenState createState() => _VideoCallScreenState();
// }

// class _VideoCallScreenState extends State<VideoCallScreen> {
//   late RtcEngine _engine;
//   bool _localUserJoined = false;
//   int? _remoteUid;

//   @override
//   void initState() {
//     super.initState();
//     _initAgora();
//   }

//   Future<void> _initAgora() async {
//     await [Permission.microphone, Permission.camera].request();

//     _engine = createAgoraRtcEngine();
//     await _engine.initialize(RtcEngineContext(appId: '148cb59b6a6d4db68c55b9f3e78de6c5'));

//     _engine.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int uid, int elapsed) {
//           setState(() {
//             _localUserJoined = true;
//           });
//         },
//         onUserJoined: (RtcConnection connection, int uid, int elapsed) {
//           setState(() {
//             _remoteUid = uid;
//           });
//         },
//         onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
//           setState(() {
//             _remoteUid = null;
//           });
//         },
//       ),
//     );

//     await _engine.joinChannel(
//       token: 'ddd9c9b5868d4657b6a0bb884e128218',
//       channelId: 'test',
//       uid: 0,
//       options: ChannelMediaOptions(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Video Call'),
//       ),
//       body: Stack(
//         children: [
//           Center(
//             child: _remoteUid != null
//                 ? AgoraVideoView(
//                     controller: VideoViewController.remote(
//                       rtcEngine: _engine,
//                       canvas: VideoCanvas(uid: _remoteUid),
//                     ),
//                   )
//                 : Text(
//                     'Please wait for the remote user to join',
//                     textAlign: TextAlign.center,
//                   ),
//           ),
//           Align(
//             alignment: Alignment.topLeft,
//             child: _localUserJoined
//                 ? AgoraVideoView(
//                     controller: VideoViewController(
//                       rtcEngine: _engine,
//                       canvas: const VideoCanvas(uid: 0),
//                     ),
//                   )
//                 : CircularProgressIndicator(),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _engine.leaveChannel();
//     _engine.release();
//     super.dispose();
//   }
// }
