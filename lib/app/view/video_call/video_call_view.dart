import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:language_learning_app/app/utils/components.dart';

import '../../controllers/view_controller/video_call_controller.dart';


class VideoCallScreen extends StatelessWidget {
  final String channelName;
  final String? appBarTitle;

  const VideoCallScreen({
    Key? key,
    required this.channelName,
    this.appBarTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VideoCallController(channelName: channelName));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          appBarTitle ?? 'Video Call',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: cBlack,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cBlack,
              colorScheme.primary.withOpacity(0.3),
            ],
          ),
        ),
        child: Stack(
          children: [
            Obx(() => _buildVideoViews(controller, colorScheme)),
            Obx(() => _toolbar(controller, colorScheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoViews(VideoCallController controller, ColorScheme colorScheme) {
    if (!controller.isEngineInitialized.value || controller.engine == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: colorScheme.primary,
            ),
            SizedBox(height: defaultPadding),
            const Text(
              'Connecting to video call...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    final views = _getRenderViews(controller);

    switch (views.length) {
      case 1:
        return _buildSingleVideoView(views[0], colorScheme);
      case 2:
        return _buildDualVideoView(views[0], views[1], colorScheme);
      default:
        return _buildGridVideoView(views, colorScheme);
    }
  }

  Widget _buildSingleVideoView(Widget view, ColorScheme colorScheme) {
    return Center(
      child: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          color: cBlack,
          borderRadius: BorderRadius.circular(defaultBorderRadius / 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(defaultBorderRadius / 2),
          child: view,
        ),
      ),
    );
  }

  Widget _buildDualVideoView(Widget localView, Widget remoteView, ColorScheme colorScheme) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            margin: EdgeInsets.fromLTRB(
              defaultPadding / 3,
              defaultPadding / 3,
              defaultPadding / 3,
              defaultPadding / 6,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(defaultBorderRadius),
              border: Border.all(
                color: colorScheme.primary,
                width: borderWidth2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(defaultBorderRadius),
              child: remoteView,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: EdgeInsets.fromLTRB(
              defaultPadding / 3,
              defaultPadding / 6,
              defaultPadding / 3,
              defaultPadding * 3,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(defaultBorderRadius),
              border: Border.all(
                color: colorScheme.primary,
                width: borderWidth2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(defaultBorderRadius),
              child: localView,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridVideoView(List<Widget> views, ColorScheme colorScheme) {
    List<Widget> wrappedViews = views.map((view) {
      return Container(
        margin: EdgeInsets.all(defaultPadding / 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
          border: Border.all(
            color: colorScheme.primary,
            width: borderWidth2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
          child: view,
        ),
      );
    }).toList();

    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.fromLTRB(
        defaultPadding / 3,
        defaultPadding / 3,
        defaultPadding / 3,
        defaultPadding * 3,
      ),
      children: wrappedViews,
    );
  }

  List<Widget> _getRenderViews(VideoCallController controller) {
    final List<Widget> list = [
      AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: controller.engine!,
          canvas: VideoCanvas(uid: controller.uid),
          useFlutterTexture: false,
        ),
      ),
    ];
    for (int uid in controller.users) {
      list.add(
        AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: controller.engine!,
            canvas: VideoCanvas(uid: uid),
            connection: RtcConnection(channelId: controller.channelName),
            useFlutterTexture: false,
          ),
        ),
      );
    }
    return list;
  }

  Widget _toolbar(VideoCallController controller, ColorScheme colorScheme) {
    if (!controller.isEngineInitialized.value || controller.engine == null) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(bottom: defaultPadding),
        padding: EdgeInsets.symmetric(vertical: defaultPadding / 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircleButton(
              icon: Icon(
                controller.muted.value ? Icons.mic_off : Icons.mic,
                color: controller.muted.value ? Colors.white : colorScheme.primary,
                size: 22,
              ),
              onPressed: controller.onToggleMute,
              backgroundColor: controller.muted.value ? colorScheme.primary : Colors.white,
              tooltip: controller.muted.value ? 'Unmute' : 'Mute',
            ),
            SizedBox(width: defaultPadding / 1.5),
            _buildCircleButton(
              icon: const Icon(
                Icons.call_end,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () => controller.onCallEnd(Get.context!),
              backgroundColor: Colors.red,
              size: defaultPadding * 2.5,
              tooltip: 'End Call',
            ),
            SizedBox(width: defaultPadding / 1.5),
            _buildCircleButton(
              icon: Icon(
                Icons.switch_camera,
                color: colorScheme.primary,
                size: 22,
              ),
              onPressed: controller.onSwitchCamera,
              backgroundColor: Colors.white,
              tooltip: 'Switch Camera',
            ),
            SizedBox(width: defaultPadding / 1.5),
            _buildCircleButton(
              icon: Icon(
                controller.videoEnabled.value ? Icons.videocam : Icons.videocam_off,
                color: controller.videoEnabled.value ? colorScheme.primary : Colors.white,
                size: 22,
              ),
              onPressed: controller.onToggleVideo,
              backgroundColor: controller.videoEnabled.value ? Colors.white : colorScheme.primary,
              tooltip: controller.videoEnabled.value ? 'Turn off Video' : 'Turn on Video',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required Icon icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    double? size,
    required String tooltip,
  }) {
    final buttonSize = size ?? defaultPadding * 2;

    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      elevation: 4.0,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}