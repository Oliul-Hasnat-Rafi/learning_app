import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:language_learning_app/app/view/widget/card.dart';
import 'package:language_learning_app/app/view/widget/title_text.dart.dart';
import 'package:on_process_button_widget/on_process_button_widget.dart';
import '../../controllers/view_controller/teachers_controller.dart';

class TeachersView
    extends
        StatelessWidget {
  final String? languageId;

  TeachersView({
    super.key,
    this.languageId,
  });

  late final TeachersController _controller = Get.put(
    TeachersController(
      languageId:
          languageId,
    ),
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar:
          _buildAppBar(),
      body: _buildBody(
        context,
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
      title: Obx(
        () => SubtitleText(
          string:
              "${_controller.languageName.value} Teachers",

          color:
              Colors.white,
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
  ) {
    return Obx(
      () {
        if (_controller.isLoading.value) {
          return const LinearProgressIndicator();
        }

        if (_controller.teachers.isEmpty) {
          return _buildEmptyState();
        }

        return _buildTeachersList(
          context,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: TitleText(
        'No teachers available for this language',
      ),
    );
  }

  Widget _buildTeachersList(
    BuildContext context,
  ) {
    return ListView.builder(
      padding: EdgeInsets.all(
        MediaQuery.of(
              context,
            ).size.width *
            0.04,
      ),
      itemCount:
          _controller.teachers.length,
      itemBuilder: (
        context,
        index,
      ) {
        final teacherData =
            _controller.teachers[index];
        return _buildTeacherCard(
          context,
          teacherData,
        );
      },
    );
  }

  Widget _buildTeacherCard(
    BuildContext context,
    dynamic teacherData,
  ) {
    final theme = Theme.of(
      context,
    );
    final spacing =
        MediaQuery.of(
          context,
        ).size.width *
        0.04;

    return CustomCard(
      margin: EdgeInsets.only(
        bottom:
            spacing,
      ),

      child: InkWell(
        onTap:
            () => _controller.selectTeacher(
              teacherData,
            ),
        child: Padding(
          padding: EdgeInsets.all(
            spacing,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildTeacherHeader(
                context,
                teacherData,
              ),
              SizedBox(
                height:
                    spacing,
              ),

              _buildActionButtons(
                context,
                teacherData,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherHeader(
    BuildContext context,
    dynamic teacherData,
  ) {
    final avatarRadius =
        MediaQuery.of(
          context,
        ).size.width *
        0.075;
    final spacing =
        MediaQuery.of(
          context,
        ).size.width *
        0.04;

    return Row(
      children: [
        _buildTeacherAvatar(
          teacherData,
          avatarRadius,
        ),
        SizedBox(
          width:
              spacing,
        ),
        Expanded(
          child: _buildTeacherInfo(
            context,
            teacherData,
          ),
        ),
        _buildTeacherRate(
          teacherData,
        ),
      ],
    );
  }

  Widget _buildTeacherAvatar(
    dynamic teacherData,
    double radius,
  ) {
    return CircleAvatar(
      radius:
          radius,
      backgroundImage:
          teacherData.user.photoUrl.isNotEmpty
              ? NetworkImage(
                teacherData.user.photoUrl,
              )
              : null,
      child:
          teacherData.user.photoUrl.isEmpty
              ? Text(
                teacherData.user.name
                    .substring(
                      0,
                      1,
                    )
                    .toUpperCase(),
                style: TextStyle(
                  fontSize:
                      radius *
                      0.8,
                ),
              )
              : null,
    );
  }

  Widget _buildTeacherInfo(
    BuildContext context,
    dynamic teacherData,
  ) {
    final theme = Theme.of(
      context,
    );
    final smallSpacing =
        MediaQuery.of(
          context,
        ).size.width *
        0.01;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          teacherData.user.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        SizedBox(
          height:
              smallSpacing,
        ),
        _buildTeacherBio(
          teacherData,
        ),
      ],
    );
  }

  Widget _buildTeacherRate(
    dynamic teacherData,
  ) {
    return Text(
      '\$${teacherData.teacher.hourlyRate.toStringAsFixed(2)}/hr',
      style: const TextStyle(
        fontSize:
            16.0,
        fontWeight:
            FontWeight.bold,
        color:
            Colors.green,
      ),
    );
  }

  Widget _buildTeacherBio(
    dynamic teacherData,
  ) {
    return Text(
      teacherData.teacher.bio.isNotEmpty
          ? teacherData.teacher.bio
          : 'No bio available.',
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    dynamic teacherData,
  ) {
    final spacing =
        MediaQuery.of(
          context,
        ).size.width *
        0.04;

    return Row(
      children: [
         Expanded(
          child: OnProcessButtonWidget(
          onTap: 
            () {
              _controller.startChatWithTeacher(
                teacherData,
              );
            },
            child: Icon(
              Icons.message,
              color:
                  Colors.white,
            ),
          ),
        ),
        SizedBox(
          width:
              spacing,
        ),
        Expanded(
          child: OnProcessButtonWidget(
            onTap:
                () => _controller.selectTeacher(
                  teacherData,
                ),
            child: const Text(
              'Book Lesson',
            ),
          ),
        ),
      ],
    );
  }
}
