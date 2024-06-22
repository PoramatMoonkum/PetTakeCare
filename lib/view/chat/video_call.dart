import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoCallScreen extends StatefulWidget {
  final String chatRoomId;

  VideoCallScreen({required this.chatRoomId});

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late RTCPeerConnection _peerConnection;
  late MediaStream _localStream;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    _startCall();
    _listenForRemoteDescription();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _startCall() async {
    _localStream = await _getUserMedia();
    _localRenderer.srcObject = _localStream;

    _peerConnection = await _createPeerConnection();
    _peerConnection.addStream(_localStream);

    _peerConnection.onIceCandidate = (candidate) {
      if (candidate != null) {
        _sendSignalingData(candidate.toMap());
      }
    };

    _peerConnection.onAddStream = (stream) {
      _remoteRenderer.srcObject = stream;
    };

    final offer = await _peerConnection.createOffer();
    await _peerConnection.setLocalDescription(offer);
    _sendSignalingData(offer.toMap());
  }

  Future<MediaStream> _getUserMedia() async {
    final mediaConstraints = {
      'audio': true,
      'video': {'facingMode': 'user'},
    };

    return await navigator.mediaDevices.getUserMedia(mediaConstraints);
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    final configuration = {
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'},
      ],
    };

    return await createPeerConnection(configuration);
  }

  void _sendSignalingData(Map<String, dynamic> data) {
    FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(widget.chatRoomId)
        .collection('video_call')
        .add(data);
  }

  Future<void> _listenForRemoteDescription() async {
    FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(widget.chatRoomId)
        .collection('video_call')
        .snapshots()
        .listen((snapshot) async {
      for (var doc in snapshot.docs) {
        if (doc.data().containsKey('sdp') && doc.data().containsKey('type')) {
          final remoteDescription = RTCSessionDescription(
            doc.data()['sdp'],
            doc.data()['type'],
          );
          await _peerConnection.setRemoteDescription(remoteDescription);
          if (doc.data()['type'] == 'offer') {
            final answer = await _peerConnection.createAnswer();
            await _peerConnection.setLocalDescription(answer);
            _sendSignalingData(answer.toMap());
          }
        } else if (doc.data().containsKey('candidate')) {
          final candidate = RTCIceCandidate(
            doc.data()['candidate'],
            doc.data()['sdpMid'],
            doc.data()['sdpMLineIndex'],
          );
          await _peerConnection.addCandidate(candidate);
        }
      }
    });
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection.close();
    _localStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Call'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RTCVideoView(_remoteRenderer),
          ),
          Expanded(
            child: Container(
              width: 100,
              height: 150,
              child: RTCVideoView(_localRenderer, mirror: true),
            ),
          ),
        ],
      ),
    );
  }
}
