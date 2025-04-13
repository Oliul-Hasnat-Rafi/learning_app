import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:language_learning_app/app/controllers/view_controller/teacher_profile_controller.dart';
import 'package:intl/intl.dart';
import 'package:language_learning_app/app/view/dashboard/teacher/teacher_dashboard_view.dart';
import 'package:language_learning_app/app/view/widget/button_3.dart';
import 'package:language_learning_app/app/view/widget/card.dart';
import 'package:language_learning_app/app/view/widget/custom_text_field_widget.dart';
import 'package:language_learning_app/app/view/widget/title_text.dart.dart';
import 'package:language_learning_app/app/utils/components.dart';
import 'package:on_process_button_widget/on_process_button_widget.dart';

class TeacherProfileView
    extends
        StatelessWidget {
  TeacherProfileView({
    super.key,
  });

  final TeacherProfileController controller = Get.put(
    TeacherProfileController(),
  );
  _size(
    int i,
  ) {
    return SizedBox(
      height:
          defaultPadding /
          i,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Teacher Profile',
        ),
        actions: [
          Button3(
            child: const Icon(
              Icons.save,
            ),
            onTap: () async {
              bool success =
                  await controller.saveTeacherProfile();
              if (success) {
                Get.snackbar(
                  'Success',
                  'Profile updated successfully',
                );
                Get.offAll(
                  () =>
                      TeacherDashboardView(),
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to update profile',

                  backgroundColor:
                      Colors.red,
                );
              }
            },
          ),
        ],
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const LinearProgressIndicator();
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(
              defaultPadding,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const TitleText(
                  'Your Bio',
                ),
                _size(
                  2,
                ),
                CustomTextFormField(
                  hintText:
                      'Tell students about yourself, your experience, and teaching style...',
                  maxLines:
                      5,
                  onChanged:
                      (
                        value,
                      ) =>
                          controller.bio.value = value,
                  textEditingController: TextEditingController(
                    text:
                        controller.bio.value,
                  ),
                ),

                _size(
                  2,
                ),

                const TitleText(
                  'Hourly Rate (USD)',
                ),
                _size(
                  2,
                ),
                CustomTextFormField(
                  hintText:
                      'Enter your hourly rate',
                  keyboardType:
                      TextInputType.number,
                  onChanged: (
                    value,
                  ) {
                    double? rate = double.tryParse(
                      value,
                    );
                    if (rate !=
                        null) {
                      controller.hourlyRate.value = rate;
                    }
                  },
                  prefixIcon: const Icon(
                    Icons.attach_money,
                  ),
                  textEditingController: TextEditingController(
                    text:
                        controller.hourlyRate.value.toString(),
                  ),
                ),
                _size(
                  2,
                ),

                const TitleText(
                  'Languages You Teach',
                ),
                _size(
                  2,
                ),
                Wrap(
                  spacing:
                      8,
                  runSpacing:
                      8,
                  children:
                      controller.availableLanguages.map(
                        (
                          language,
                        ) {
                          bool isSelected = controller.selectedLanguageIds.contains(
                            language.id,
                          );

                          return FilterChip(
                            label: Text(
                              language.name,
                            ),
                            selected:
                                isSelected,
                            onSelected: (
                              selected,
                            ) {
                              controller.toggleLanguage(
                                language.id,
                              );
                            },
                            avatar: CircleAvatar(
                              backgroundImage: AssetImage(
                                language.flagUrl,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                ),

                _size(
                  2,
                ),

                const TitleText(
                  'Your Availability',
                ),
                _size(
                  2,
                ),

                // ElevatedButton.icon(
                //   icon: const Icon(
                //     Icons.add,
                //   ),
                //   label: const Text(
                //     'Add Available Time Slot',
                //   ),
                //   onPressed: () async {
                //     final DateTime? pickedDate = await showDatePicker(
                //       context:
                //           context,
                //       initialDate:
                //           DateTime.now(),
                //       firstDate:
                //           DateTime.now(),
                //       lastDate: DateTime.now().add(
                //         const Duration(
                //           days:
                //               60,
                //         ),
                //       ),
                //     );

                //     if (pickedDate !=
                //         null) {
                //       final TimeOfDay? pickedTime = await showTimePicker(
                //         context:
                //             context,
                //         initialTime:
                //             TimeOfDay.now(),
                //       );

                //       if (pickedTime !=
                //           null) {
                //         final DateTime combinedDateTime = DateTime(
                //           pickedDate.year,
                //           pickedDate.month,
                //           pickedDate.day,
                //           pickedTime.hour,
                //           pickedTime.minute,
                //         );

                //         controller.addAvailabilitySlot(
                //           combinedDateTime,
                //         );
                //       }
                //     }
                //   },
                // ),
                OnProcessButtonWidget(
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context:
                          context,
                      initialDate:
                          DateTime.now(),
                      firstDate:
                          DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(
                          days:
                              60,
                        ),
                      ),
                    );

                    if (pickedDate !=
                        null) {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context:
                            context,
                        initialTime:
                            TimeOfDay.now(),
                      );

                      if (pickedTime !=
                          null) {
                        final DateTime combinedDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );

                        controller.addAvailabilitySlot(
                          combinedDateTime,
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Add Available Time Slot',
                  ),
                ),
                _size(
                  2,
                ),
                controller.availability.isEmpty
                    ? const Center(
                      child: TitleText(
                        'No availability slots added yet',
                      ),
                    )
                    : ListView.builder(
                      shrinkWrap:
                          true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount:
                          controller.availability.length,
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        final slot =
                            controller.availability[index];
                        final dateTime = DateTime.parse(
                          slot,
                        );
                        final formattedDate = DateFormat(
                          'EEEE, MMMM d, yyyy',
                        ).format(
                          dateTime,
                        );
                        final formattedTime = DateFormat(
                          'h:mm a',
                        ).format(
                          dateTime,
                        );

                        return CustomCard(
                          margin: EdgeInsets.only(
                            bottom:
                                defaultPadding,
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.access_time,
                            ),
                            title: Text(
                              formattedDate,
                            ),
                            subtitle: Text(
                              formattedTime,
                            ),
                           
                            
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color:
                                    Colors.red,
                              ),
                              onPressed:
                                  () => controller.removeAvailabilitySlot(
                                    slot,
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}
