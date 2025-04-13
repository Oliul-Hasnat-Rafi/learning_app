import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:language_learning_app/app/utils/secret.dart';

class PaymentService
    extends
        GetxService {
  Future<
    Map<
      String,
      dynamic
    >
  >
  createPaymentIntent(
    double amount,
    String currency,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://api.stripe.com/v1/payment_intents',
        ),
        headers: {
          'Authorization':
              'Bearer ${Secret.stripeSecretKey}',
          'Content-Type':
              'application/x-www-form-urlencoded',
        },
        body: {
          'amount':
              (amount *
                      100)
                  .toInt()
                  .toString(),
          'currency':
              currency,
        },
      );

      return json.decode(
        response.body,
      );
    } catch (
      e
    ) {
      print(
        'Error creating payment intent: $e',
      );
      throw e;
    }
  }

  Future<
    String
  >
  makePayment({
    required double amount,
    required String currency,
  }) async {
    try {
      print(
        'Starting payment process...',
      );
      final paymentIntentData = await createPaymentIntent(
        amount,
        currency,
      );
      print(
        'Payment intent created: ${paymentIntentData['id']}',
      );

      print(
        'Initializing payment sheet...',
      );
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret:
              paymentIntentData['client_secret'],
          merchantDisplayName:
              'Language Learning App',
          style:
              ThemeMode.light,
        ),
      );
      print(
        'Payment sheet initialized successfully',
      );

      await Stripe.instance.presentPaymentSheet();
      print(
        'Payment sheet presented',
      );

      return paymentIntentData['id'];
    } catch (
      e
    ) {
      print(
        'Payment error: $e',
      );
      rethrow;
    }
  }
}
