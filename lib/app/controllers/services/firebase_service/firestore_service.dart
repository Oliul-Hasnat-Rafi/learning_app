import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../models/language_model.dart';
import '../../../models/teacher_model.dart';
import '../../../models/booking_model.dart';

class FirestoreService
    extends
        GetxService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<
    List<
      LanguageModel
    >
  >
  getLanguages() async {
    try {
      QuerySnapshot
      snapshot =
          await _firestore
              .collection(
                'languages',
              )
              .get();

      return snapshot.docs.map(
        (
          doc,
        ) {
          Map<
            String,
            dynamic
          >
          data =
              doc.data()
                  as Map<
                    String,
                    dynamic
                  >;
          return LanguageModel.fromJson(
            {
              'id':
                  doc.id,
              ...data,
            },
          );
        },
      ).toList();
    } catch (
      e
    ) {
      print(
        'Error fetching languages: $e',
      );
      return [];
    }
  }

  Future<
    List<
      TeacherModel
    >
  >
  getTeachersByLanguage(
    String languageId,
  ) async {
    try {
      QuerySnapshot
      snapshot =
          await _firestore
              .collection(
                'teachers',
              )
              .where(
                'languages',
                arrayContains:
                    languageId,
              )
              .get();

      List<
        TeacherModel
      >
      teachers =
          [];

      for (var doc in snapshot.docs) {
        Map<
          String,
          dynamic
        >
        data =
            doc.data()
                as Map<
                  String,
                  dynamic
                >;
        teachers.add(
          TeacherModel.fromJson(
            {
              'id':
                  doc.id,
              ...data,
            },
          ),
        );
      }

      return teachers;
    } catch (
      e
    ) {
      print(
        'Error fetching teachers: $e',
      );
      return [];
    }
  }

  Future<
    TeacherModel?
  >
  getTeacherById(
    String teacherId,
  ) async {
    try {
      DocumentSnapshot
      doc =
          await _firestore
              .collection(
                'teachers',
              )
              .doc(
                teacherId,
              )
              .get();

      if (doc.exists) {
        Map<
          String,
          dynamic
        >
        data =
            doc.data()
                as Map<
                  String,
                  dynamic
                >;
        return TeacherModel.fromJson(
          {
            'id':
                doc.id,
            ...data,
          },
        );
      }

      return null;
    } catch (
      e
    ) {
      print(
        'Error fetching teacher: $e',
      );
      return null;
    }
  }

  // Bookings
  Future<
    String
  >
  createBooking(
    BookingModel booking,
  ) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(
            'bookings',
          )
          .add(
            booking.toJson(),
          );

      await updateTeacherAvailability(
        booking.teacherId,
        booking.startTime,
        booking.endTime,
      );

      return docRef.id;
    } catch (
      e
    ) {
      print(
        'Error creating booking: $e',
      );
      throw e;
    }
  }

  Future<
    void
  >
  updateTeacherAvailability(
    String teacherId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      DocumentSnapshot
      teacherDoc =
          await _firestore
              .collection(
                'teachers',
              )
              .doc(
                teacherId,
              )
              .get();

      if (teacherDoc.exists) {
        List<
          String
        >
        availability = List<
          String
        >.from(
          teacherDoc.get(
            'availability',
          ),
        );

        availability.removeWhere(
          (
            slot,
          ) {
            DateTime slotTime = DateTime.parse(
              slot,
            );
            return slotTime.isAtSameMomentAs(
                  startTime,
                ) ||
                (slotTime.isAfter(
                      startTime,
                    ) &&
                    slotTime.isBefore(
                      endTime,
                    ));
          },
        );

        await _firestore
            .collection(
              'teachers',
            )
            .doc(
              teacherId,
            )
            .update(
              {
                'availability':
                    availability,
              },
            );
      }
    } catch (
      e
    ) {
      print(
        'Error updating teacher availability: $e',
      );
      throw e;
    }
  }

  Future<
    List<
      BookingModel
    >
  >
  getStudentBookings(
    String studentId,
  ) async {
    try {
      QuerySnapshot
      snapshot =
          await _firestore
              .collection(
                'bookings',
              )
              .where(
                'studentId',
                isEqualTo:
                    studentId,
              )
              .orderBy(
                'startTime',
              )
              .get();

      return snapshot.docs.map(
        (
          doc,
        ) {
          Map<
            String,
            dynamic
          >
          data =
              doc.data()
                  as Map<
                    String,
                    dynamic
                  >;
          return BookingModel.fromJson(
            {
              'id':
                  doc.id,
              ...data,
            },
          );
        },
      ).toList();
    } catch (
      e
    ) {
      print(
        'Error fetching student bookings: $e',
      );
      return [];
    }
  }

  Future<
    List<
      BookingModel
    >
  >
  getTeacherBookings(
    String teacherId,
  ) async {
    try {
      QuerySnapshot
      snapshot =
          await _firestore
              .collection(
                'bookings',
              )
              .where(
                'teacherId',
                isEqualTo:
                    teacherId,
              )
              .orderBy(
                'startTime',
              )
              .get();

      return snapshot.docs.map(
        (
          doc,
        ) {
          Map<
            String,
            dynamic
          >
          data =
              doc.data()
                  as Map<
                    String,
                    dynamic
                  >;
          return BookingModel.fromJson(
            {
              'id':
                  doc.id,
              ...data,
            },
          );
        },
      ).toList();
    } catch (
      e
    ) {
      print(
        'Error fetching teacher bookings: $e',
      );
      return [];
    }
  }

  Future<
    bool
  >
  updateTeacherProfile({
    required String teacherId,
    List<
      String
    >?
    languages,
    String? bio,
    double? hourlyRate,
    List<
      String
    >?
    availability,
  }) async {
    try {
      Map<
        String,
        dynamic
      >
      updateData =
          {};

      if (languages !=
          null) {
        updateData['languages'] =
            languages;
      }
      if (bio !=
          null) {
        updateData['bio'] =
            bio;
      }
      if (hourlyRate !=
          null) {
        updateData['hourlyRate'] =
            hourlyRate;
      }
      if (availability !=
          null) {
        updateData['availability'] =
            availability;
      }

      updateData['updatedAt'] =
          DateTime.now().toIso8601String();

      await _firestore
          .collection(
            'teachers',
          )
          .doc(
            teacherId,
          )
          .update(
            updateData,
          );
      return true;
    } catch (
      e
    ) {
      print(
        'Error updating teacher profile: $e',
      );
      return false;
    }
  }

  Future<
    void
  >
  setupInitialData() async {
    List<
      Map<
        String,
        dynamic
      >
    >
    languages = [
      {
        'name':
            'French',
        'flagUrl':
            'assets/flags/french.png',
        'description':
            'Learn French with native speakers.',
      },
      {
        'name':
            'Spanish',
        'flagUrl':
            'assets/flags/spanish.png',
        'description':
            'Learn Spanish with experienced teachers.',
      },
      {
        'name':
            'Japanese',
        'flagUrl':
            'assets/flags/japanese.png',
        'description':
            'Master Japanese language and culture.',
      },
      {
        'name':
            'German',
        'flagUrl':
            'assets/flags/german.png',
        'description':
            'Learn German from professionals.',
      },
      {
        'name':
            'Chinese',
        'flagUrl':
            'assets/flags/chinese.png',
        'description':
            'Learn Mandarin Chinese with expert tutors.',
      },
    ];

    QuerySnapshot
    existingLanguages =
        await _firestore
            .collection(
              'languages',
            )
            .get();

    if (existingLanguages.docs.isEmpty) {
      for (var language in languages) {
        await _firestore
            .collection(
              'languages',
            )
            .add(
              language,
            );
      }
    }
  }
}
