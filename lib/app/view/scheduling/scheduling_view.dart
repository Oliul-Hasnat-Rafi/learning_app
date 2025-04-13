import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:language_learning_app/app/controllers/services/functions/date_time_conversion.dart';
import 'package:language_learning_app/app/utils/components.dart';
import 'package:language_learning_app/app/view/widget/title_text.dart.dart';
import 'package:tuple/tuple.dart';
import '../../controllers/view_controller/scheduling_controller.dart';

class SchedulingView
    extends
        StatelessWidget {
  Tuple4<
    String,
    String,
    double,
    String
  >?
  teacherData = const Tuple4(
    '',
    '',
    0.0,
    '',
  );

  SchedulingView({
    super.key,
    this.teacherData,
  });

  late final SchedulingController controller = Get.put(
    SchedulingController(
      teacherData:
          teacherData,
    ),
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(
      context,
    );
    final colorScheme =
        theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation:
            0,
        title: const SubtitleText(
          string:
              'Book a Session',
          color:
              Colors.white,
        ),
        centerTitle:
            true,
        backgroundColor:
            colorScheme.primary,
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color:
                        colorScheme.primary,
                  ),
                  SizedBox(
                    height:
                        defaultPadding /
                        1.5,
                  ),
                  Text(
                    'Loading available slots...',
                    style:
                        theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          if (controller.availableSlots.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.event_busy,
                    size:
                        80,
                    color:
                        Colors.grey,
                  ),
                  SizedBox(
                    height:
                        defaultPadding -
                        4,
                  ),
                  Text(
                    'No slots available',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height:
                        defaultPadding /
                        3,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          defaultPadding +
                          8,
                    ),
                    child: Text(
                      'There are no available time slots for ${controller.teacherName.value} at this time.',
                      textAlign:
                          TextAlign.center,
                      style:
                          theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            );
          }

          final uniqueDays =
              controller.getUniqueDays();

          return Column(
            children: [
              _buildTeacherProfile(
                context,
              ),

              SizedBox(
                height:
                    defaultPadding /
                    3,
              ),

              Expanded(
                child: _buildTimeSlotsList(
                  uniqueDays,
                  context,
                ),
              ),

              _buildBottomButton(
                context,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTeacherProfile(
    BuildContext context,
  ) {
    final theme = Theme.of(
      context,
    );

    return Container(
      margin: EdgeInsets.all(
        defaultPadding /
            1.5,
      ),
      padding: EdgeInsets.all(
        defaultPadding /
            1.5,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(
              0.8,
            ),
            theme.colorScheme.primary,
          ],
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          defaultPadding /
              1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.1,
            ),
            blurRadius:
                defaultPadding -
                14,
            offset: const Offset(
              0,
              5,
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag:
                'teacher-${controller.teacherName.value}',
            child: CircleAvatar(
              radius:
                  defaultPadding +
                  8,
              backgroundColor:
                  Colors.white,
              child: Text(
                controller.teacherName.value.isNotEmpty
                    ? controller.teacherName.value
                        .substring(
                          0,
                          1,
                        )
                        .toUpperCase()
                    : "T",
                style: TextStyle(
                  fontSize:
                      28,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          SizedBox(
            width:
                defaultPadding /
                1.5,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  controller.teacherName.value,
                  style: const TextStyle(
                    fontSize:
                        22,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Colors.white,
                  ),
                ),
                SizedBox(
                  height:
                      defaultPadding /
                      6,
                ),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        defaultPadding /
                        2,
                    vertical:
                        defaultPadding /
                        4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Colors.white,
                    borderRadius: BorderRadius.circular(
                      defaultPadding -
                          4,
                    ),
                  ),
                  child: Text(
                    '\$${controller.hourlyRate.value.toStringAsFixed(2)}/hour',
                    style: TextStyle(
                      fontSize:
                          16,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotsList(
    List<
      DateTime
    >
    uniqueDays,
    BuildContext context,
  ) {
    final theme = Theme.of(
      context,
    );

    return Container(
      margin: EdgeInsets.only(
        top:
            defaultPadding /
            1.5,
      ),
      decoration: BoxDecoration(
        color:
            Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            defaultPadding +
                4,
          ),
          topRight: Radius.circular(
            defaultPadding +
                4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.05,
            ),
            blurRadius:
                defaultPadding -
                14,
            offset: const Offset(
              0,
              -5,
            ),
          ),
        ],
      ),
      child: Obx(
        () {
          final selectedDate =
              controller.selectedDate.value;
          if (selectedDate ==
              null) {
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(
                defaultPadding /
                    1.5,
                defaultPadding,
                defaultPadding /
                    1.5,
                defaultPadding /
                    1.5,
              ),
              itemCount:
                  uniqueDays.length,
              itemBuilder: (
                context,
                dayIndex,
              ) {
                final day =
                    uniqueDays[dayIndex];
                return _buildDaySlots(
                  day,
                  context,
                );
              },
            );
          } else {
            return ListView(
              padding: EdgeInsets.fromLTRB(
                defaultPadding /
                    1.5,
                defaultPadding,
                defaultPadding /
                    1.5,
                defaultPadding /
                    1.5,
              ),
              children: [
                _buildDaySlots(
                  selectedDate,
                  context,
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildDaySlots(
    DateTime day,
    BuildContext context,
  ) {
    final theme = Theme.of(
      context,
    );
    final slots = controller.getSlotsForDay(
      day,
    );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom:
                defaultPadding /
                1.5,
          ),
          child: Row(
            children: [
              Icon(
                Icons.event,
                color:
                    theme.colorScheme.primary,
                size:
                    20,
              ),
              SizedBox(
                width:
                    defaultPadding /
                    3,
              ),
              Text(
                day.custom_EEEE_MMM_d_yyyy,
                style: TextStyle(
                  fontSize:
                      18,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),

        Text(
          'Available Time Slots',
          style: TextStyle(
            fontSize:
                16,
            fontWeight:
                FontWeight.w500,
            color: theme.colorScheme.onSurface.withOpacity(
              0.7,
            ),
          ),
        ),

        SizedBox(
          height:
              defaultPadding /
              2,
        ),

        Wrap(
          spacing:
              defaultPadding -
              14,
          runSpacing:
              defaultPadding /
              2,
          children:
              slots.map(
                (
                  slot,
                ) {
                  return Obx(
                    () {
                      final isSelected =
                          controller.selectedSlot.value !=
                              null &&
                          controller.selectedSlot.value!.isAtSameMomentAs(
                            slot,
                          );

                      return GestureDetector(
                        onTap: () {
                          if (controller.selectedSlot.value !=
                                  null &&
                              controller.selectedSlot.value!.isAtSameMomentAs(
                                slot,
                              )) {
                            controller.selectTimeSlot(
                              null,
                            );
                          } else {
                            controller.selectTimeSlot(
                              slot,
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(
                            milliseconds:
                                200,
                          ),
                          width:
                              (MediaQuery.of(
                                    context,
                                  ).size.width -
                                  (defaultPadding *
                                      2)) /
                              3,
                          padding: EdgeInsets.symmetric(
                            vertical:
                                defaultPadding -
                                14,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(
                              defaultPadding /
                                  2,
                            ),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? theme.colorScheme.primary
                                      : Colors.grey.shade300,
                              width:
                                  1.5,
                            ),
                            boxShadow:
                                isSelected
                                    ? [
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius:
                                            defaultPadding /
                                            3,
                                        offset: const Offset(
                                          0,
                                          2,
                                        ),
                                      ),
                                    ]
                                    : null,
                          ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Text(
                                slot.custom_hh_mm_a,
                                style: TextStyle(
                                  fontSize:
                                      15,
                                  fontWeight:
                                      FontWeight.w600,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ).toList(),
        ),

        SizedBox(
          height:
              defaultPadding,
        ),
      ],
    );
  }

  Widget _buildBottomButton(
    BuildContext context,
  ) {
    final theme = Theme.of(
      context,
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
        defaultPadding /
            1.5,
        defaultPadding /
            2,
        defaultPadding /
            1.5,
        defaultPadding /
                1.5 +
            MediaQuery.of(
              context,
            ).padding.bottom,
      ),
      decoration: BoxDecoration(
        color:
            Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            defaultPadding,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.05,
            ),
            blurRadius:
                defaultPadding -
                14,
            offset: const Offset(
              0,
              -5,
            ),
          ),
        ],
      ),
      child: Obx(
        () {
          final isSlotSelected =
              controller.selectedSlot.value !=
              null;

          return Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              if (isSlotSelected)
                Padding(
                  padding: EdgeInsets.only(
                    bottom:
                        defaultPadding /
                        2,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Time',
                              style: TextStyle(
                                fontSize:
                                    14,
                                color:
                                    Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(
                              height:
                                  defaultPadding /
                                  6,
                            ),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize:
                                      16,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      theme.colorScheme.onSurface,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        controller.selectedSlot.value!.custom_d_MMM,
                                    style: const TextStyle(
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        ' • ',
                                  ),
                                  TextSpan(
                                    text:
                                        controller.selectedSlot.value!.custom_hh_mm_a,
                                    style: TextStyle(
                                      color:
                                          theme.colorScheme.primary,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize:
                                  14,
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(
                            height:
                                defaultPadding /
                                6,
                          ),
                          Text(
                            '\$${controller.hourlyRate.value.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize:
                                  20,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              ElevatedButton(
                onPressed:
                    isSlotSelected
                        ? () =>
                            controller.proceedToPayment()
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.primary,
                  foregroundColor:
                      Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical:
                        defaultPadding /
                        1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      defaultPadding /
                          1.5,
                    ),
                  ),
                  elevation:
                      0,
                ),
                child: Text(
                  isSlotSelected
                      ? 'Proceed to Payment'
                      : 'Select a Time Slot',
                  style: const TextStyle(
                    fontSize:
                        16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
