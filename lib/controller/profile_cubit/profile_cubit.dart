import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:chit_chat_1/firebase/firebase_repository.dart';
import 'package:chit_chat_1/model/user_data.dart';
import 'package:chit_chat_1/res/colors.dart';
import 'package:chit_chat_1/res/common_instants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial(user: UserData())) {
    onLoad();
  }

  bool isNotification = false;
  bool isDark = false;
  UserData userModel = UserData();
  FirebaseRepository firebaseRepository = FirebaseRepository();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future getProfile() async {
    userModel = UserData(
      userEmail: firebaseAuth.currentUser!.email,
      userName: firebaseAuth.currentUser!.displayName!,
      profileURL: firebaseAuth.currentUser!.photoURL,
    );
    emit(ProfileInitial(
        user: userModel, isDarkTheme: isDark, isNotification: isNotification));
  }

  onProfilePage() {
    emit(ProfileInitial(
        user: userModel, isNotification: isNotification, isDarkTheme: isDark));
  }

  Future<void> onLoad() async {
    CollectionReference<Map<String, dynamic>> query =
        firebaseFirestore.collection('users');

    query.doc().get().then((v) {});

    await query.where('uid', isEqualTo: currentUserId).get().then(
      (value) {
        if (value.docs.isNotEmpty) {
          userModel = UserData.fromJson(value.docs.first.data());
          if (userModel.fCM == '' || userModel.fCM == null) {
            isNotification = false;
          } else {
            isNotification = true;
          }
        }
      },
    );

    SharedPreferences sp = await SharedPreferences.getInstance();
    String theme = sp.getString('thememode') ?? 'light';
    if (theme == 'light') {
      isDark = false;
    } else {
      isDark = true;
    }
    emit(ProfileInitial(
        user: userModel, isNotification: isNotification, isDarkTheme: isDark));
  }

  changeTheme(ThemeSwitcherState theme) async {
    isDark = !isDark;
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (isDark) {
      theme.changeTheme(theme: MyAppTheme.darkTheme);
      sp.setString('thememode', 'dark');
    } else {
      theme.changeTheme(theme: MyAppTheme.lightTheme);
      sp.setString('thememode', 'light');
    }
    emit(ProfileInitial(
        user: userModel, isNotification: isNotification, isDarkTheme: isDark));
  }

  updateProfile(XFile? value) async {
    await firebaseRepository.uploadFile(value!, 'profile').then((value) async {
      userModel.profileURL = value;
      firebaseRepository.updateUser(currentUserId, {"profileURL": value});
      await firebaseAuth.currentUser!.updatePhotoURL(value);
    });
  }

  signoutAlert() {
    emit(SigningOutState());
  }

  signout() async {
    firebaseRepository.updateUser(currentUserId, {"fcm": ''}).then((value) {
      firebaseAuth.signOut().then((value) {
        emit(SignOut());
      });
    });
  }

  passwordResetDialog() {
    emit(ChangePasswordState());
  }

  changePassword(String password, String newPassword) {
    util.checkNetwork().then((e) {
      firebaseAuth
          .signInWithEmailAndPassword(
              email: firebaseAuth.currentUser!.email!, password: password)
          .then((v) {
        firebaseAuth.currentUser!.updatePassword(newPassword).then((e) {
          emit(PasswordUpdated());
        }).catchError((e) {
          showFirebaseError(e);
        });
      }).catchError((e) {
        showFirebaseError(e);
      });
    }).catchError((e) {
      emit(AlertState(type: 'network', text: 'Please connect to internet'));
    });
  }

  showFirebaseError(FirebaseAuthException e) {
    String errorMessage = '';
    if (e.code == 'wrong-password') {
      errorMessage = 'Wrong password';
    } else if (e.code == 'too-many-requests') {
      errorMessage = 'Try resetting your password or try later';
    } else {
      errorMessage = e.code;
    }
    emit(AlertToast(type: 'error', text: errorMessage));
  }

  changeNotificationPref() async {
    isNotification = !isNotification;
    String fcm = '';
    if (isNotification) {
      await firebaseMessaging.getToken().then((value) {
        fcm = value ?? '';
      });
    }
    firebaseRepository.updateUser(currentUserId, {"fcm": fcm});
    emit(ProfileInitial(
        user: userModel, isNotification: isNotification, isDarkTheme: isDark));
  }

  void editProfile() {
    emit(ProfileInitial(
        user: userModel, isDarkTheme: isDark, isNotification: isNotification));
  }

  updateProfileData(String name, String mobileNumber) async {
    emit(ProfileLoader());
    if (name != userModel.userName) {
      userModel.userName = name;
      await firebaseAuth.currentUser!.updateDisplayName('name');
    }
    if (mobileNumber != userModel.phoneNumber) {
      userModel.phoneNumber = mobileNumber;
      await firebaseRepository.updateUser(
          firebaseAuth.currentUser!.uid, {"mobileNumber": mobileNumber});
    }
    if (editedProfile != null) {
      await updateProfile(XFile(editedProfile!));
      editedProfile = null;
    }
    emit(ProfileLoaderCancel());
    emit(ProfileInitial(
        user: userModel, isDarkTheme: isDark, isNotification: isNotification));
    emit(ProfileUpdate());
  }

  resetProfileField() {
    editedProfile = null;
    emit(ProfileInitial(
        user: userModel, isDarkTheme: isDark, isNotification: isNotification));
  }

  String? editedProfile;
  captureImage(ImageSource type) async {
    await util.captureImage(type).then((value) {
      editedProfile = value!.path;
      emit(ProfileInitial(user: userModel, editedprofile: editedProfile));
    });
  }
}
