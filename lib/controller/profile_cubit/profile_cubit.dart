import 'package:chit_chat/firebase/firebase_repository.dart';
import 'package:chit_chat/model/user_model.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial(user: UserModel())) {
    onLoad();
  }

  bool isNotification = false;
  bool isDark = false;
  UserModel userModel = UserModel();
  FirebaseRepository firebaseRepository = FirebaseRepository();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  getProfile() {
    userModel = UserModel(
      email: firebaseAuth.currentUser!.email,
      name: firebaseAuth.currentUser!.displayName!,
      profileURL: firebaseAuth.currentUser!.photoURL,
    );
    emit(ProfileInitial(
        user: userModel, isDarkTheme: isDark, isNotification: isNotification));
  }

  Future<void> onLoad() async {
    userModel = UserModel(
      email: firebaseAuth.currentUser!.email,
      name: firebaseAuth.currentUser!.displayName!,
      profileURL: firebaseAuth.currentUser!.photoURL,
    );

    CollectionReference query = firebaseFirestore.collection('users');

    await query.where('uid', isEqualTo: currentUserId).get().then(
      (value) {
        if (value.docs.isNotEmpty) {
          if (value.docs.first['fcm'] == '' ||
              value.docs.first['fcm'] == null) {
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

  pickImage(ImageSource type) {
    util.captureImage(type).then((value) {
      if (value != null) {
        updateProfile(value);
      }
    });
  }

  changeTheme() {
    isDark = !isDark;
    emit(ProfileInitial(
        user: userModel, isNotification: isNotification, isDarkTheme: isDark));
  }

  updateProfile(XFile? value) {
    firebaseRepository.uploadFile(value!, 'profile').then((value) async {
      userModel.profileURL = value;
      firebaseRepository.updateUser(currentUserId, {"profileURL": value});
      await firebaseAuth.currentUser!.updatePhotoURL(value);
    });
  }

  editProfile() {}

  Future signout() async {
    firebaseRepository.updateUser(currentUserId, {"fcm": ''}).then((value) {
      firebaseAuth.signOut().then((value) {
        emit(SignOut());
      });
    });
  }
}
