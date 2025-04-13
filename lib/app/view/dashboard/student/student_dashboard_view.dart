import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:language_learning_app/app/controllers/services/functions/date_time_conversion.dart';
import 'package:language_learning_app/app/controllers/view_controller/dashboard_controller.dart';
import 'package:language_learning_app/app/controllers/view_controller/languages_controller.dart';
import 'package:language_learning_app/app/models/booking_model.dart';
import 'package:language_learning_app/app/models/language_model.dart';
import 'package:language_learning_app/app/view/video_call/video_call_view.dart';
import 'package:language_learning_app/app/view/chat/chat_list_view.dart';
import 'package:language_learning_app/app/view/language/languages_view.dart';
import 'package:language_learning_app/app/view/widget/button_3.dart';
import 'package:language_learning_app/app/view/widget/card.dart';
import 'package:language_learning_app/app/view/widget/title_text.dart.dart';
import 'package:language_learning_app/app/utils/secret.dart';
import 'package:on_process_button_widget/on_process_button_widget.dart';
import '../../../utils/components.dart';

class StudentDashboardView extends StatelessWidget {
  StudentDashboardView({
    super.key,
  });

  final DashboardController _dashboardController = Get.put(
    DashboardController(),
  );
  final LanguagesController _languagesController = Get.put(
    LanguagesController(),
  );

  Widget _verticalSpace(
    double factor,
  ) => SizedBox(
    height: defaultPadding / factor,
  );

  Future<void> _refreshDashboard() async {
    await _dashboardController.fetchStudentBookings();
    await _languagesController.fetchLanguages();
    await _dashboardController.checkNotifications();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: _buildAppBar(
        context,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: ListView(
          padding: EdgeInsets.all(
            defaultPadding,
          ),
          children: [
            Obx(
              () => _dashboardController.isLoading.value
                  ? const LinearProgressIndicator()
                  : const SizedBox(),
            ),
            _buildWelcomeCard(),
            _verticalSpace(2),
            _buildLanguageSectionHeader(),
            SizedBox(
              height: 150, // Fixed height for horizontal language list
              child: _buildLanguageList(),
            ),
            _verticalSpace(2),
            const TitleText(
              'Upcoming / Running Courses',
            ),
            const SizedBox(
              height: 8,
            ),
            _buildUpcomingCoursesContent(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
  ) {
    return AppBar(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.primary,
      title: const SubtitleText(
        string: 'Student Dashboard',
        color: Colors.white,
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.logout,
            color: Colors.white,
          ),
          onPressed: () => _dashboardController.signOut(),
        ),
        Button3(
          child: const Icon(
            Icons.message,
            color: Colors.white,
          ),
          onTap: () => Get.to(
            () => ChatListView(),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return CustomCard(
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            child: Icon(
              Icons.person,
              size: 40,
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => TitleText(
                    'Welcome, ${_dashboardController.userName.value}',
                  ),
                ),
                const SubtitleText(
                  string: 'Student',
                ),
              ],
            ),
          ),
          OnProcessButtonWidget(
            onTap: () => Get.to(
              LanguagesView(),
            ),
            child: const Text(
              'Find Teachers',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSectionHeader() {
    return Row(
      children: [
        const TitleText(
          'Select Language',
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Get.to(
            LanguagesView(),
          ),
          child: const Text(
            'See All',
            style: TextStyle(
              decoration: TextDecoration.underline,
              decorationColor: Colors.black87,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageList() {
    return Obx(
      () => ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _languagesController.languages.length,
        itemBuilder: (
          context,
          index,
        ) {
          return _buildLanguageCard(
            _languagesController.languages[index],
          );
        },
      ),
    );
  }

  Widget _buildLanguageCard(
    LanguageModel language,
  ) {
    return CustomCard(
      margin: EdgeInsets.only(
        right: defaultPadding / 4,
      ),
      backgroundColor: Theme.of(
        Get.context!,
      ).colorScheme.secondaryContainer.withOpacity(
        0.2,
      ),
      onTap: () => _languagesController.selectLanguage(
        language.id,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: defaultBorderRadius * 4,
            backgroundImage: AssetImage(
              language.flagUrl,
            ),
          ),
          _verticalSpace(
            4,
          ),
          TitleText(
            language.name,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCoursesContent() {
    return Obx(
      () {
        if (_dashboardController.upcomingBookings.isEmpty) {
          return const CustomCard(
            child: Center(
              child: TitleText(
                'No upcoming classes',
              ),
            ),
          );
        }

        return Column(
          children: _dashboardController.upcomingBookings.map((booking) {
            return _buildBookingCard(booking);
          }).toList(),
        );
      },
    );
  }

  Widget _buildBookingCard(
    BookingModel booking,
  ) {
    final teacherName = _dashboardController.getTeacherName(
      booking.teacherId,
    );
    final languageName = _dashboardController.getLanguageName(
      booking.languageId,
    );
    final canJoin = _canJoinSession(
      booking,
    );

    return CustomCard(
      child: Row(
        children: [
          CircleAvatar(
            child: Text(
              teacherName.isNotEmpty
                  ? teacherName[0].toUpperCase()
                  : 'T',
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleText(
                  '$languageName Lesson with $teacherName',
                ),
                SubtitleText(
                  string: booking.startTime.custom_EEEE_MMM_d_yyyy,
                ),
                SubtitleText(
                  string: '${booking.startTime.custom_hh_mm_a} - ${booking.endTime.custom_hh_mm_a}',
                ),
              ],
            ),
          ),
          OnProcessButtonWidget(
            onTap: kDebugMode
                ? () => _joinClass(
                  booking,
                )
                : canJoin
                ? () => _joinClass(
                  booking,
                )
                : null,
            backgroundColor: _getButtonColor(
              booking,
              canJoin,
            ),
            child: SubtitleText(
              string: _getButtonText(
                booking,
                canJoin,
              ),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  bool _canJoinSession(
    BookingModel booking,
  ) {
    final isConfirmed = booking.status == BookingStatus.confirmed.name;
    final isWithinJoinWindow = booking.startTime.difference(
                  DateTime.now(),
                ).inMinutes <= 10 &&
        booking.endTime.isAfter(
          DateTime.now(),
        );
    return isConfirmed && isWithinJoinWindow;
  }

  Future<bool?>? _joinClass(
    BookingModel booking,
  ) async {
    if (kDebugMode) {
      print(
        "Navigating to VideoCallScreen...",
      );
    }
    print(
      "Agora App ID: ${Secret.agoraAppid}",
    );
    print(
      "Channel Name: ${booking.videoCallChannel}",
    );
    print(
      "Token: ${booking.videoCallToken}",
    );
    Get.to(
      () => VideoCallScreen(
        channelName: booking.videoCallChannel,
        appBarTitle: '${_dashboardController.getLanguageName(booking.languageId)} Lesson with ${_dashboardController.getTeacherName(booking.teacherId)}',
      ),
    );

    print(
      "Navigation to VideoCallScreen complete.",
    );
  }

  Color _getButtonColor(
    BookingModel booking,
    bool canJoin,
  ) {
    if (canJoin) {
      return Theme.of(
        Get.context!,
      ).colorScheme.primary;
    }
    return Theme.of(
      Get.context!,
    ).colorScheme.secondaryContainer;
  }

  String _getButtonText(
    BookingModel booking,
    bool canJoin,
  ) {
    if (booking.status == BookingStatus.pending.name) {
      return 'Pending';
    } else if (booking.status == BookingStatus.canceled.name) {
      return 'Cancelled';
    } else if (booking.status == BookingStatus.completed.name) {
      return 'Completed';
    } else if (canJoin) {
      return 'Join';
    } else {
      return 'Upcoming';
    }
  }
}