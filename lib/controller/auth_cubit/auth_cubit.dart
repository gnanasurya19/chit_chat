import 'package:chit_chat/model/user_data.dart';
import 'package:chit_chat/model/user_model.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit()
      : super(
          AuthViewState(
              status: PageStatus.notSignedIn,
              userModel: UserModel(email: '', password: ''),
              buttonLoader: false),
        );

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  onInit() {
    emit(AuthViewState(
        status: PageStatus.notSignedIn,
        userModel: UserModel(email: '', password: ''),
        buttonLoader: false));
  }

  doSignIn(PageStatus status, UserModel userModel) {
    if (status == PageStatus.signIn) {
      if (userModel.email == null || userModel.email!.isEmpty) {
        emit(AuthToast(type: 'error', text: 'Please enter email address'));
      } else if (userModel.password == null ||
          userModel.password!.isEmpty ||
          userModel.password!.length < 6) {
        emit(AuthToast(type: 'error', text: 'Please enter 6 digit password'));
      } else {
        util.checkNetwork().then((value) async {
          try {
            emit(AuthLoading());

            await firebaseAuth.signInWithEmailAndPassword(
                email: userModel.email!, password: userModel.password!);

            await firebaseMessaging.getToken().then(
              (token) async {
                await firebaseFirestore
                    .collection('users')
                    .where('uid', isEqualTo: firebaseAuth.currentUser!.uid)
                    .get()
                    .then((user) {
                  final UserData userData =
                      UserData.fromJson(user.docs[0].data());
                  DocumentReference messageRef = firebaseFirestore
                      .collection('users')
                      .doc(user.docs[0].id);
                  if (userData.fCM != token) {
                    userData.fCM = token;
                    messageRef.update(userData.toJson());
                  }
                });
              },
            );
            emit(AuthCancelLoading());

            if (firebaseAuth.currentUser!.emailVerified) {
              emit(AuthUserLoginSuccess());
            } else {
              emit(AuthVerifyUserEmail());
            }
          } on FirebaseAuthException catch (e) {
            emit(AuthCancelLoading());
            showFirebaseError(e);
          } catch (e) {
            emit(AuthCancelLoading());
          }
        }).catchError((e) {
          emit(AuthAlert(
              type: 'network',
              text: 'No internet\nPlease connect to internet'));
        });
      }
    } else {
      emit(AuthViewState(
          buttonLoader: true,
          status: PageStatus.signIn,
          userModel: UserModel(email: '', password: '')));
    }
  }

  dosignUP(UserModel userModel) async {
    if (userModel.name == null || userModel.name!.isEmpty) {
      emit(AuthToast(type: 'error', text: 'Please enter your name'));
    } else if (userModel.email == null || userModel.email!.isEmpty) {
      emit(AuthToast(type: 'error', text: 'Please enter email address'));
    } else if (userModel.password == null ||
        userModel.password!.isEmpty ||
        userModel.password!.length < 6) {
      emit(AuthToast(type: 'error', text: 'Please enter 6 digit password'));
    } else {
      util.checkNetwork().then((value) async {
        try {
          emit(AuthLoading());
          if (firebaseAuth.currentUser != null) {
            firebaseAuth.signOut();
          }

          //sign up user
          await firebaseAuth
              .createUserWithEmailAndPassword(
                  email: userModel.email!, password: userModel.password!)
              .then((value) async {
            //update username
            await firebaseAuth.currentUser!.updateDisplayName(userModel.name);

            final UserData user = UserData(
                userEmail: userModel.email,
                userName: userModel.name,
                uid: firebaseAuth.currentUser!.uid);

            //add user to database
            await firebaseFirestore.collection('users').add(user.toJson());
            emit(AuthCancelLoading());
            emit(AuthUserRegisterSuccess());
            emit(AuthViewState(
                buttonLoader: false,
                status: PageStatus.signIn,
                userModel: UserModel(email: '', password: '')));
          });
        } on FirebaseAuthException catch (e) {
          emit(AuthCancelLoading());
          showFirebaseError(e);
        }
      }).catchError((e) {
        emit(AuthAlert(type: 'network', text: 'Please connect to internet'));
      });
    }
  }

  verifyEmail(BuildContext context) {
    firebaseAuth.currentUser!.sendEmailVerification().catchError((e) {
      if (e.code == 'too-many-requests') {
        util.doAlert(context, 'Too Many Request \nPlease try later', 'error');
      } else {
        showFirebaseError(e);
      }
    });
  }

  forgotPassword(String email) {
    if (email.isEmpty) {
      emit(AuthToast(type: 'error', text: 'Please enter email'));
    } else {
      util.checkNetwork().then((value) async {
        firebaseAuth.sendPasswordResetEmail(email: email).then((value) {
          emit(AuthPasswordResetMailSent());
        }).catchError((e) {
          showFirebaseError(e);
        });
      });
    }
  }

  showFirebaseError(FirebaseAuthException e) {
    String errorMessage = '';
    if (e.code == 'invalid-email') {
      errorMessage = 'Please enter a valid email';
    } else if (e.code == 'wrong-password') {
      errorMessage = 'Wrong password';
    } else if (e.code == 'too-many-requests') {
      errorMessage = 'Try resetting your password or try later';
    } else if (e.code == 'user-not-found') {
      emit(AuthUserNotFound());
      return;
    } else if (e.code == 'email-already-in-use') {
      errorMessage =
          'This email already linked with an account try login or Use a different email';
    } else {
      errorMessage = e.code;
    }
    emit(AuthToast(text: errorMessage, type: 'error'));
  }

  goBack() {
    emit(AuthViewState(
        buttonLoader: true,
        status: PageStatus.notSignedIn,
        userModel: UserModel(email: '', password: '')));
  }
}
