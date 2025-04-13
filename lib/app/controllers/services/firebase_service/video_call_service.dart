import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class VideoCallService {
  late final RtcEngine _engine;

  Future<void> initialize({
    required String appId,
    required String channelName,
    required String token,
    required int uid,
  }) async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          print("Joined channel: $channelName");
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          print("Remote user joined: $remoteUid");
        },
        onUserOffline: (connection, remoteUid, reason) {
          print("Remote user left: $remoteUid");
        },
      ),
    );

    await _engine.enableVideo();

    await _engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> leaveChannel() async {
    await _engine.leaveChannel();
    await _engine.release();
  }
}