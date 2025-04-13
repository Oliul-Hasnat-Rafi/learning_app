import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:language_learning_app/app/controllers/services/firebase_service/notification_service.dart';
import 'package:language_learning_app/app/controllers/services/functions/date_time_conversion.dart';
import 'package:language_learning_app/app/controllers/view_controller/dashboard_controller.dart';
import 'package:language_learning_app/app/models/booking_model.dart';
import 'package:language_learning_app/app/view/widget/button_3.dart';
import 'package:language_learning_app/app/view/widget/card.dart';
import 'package:language_learning_app/app/view/widget/custom_animated_size_widget.dart';
import 'package:language_learning_app/app/view/widget/title_text.dart.dart';
import 'package:language_learning_app/app/utils/components.dart';
import 'package:on_process_button_widget/on_process_button_widget.dart';
import '../../video_call/video_call_view.dart';
import '../../chat/chat_list_view.dart';
import '../../teacher/teacher_profile_view.dart';

class TeacherDashboardView
    extends
        StatelessWidget {
  TeacherDashboardView({
    super.key,
  });

  final DashboardController controller = Get.put(
    DashboardController(),
  );
  final NotificationService _notificationService = Get.put(
    NotificationService(),
  );

  Widget
  _size(
    int i,
  ) => SizedBox(
    height:
        defaultPadding /
        i,
  );

  Future<
    void
  >
  _refreshDashboard() async {
    await controller.fetchTeacherBookings();
    await controller.checkProfileCompletion();
    await controller.checkNotifications();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar:
          _buildAppBar(),
      body: RefreshIndicator(
        onRefresh:
            _refreshDashboard,
        child: ListView(
          padding: EdgeInsets.all(
            defaultPadding /
                2,
          ),
          children: [
            Obx(
              () =>
                  controller.isLoading.value
                      ? const LinearProgressIndicator()
                      : const SizedBox(),
            ),
            _buildProfileCard(),
            _size(
              2,
            ),
            const TitleText(
              'Upcoming Classes',
            ),
            _size(
              2,
            ),
            _buildUpcomingClassesListContent(),
            _size(
              2,
            ),
            _buildAvailabilityCard(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle:
          true,
      backgroundColor:
          Theme.of(
            Get.context!,
          ).colorScheme.primary,
      title: const SubtitleText(
        string:
            'Teacher Dashboard',
        color:
            Colors.white,
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.logout,
            color:
                Colors.white,
          ),
          onPressed:
              () =>
                  controller.signOut(),
        ),
        Button3(
          child: const Icon(
            Icons.message,
            color:
                Colors.white,
          ),
          onTap:
              () => Get.to(
                () =>
                    ChatListView(),
              ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius:
                    defaultBorderRadius *
                    3,
                child: const Icon(
                  Icons.person,
                ),
              ),
              SizedBox(
                width:
                    defaultPadding,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => TitleText(
                        controller.userName.value,
                      ),
                    ),
                    const Text(
                      'Teacher',
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                icon: const Icon(
                  Icons.edit,
                ),
                label: const Text(
                  'Edit Profile',
                ),
                onPressed:
                    () => Get.to(
                      () =>
                          TeacherProfileView(),
                    ),
              ),
            ],
          ),
          _size(
            2,
          ),
          Obx(
            () => CustomAnimatedSize(
              child:
                  controller.isProfileComplete.value
                      ? const SizedBox.shrink()
                      : _buildProfileCompletionAlert(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionAlert() {
    return Container(
      padding: EdgeInsets.all(
        defaultPadding /
            2,
      ),
      decoration: BoxDecoration(
        color:
            Colors.amber.shade100,
        borderRadius: BorderRadius.circular(
          8,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning,
            color:
                Colors.amber,
          ),
          SizedBox(
            width:
                defaultPadding /
                2,
          ),
          const Flexible(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                TitleText(
                  'Complete your profile',
                ),
                SubtitleText(
                  string:
                      'Add your languages, bio, hourly rate and availability to start teaching.',
                ),
              ],
            ),
          ),
          TextButton(
            onPressed:
                () => Get.to(
                  () =>
                      TeacherProfileView(),
                ),
            child: const Text(
              'Complete',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingClassesListContent() {
    return Obx(
      () {
        if (controller.upcomingBookings.isEmpty) {
          return const CustomCard(
            child: Center(
              child: TitleText(
                'No upcoming classes',
              ),
            ),
          );
        }

        return Column(
          children:
              controller.upcomingBookings.map(
                (
                  booking,
                ) {
                  return _buildBookingCard(
                    booking,
                  );
                },
              ).toList(),
        );
      },
    );
  }

  Widget _buildBookingCard(
    BookingModel booking,
  ) {
    final studentName = controller.getStudentName(
      booking.studentId,
    );
    final languageName = controller.getLanguageName(
      booking.languageId,
    );
    final isPending =
        booking.status ==
        BookingStatus.pending.name;
    final canJoin = _canStartSession(
      booking,
    );

    return CustomCard(
      margin: const EdgeInsets.only(
        bottom:
            12,
      ),
      child: Row(
        children: [
          CircleAvatar(
            child: Text(
              studentName.isNotEmpty
                  ? studentName[0].toUpperCase()
                  : 'S',
            ),
          ),
          const SizedBox(
            width:
                10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                TitleText(
                  languageName,
                ),
                TitleText(
                  '$languageName Lesson with $studentName',
                ),
                SubtitleText(
                  string:
                      booking.startTime.custom_EEEE_MMM_d_yyyy,
                ),
                SubtitleText(
                  string:
                      '${booking.startTime.custom_hh_mm_a} - ${booking.endTime.custom_hh_mm_a}',
                ),
              ],
            ),
          ),
          isPending
              ? _manageBooking(
                booking,
              )
              : OnProcessButtonWidget(
                onTap:
                    canJoin
                        ? () => _startClass(
                          booking,
                        )
                        : null,
                backgroundColor:
                    canJoin
                        ? Theme.of(
                          Get.context!,
                        ).colorScheme.primary
                        : Theme.of(
                          Get.context!,
                        ).colorScheme.secondaryContainer,
                child: SubtitleText(
                  string:
                      canJoin
                          ? 'Join'
                          : 'Upcoming',
                  color:
                      Colors.white,
                ),
              ),
        ],
      ),
    );
  }

  bool _canStartSession(
    BookingModel booking,
  ) {
    final isConfirmed =
        booking.status ==
        BookingStatus.confirmed.name;
    final isWithinJoinWindow =
        booking.startTime
                .difference(
                  DateTime.now(),
                )
                .inMinutes <=
            10 &&
        booking.endTime.isAfter(
          DateTime.now(),
        );
    return isConfirmed &&
        isWithinJoinWindow;
  }

  Future<
    bool?
  >?
  _startClass(
    BookingModel booking,
  ) async {
    Get.to(
      () => VideoCallScreen(
        channelName:
            booking.videoCallChannel,
        appBarTitle:
            '${controller.getLanguageName(booking.languageId)} Lesson with ${controller.getStudentName(booking.studentId)}',
      ),
    );
  }

  Widget _manageBooking(
    BookingModel booking,
  ) {
    return Container(
      width:
          defaultPadding *
          5,
      decoration: BoxDecoration(
        border: Border.all(
          color:
              Theme.of(
                Get.context!,
              ).colorScheme.primary,
        ),
        borderRadius: BorderRadius.circular(
          defaultBorderRadius,
        ),
      ),
      child: PopupMenuButton<
        BookingStatus
      >(
        itemBuilder:
            (
              context,
            ) =>
                BookingStatus.values
                    .map(
                      (
                        status,
                      ) => PopupMenuItem(
                        value:
                            status,
                        child: Row(
                          children: [
                            Icon(
                              _getStatusIcon(
                                status,
                              ),
                              color: _getStatusColor(
                                status,
                              ),
                              size:
                                  18,
                            ),
                            const SizedBox(
                              width:
                                  8,
                            ),
                            Text(
                              status.name.capitalize!,
                              style: TextStyle(
                                color: _getStatusColor(
                                  status,
                                ),
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
        onSelected: (
          status,
        ) async {
          await controller.bookingStatusUpdate(
            booking.id,
            status.name,
          );
          await _notificationService.sendNotificationToUser(
            userId:
                booking.studentId,
            title:
                'Booking Status Update',
            body:
                'Your booking status has been updated to ${status.name.capitalize}',
          );
        },
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(
                    _getCurrentStatus(
                      booking,
                    ),
                  ),
                  color: _getStatusColor(
                    _getCurrentStatus(
                      booking,
                    ),
                  ),
                  size:
                      16,
                ),
                const SizedBox(
                  width:
                      4,
                ),
                Text(
                  booking.status.capitalize!,
                  style: TextStyle(
                    color: _getStatusColor(
                      _getCurrentStatus(
                        booking,
                      ),
                    ),
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_drop_down,
            ),
          ],
        ),
      ),
    );
  }

  BookingStatus _getCurrentStatus(
    BookingModel booking,
  ) {
    return BookingStatus.values.firstWhere(
      (
        e,
      ) =>
          e.name ==
          booking.status,
      orElse:
          () =>
              BookingStatus.pending,
    );
  }

  Widget _buildAvailabilityCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const TitleText(
            'Manage Your Availability',
          ),
          _size(
            2,
          ),
          const SubtitleText(
            string:
                'Update your available time slots to let students book lessons.',
          ),
          _size(
            2,
          ),
          OnProcessButtonWidget(
            onTap:
                () => Get.to(
                  () =>
                      TeacherProfileView(),
                ),
            child: const Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  color:
                      Colors.white,
                ),
                SizedBox(
                  width:
                      12,
                ),
                SubtitleText(
                  string:
                      'Update Availability',
                  color:
                      Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(
    BookingStatus status,
  ) {
    switch (status) {
      case BookingStatus.confirmed:
        return Icons.check_circle_outline;
      case BookingStatus.canceled:
        return Icons.cancel_outlined;
      case BookingStatus.completed:
        return Icons.task_alt;
      case BookingStatus.pending:
        return Icons.hourglass_empty;
    }
  }

  Color _getStatusColor(
    BookingStatus status,
  ) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.canceled:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.pending:
        return Colors.orange;
    }
  }
}
