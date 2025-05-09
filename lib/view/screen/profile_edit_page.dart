import 'dart:io';

import 'package:chit_chat/controller/profile_cubit/profile_cubit.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:chit_chat/res/custom_widget/svg_icon.dart';
import 'package:chit_chat/view/widget/circular_profile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  late ProfileCubit profileCubit;
  bool isEdited = false;
  bool isProfileEdited = false;
  late String name;
  late String mobileNO;

  @override
  void initState() {
    profileCubit = BlocProvider.of<ProfileCubit>(context);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        profileCubit.editProfile();
      },
    );
    super.initState();
  }

  editImage() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            backgroundColor: Theme.of(context).colorScheme.onTertiary,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    profileCubit.captureImage(ImageSource.camera).then((value) {
                      setState(() {
                        isProfileEdited = true;
                      });
                    }).catchError((e) {});
                  },
                  leading: const Icon(
                    Icons.camera,
                  ),
                  title: Text(
                    'Camera',
                    style: style.text.regular,
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    profileCubit
                        .captureImage(ImageSource.gallery)
                        .then((value) {
                      setState(() {
                        isProfileEdited = true;
                      });
                    }).catchError((e) {});
                  },
                  leading: const Icon(
                    Icons.image,
                  ),
                  title: Text(
                    'Gallery',
                    style: style.text.regular,
                  ),
                ),
              ],
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceDim,
        centerTitle: true,
        title: Text(
          'EDIT PROFILE',
          style: style.text.boldLarge,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceDim,
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is AddDataToFeild) {
            if (state.name?.isNotEmpty == true) {
              nameController.text = name = state.name ?? '';
            }
            if (state.name?.isNotEmpty == true) {
              phoneController.text = mobileNO = state.phoneNo ?? '';
            }
          }
        },
        buildWhen: (previous, current) => current is! ProfileActionState,
        builder: (context, state) {
          if (state is ProfileInitial) {
            // if (state.user.userName?.isNotEmpty == true) {
            //   nameController.text = name = state.user.userName ?? '';
            // }
            // if (state.user.phoneNumber?.isNotEmpty == true) {
            //   phoneController.text = mobileNO = state.user.phoneNumber ?? '';
            // }
            var inputDecoration = InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.only(left: 10),
              fillColor: Theme.of(context).colorScheme.inverseSurface,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10),
              ),
            );
            var textStyle = style.text.semiBoldMedium;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(20),
                    Center(
                      child: Hero(
                        tag: 'profile',
                        child: GestureDetector(
                          onTap: () {
                            editImage();
                          },
                          child: Stack(
                            children: [
                              SizedBox(
                                height: 120,
                                width: 120,
                                child: state.editedprofile == null
                                    ? CircularProfileImage(
                                        isNetworkImage:
                                            state.user.profileURL != null,
                                        image: state.user.profileURL,
                                      )
                                    : Container(
                                        clipBehavior: Clip.hardEdge,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.file(
                                          File(state.editedprofile!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: AppColor.white),
                                      color: AppColor.blue,
                                      shape: BoxShape.circle),
                                  child: const SVGIcon(
                                    name: 'camera',
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Gap(30),
                    Text(
                      'Name',
                      style: textStyle,
                    ),
                    const Gap(5),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: TextFormField(
                        controller: nameController,
                        decoration: inputDecoration,
                        onChanged: (value) {
                          setState(() {
                            if (value != name) {
                              isEdited = true;
                            } else {
                              isEdited = false;
                            }
                          });
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z ]'))
                        ],
                      ),
                    ),
                    Text(
                      'Phone number',
                      style: textStyle,
                    ),
                    const Gap(5),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: TextFormField(
                        controller: phoneController,
                        decoration: inputDecoration,
                        onChanged: (value) {
                          setState(() {
                            if (value != mobileNO) {
                              isEdited = true;
                            } else {
                              isEdited = false;
                            }
                          });
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
      bottomSheet: Container(
        color: Theme.of(context).colorScheme.surfaceDim,
        padding: EdgeInsets.symmetric(
            horizontal: style.insets.lg, vertical: style.insets.xxl),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: AppColor.greyText,
                  disabledBackgroundColor:
                      AppColor.black.withValues(alpha: 0.1),
                  foregroundColor: AppColor.white),
              onPressed: (isEdited || isProfileEdited)
                  ? () {
                      profileCubit.resetProfileField();
                      setState(() {
                        isEdited = false;
                        isProfileEdited = false;
                      });
                    }
                  : null,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                child: Text(
                  'RESET',
                  style: style.text.regular,
                ),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: AppColor.blue,
                  disabledBackgroundColor: AppColor.blue.withValues(alpha: 0.3),
                  foregroundColor: AppColor.white),
              onPressed: (isEdited || isProfileEdited)
                  ? () {
                      profileCubit.updateProfileData(
                          nameController.text, phoneController.text);
                    }
                  : null,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                child: Text(
                  'UPDATE',
                  style: style.text.regular,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
