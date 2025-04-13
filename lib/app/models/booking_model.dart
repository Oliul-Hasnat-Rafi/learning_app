class BookingModel {
  final String id;
  final String studentId;
  final String teacherId;
  final String languageId;
  final DateTime startTime;
  final DateTime endTime;
  final double amount;
  final String status;
  final String paymentId;
  final String videoCallChannel;
  final String videoCallToken;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.languageId,
    required this.startTime,
    required this.endTime,
    required this.amount,
    required this.status,
    required this.paymentId,
    required this. videoCallChannel,
    required this. videoCallToken,
    required this.createdAt,
  });

  factory BookingModel.fromJson(
    Map<
      String,
      dynamic
    >
    json,
  ) {
    return BookingModel(
      id:
          json['id'],
      studentId:
          json['studentId'],
      teacherId:
          json['teacherId'],
      languageId:
          json['languageId'],
      startTime: DateTime.parse(
        json['startTime'],
      ),
      endTime: DateTime.parse(
        json['endTime'],
      ),
      amount:
          json['amount'].toDouble(),
      status:
          json['status'],
      paymentId:
          json['paymentId'],
      videoCallChannel:
          json['videoCallChannel'],
      videoCallToken:
          json['videoCallToken'],

      createdAt: DateTime.parse(
        json['createdAt'],
      ),
    );
  }

  Map<
    String,
    dynamic
  >
  toJson() {
    return {
      'id':
          id,
      'studentId':
          studentId,
      'teacherId':
          teacherId,
      'languageId':
          languageId,
      'startTime':
          startTime.toIso8601String(),
      'endTime':
          endTime.toIso8601String(),
      'amount':
          amount,
      'status':
          status,
      'paymentId':
          paymentId,
      'videoCallChannel':
          videoCallChannel,
      'videoCallToken':
          videoCallToken,
      'createdAt':
          createdAt.toIso8601String(),
    };
  }
}

enum BookingStatus {
  pending,
  confirmed,
  completed,
  canceled,
}
