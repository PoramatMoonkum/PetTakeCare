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
    _createPeerConnection().then((pc) {
      _peerConnection = pc;
      _createOffer();
      _listenForRemoteDescription();
    });
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection.close();
    super.dispose();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    final configuration = <String, dynamic>{
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    final pc = await createPeerConnection(configuration);

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    _localStream.getTracks().forEach((track) {
      pc.addTrack(track, _localStream);
    });

    pc.onIceCandidate = (candidate) {
      // ส่ง candidate ไปยัง remote peer ผ่าน signaling server
      if (candidate != null) {
        FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.chatRoomId)
            .collection('candidates')
            .add(candidate.toMap());
      }
    };

    pc.onTrack = (event) {
      if (event.track.kind == 'video') {
        setState(() {
          _remoteRenderer.srcObject = event.streams[0];
        });
      }
    };

    setState(() {
      _localRenderer.srcObject = _localStream;
    });

    return pc;
  }

  void _createOffer() async {
    final offer = await _peerConnection.createOffer();
    await _peerConnection.setLocalDescription(offer);

    // บันทึก offer ไปยัง Firestore
    FirebaseFirestore.instance.collection('rooms').doc(widget.chatRoomId).set({
      'offer': {
        'type': offer.type,
        'sdp': offer.sdp,
      },
    });
  }

  void _createAnswer() async {
    final answer = await _peerConnection.createAnswer();
    await _peerConnection.setLocalDescription(answer);

    // บันทึก answer ไปยัง Firestore
    FirebaseFirestore.instance.collection('rooms').doc(widget.chatRoomId).update({
      'answer': {
        'type': answer.type,
        'sdp': answer.sdp,
      },
    });
  }

  void _setRemoteDescription(Map<String, dynamic> description) async {
    final sdp = RTCSessionDescription(description['sdp'], description['type']);
    await _peerConnection.setRemoteDescription(sdp);
  }

  void _listenForRemoteDescription() {
    FirebaseFirestore.instance.collection('rooms').doc(widget.chatRoomId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        if (data.containsKey('offer')) {
          _setRemoteDescription(data['offer']);
          _createAnswer(); // ถ้าเจอ offer ก็สร้าง answer
        }
        if (data.containsKey('answer')) {
          _setRemoteDescription(data['answer']);
        }
      }
    });

    FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.chatRoomId)
        .collection('candidates')
        .snapshots()
        .listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          _peerConnection.addCandidate(RTCIceCandidate(
            change.doc['candidate'],
            change.doc['sdpMid'],
            change.doc['sdpMLineIndex'],
          ));
        }
      });
    });
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
            child: RTCVideoView(_localRenderer),
          ),
          Expanded(
            child: RTCVideoView(_remoteRenderer),
          ),
        ],
      ),
    );
  }
}
