import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:language_learning_app/app/controllers/view_controller/payment_controller.dart';
import 'package:language_learning_app/app/controllers/services/functions/date_time_conversion.dart';
import 'package:language_learning_app/app/view/dashboard/student/student_dashboard_view.dart';
import 'package:language_learning_app/app/view/widget/card.dart';
import 'package:language_learning_app/app/view/widget/custom_image.dart';
import 'package:language_learning_app/app/view/widget/title_text.dart.dart';
import 'package:language_learning_app/app/utils/components.dart';
import 'package:on_process_button_widget/on_process_button_widget.dart';
import 'package:tuple/tuple.dart';

class PaymentView
    extends
        StatelessWidget {
  Tuple7<
    String,
    String,
    String,
    String,
    double,
    DateTime,
    DateTime
  >?
  paymentData = Tuple7(
    '',
    '',
    '',
    '',
    0.0,
    DateTime.now(),
    DateTime.now(),
  );
  PaymentView({
    super.key,
    this.paymentData,
  });

  late final PaymentController controller = Get.put(
    PaymentController(
      paymentData:
          paymentData,
    ),
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
        backgroundColor:
            Theme.of(
              context,
            ).colorScheme.primary,
        title: Obx(
          () => SubtitleText(
            string:
                controller.isPaymentComplete.value
                    ? 'Payment Successful'
                    : 'Confirm Booking',
            color:
                Colors.white,
          ),
        ),
        centerTitle:
            true,
      ),
      body: Obx(
        () {
          if (controller.isPaymentComplete.value) {
            return _buildSuccessView();
          } else {
            return _buildPaymentView();
          }
        },
      ),
    );
  }

  Widget _buildPaymentView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        defaultPadding,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const TitleText(
                  'Booking Summary',
                ),
                _size(
                  1,
                ),

                _buildInfoRow(
                  'Teacher',
                  controller.teacherName.value,
                ),
                _buildInfoRow(
                  'Date',
                  controller.startTime.value.custom_d_MMM_EEE,
                ),
                _buildInfoRow(
                  'Time',
                  '${controller.startTime.value.custom_hh_mm_a} - ${controller.endTime.value.custom_hh_mm_a}',
                ),
                _buildInfoRow(
                  'Duration',
                  '1 hour',
                ),
                Divider(
                  height:
                      defaultPadding,
                ),
                _buildInfoRow(
                  'Price',
                  '\$${controller.amount.value.toStringAsFixed(2)}',
                  isHighlighted:
                      true,
                ),
              ],
            ),
          ),

          _size(
            2,
          ),

          const TitleText(
            'Payment Method',
          ),
          _size(
            2,
          ),

          CustomCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const TitleText(
                  'Credit/Debit Card',
                ),
                _size(
                  4,
                ),
                const SubtitleText(
                  string:
                      'You will be redirected to a secure payment page to enter your card details.',
                  color:
                      Colors.grey,
                ),
              ],
            ),
          ),
          _size(
            2,
          ),

          Obx(
            () =>
                controller.errorMessage.value.isNotEmpty
                    ? Container(
                      padding: const EdgeInsets.all(
                        12,
                      ),
                      margin: const EdgeInsets.only(
                        bottom:
                            16,
                      ),
                      decoration: BoxDecoration(
                        color:
                            Colors.red[50],
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                        border: Border.all(
                          color:
                              Colors.red[200]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color:
                                Colors.red[700],
                          ),
                          const SizedBox(
                            width:
                                12,
                          ),
                          Expanded(
                            child: Text(
                              controller.errorMessage.value,
                              style: TextStyle(
                                color:
                                    Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : const SizedBox.shrink(),
          ),

          Obx(
            () => OnProcessButtonWidget(
              onTap:
                  controller.isProcessing.value
                      ? null
                      : () =>
                          controller.processPayment(),
              onDone: (
                isSuccess,
              ) {
                Get.offAll(
                  StudentDashboardView(),
                );
              },
              child: SubtitleText(
                string:
                    'Pay \$${controller.amount.value.toStringAsFixed(2)}',
                color:
                    Colors.white,
              ),
            ),
          ),

          _size(
            2,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Padding(
      padding: EdgeInsets.all(
        defaultPadding,
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color:
                Colors.green,
            size:
                80,
          ),
          _size(
            3,
          ),
          const TitleText(
            'Booking Confirmed!',
          ),
          _size(
            2,
          ),
          SubtitleText(
            string:
                'Your lesson with ${controller.teacherName.value} has been booked for ${controller.startTime.value.custom_EEEE_MMM_d_yyyy} at ${controller.startTime.value.custom_hh_mm_a}.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isHighlighted =
        false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom:
            defaultPadding /
            2,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          SubtitleText(
            string:
                label,

            color:
                Colors.grey[700],
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight:
                  isHighlighted
                      ? FontWeight.bold
                      : FontWeight.normal,
              fontSize:
                  isHighlighted
                      ? 18
                      : 14,
            ),
          ),
        ],
      ),
    );
  }
}
