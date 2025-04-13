import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSetupUtil {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static Future<
    void
  >
  uploadLanguages() async {
    try {
      QuerySnapshot
      existingLanguages =
          await _firestore
              .collection(
                'languages',
              )
              .get();

      if (existingLanguages.docs.isNotEmpty) return;

      List<
        Map<
          String,
          dynamic
        >
      >
      languages = [
        {
          "id":
              "1",
          'name':
              'French',
          'flagUrl':
              'assets/flags/french.png',
          'description':
              'Learn French with native speakers.',
        },
        {
          "id":
              "2",
          'name':
              'Spanish',
          'flagUrl':
              'assets/flags/spanish.png',
          'description':
              'Learn Spanish with experienced teachers.',
        },
        {
          "id":
              "3",
          'name':
              'Japanese',
          'flagUrl':
              'assets/flags/japanese.png',
          'description':
              'Master Japanese language and culture.',
        },
        {
          "id":
              "4",
          'name':
              'German',
          'flagUrl':
              'assets/flags/german.png',
          'description':
              'Learn German from professionals.',
        },
        {
          "id":
              "5",
          'name':
              'Chinese',
          'flagUrl':
              'assets/flags/chinese.png',
          'description':
              'Learn Mandarin Chinese with expert tutors.',
        },
        {
          "id":
              "6",
          'name':
              'Arabic',
          'flagUrl':
              'assets/flags/arabic.png',
          'description':
              'Discover Arabic language and its rich heritage.',
        },
      ];

      for (var language in languages) {
        await _firestore
            .collection(
              'languages',
            )
            .add(
              language,
            );
      }
    } catch (
      e
    ) {
      print(
        'Error uploading languages: $e',
      );
    }
  }

  static Future<
    bool
  >
  addSingleLanguage({
    required String name,
    required String flagUrl,
    required String description,
  }) async {
    try {
      QuerySnapshot
      existingLanguage =
          await _firestore
              .collection(
                'languages',
              )
              .where(
                'name',
                isEqualTo:
                    name,
              )
              .get();

      if (existingLanguage.docs.isNotEmpty) {
        print(
          'Language $name already exists in the database.',
        );
        return false;
      }

      Map<
        String,
        dynamic
      >
      languageData = {
        'name':
            name,
        'flagUrl':
            flagUrl,
        'description':
            description,
        'createdAt':
            DateTime.now().toIso8601String(),
      };

      await _firestore
          .collection(
            'languages',
          )
          .add(
            languageData,
          );

      return true;
    } catch (
      e
    ) {
      print(
        'Error adding language: $e',
      );
      return false;
    }
  }
}
