import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:language_learning_app/app/view/dashboard/student/student_dashboard_view.dart';
import 'package:language_learning_app/app/view/dashboard/teacher/teacher_dashboard_view.dart';
import 'package:language_learning_app/app/view/teacher/teacher_profile_view.dart';
import '../../../models/user_model.dart';
import '../../../view/auth/auth_view.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Rx<User?> firebaseUser = Rx<User?>(null);
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    
    ever(firebaseUser, setInitialScreen);
  }

  setInitialScreen(User? user) async {
  if (user == null) {
    if (Get.currentRoute != '/auth') {
      Get.off(AuthView());
    }
  } else {
    await _fetchUserData(user.uid);

    if (currentUser.value?.role == 'student') {
      Get.off(StudentDashboardView());
    } else if (currentUser.value?.role == 'teacher') {
      bool isProfileComplete = await _isTeacherProfileComplete(user.uid);

      if (!isProfileComplete) {
        Get.off(TeacherProfileView());
      } else {
        Get.off(TeacherDashboardView());
      }
    }
  }
}

Future<bool> _isTeacherProfileComplete(String uid) async {
  try {
    DocumentSnapshot doc = await _firestore.collection('teachers').doc(uid).get();
    
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      List<String> languages = List<String>.from(data['languages'] ?? []);
      String bio = data['bio'] ?? '';
      double hourlyRate = (data['hourlyRate'] ?? 0.0).toDouble();
      List<String> availability = List<String>.from(data['availability'] ?? []);
      
      return languages.isNotEmpty && 
             bio.isNotEmpty && 
             hourlyRate > 0 && 
             availability.isNotEmpty;
    }
    
    return false;
  } catch (e) {
    print('Error checking teacher profile completion: $e');
    return false;
  }
}
Future<void> _fetchUserData(String uid) async {
  try {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      if (data['createdAt'] is Timestamp) {
        data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
      }
      
      if (data['updatedAt'] is Timestamp) {
        data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate();
      }
      
      currentUser.value = UserModel.fromJson({'id': uid, ...data});
      
      if (data.containsKey('fcmTokens')) {
        List<dynamic> tokens = data['fcmTokens'] ?? [];
        print('User has ${tokens.length} FCM tokens registered');
      } else {
        print('User has no FCM tokens registered yet');
      }
      
      print('User role loaded: ${currentUser.value?.role}');
    } else {
      print('User document not found for ID: $uid');
    }
  } catch (e) {
    print('Error fetching user data: $e');
  }
}

  Future<bool> signUp(String email, String password, String name, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      User? user = result.user;
      
      if (user != null) {
        UserModel newUser = UserModel(
          id: user.uid,
          name: name,
          email: email,
          photoUrl: '',
          role: role,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(user.uid).set(newUser.toJson());
        
        if (role == 'teacher') {
          await _firestore.collection('teachers').doc(user.uid).set({
            'userId': user.uid,
            'languages': [],
            'bio': '',
            'hourlyRate': 0.0,
            'availability': [],
            'rating': 0.0,
            'totalReviews': 0,
            'createdAt': DateTime.now().toIso8601String(),
          });
        }
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error during sign up: $e');
      return false;
    }
  }

Future<bool> signIn(String email, String password) async {
  try {
    var userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    
    await _fetchUserData(userCredential.user!.uid);
    
    setInitialScreen(userCredential.user);

    return true;
  } catch (e) {
    print('Error during sign in: $e');
    return false;
  }
}

  Future<bool> signOut() async {
    try {
await _auth.signOut();
return true;
    } catch (e) {
      return false;
    }
  }
}