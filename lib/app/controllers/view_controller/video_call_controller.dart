import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:language_learning_app/app/utils/secret.dart';

class VideoCallController extends GetxController {
  final RxList<int> users = <int>[].obs;
  final RxList<String> infoStrings = <String>[].obs;
  final RxBool muted = false.obs;
  final RxBool videoEnabled = true.obs;
  final RxBool isEngineInitialized = false.obs;
  RtcEngine? engine;
  final int uid = 0;
  final String channelName;

  VideoCallController({required this.channelName});

  @override
  void onInit() {
    super.onInit();
    _requestPermissionsAndInitialize();
  }

  Future<void> _requestPermissionsAndInitialize() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (statuses[Permission.camera]!.isGranted &&
        statuses[Permission.microphone]!.isGranted) {
      await Future.delayed(const Duration(milliseconds: 500));
      await initialize();
    } else {
      infoStrings.add('Camera or Microphone permission denied');
    }
  }

  Future<void> initialize() async {
    if (Secret.agoraAppid.isEmpty) {
      infoStrings.add('APP_ID missing, please provide your APP_ID in secret.dart');
      infoStrings.add('Agora Engine is not starting');
      return;
    }

    try {
      infoStrings.add('Channel: $channelName, UID: $uid');
      await _initAgoraRtcEngine();
      _addAgoraEventHandlers();
      await engine!.setParameters('{"rtc.log_filter": 65535}');
      await engine!.enableWebSdkInteroperability(true);
      await engine!.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 1280, height: 720),
        ),
      );
      await engine!.joinChannel(
        token: "",
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
      isEngineInitialized.value = true;
    } catch (e, stackTrace) {
      infoStrings.add('Initialization error: $e');
      infoStrings.add('Stack trace: $stackTrace');
    }
  }

  Future<void> _initAgoraRtcEngine() async {
    try {
      engine = createAgoraRtcEngine();
      await engine!.initialize(
        RtcEngineContext(
          appId: Secret.agoraAppid,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          logConfig: const LogConfig(level: LogLevel.logLevelInfo),
        ),
      );
      await engine!.enableVideo();
      await engine!.startPreview();
    } catch (e, stackTrace) {
      infoStrings.add('Engine initialization failed: $e');
      infoStrings.add('Stack trace: $stackTrace');
      rethrow;
    }
  }

  void _addAgoraEventHandlers() {
    engine?.registerEventHandler(
      RtcEngineEventHandler(
        onError: (err, msg) {
          infoStrings.add('onError: $err, $msg');
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          infoStrings.add('onJoinChannel: ${connection.channelId}, uid: ${connection.localUid}');
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          infoStrings.add('onLeaveChannel');
          users.clear();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          infoStrings.add('userJoined: $remoteUid');
          users.add(remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          infoStrings.add('userOffline: $remoteUid');
          users.remove(remoteUid);
        },
        onFirstRemoteVideoFrame: (RtcConnection connection, int remoteUid, int width, int height, int elapsed) {
          infoStrings.add('firstRemoteVideo: $remoteUid ${width}x $height');
        },
      ),
    );
  }

  void onToggleMute() {
    muted.value = !muted.value;
    engine?.muteLocalAudioStream(muted.value);
  }

  void onToggleVideo() {
    videoEnabled.value = !videoEnabled.value;
    engine?.enableLocalVideo(videoEnabled.value);
  }

  void onSwitchCamera() {
    engine?.switchCamera();
  }

  void onCallEnd(BuildContext context) {
    engine?.leaveChannel();
    Get.back();
  }

  @override
  void onClose() {
    if (isEngineInitialized.value && engine != null) {
      engine!.leaveChannel();
      engine!.release();
    }
    super.onClose();
  }
}