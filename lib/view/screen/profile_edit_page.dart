import 'package:chit_chat/controller/profile_cubit/profile_cubit.dart';
import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/custom_widget/svg_icon.dart';
import 'package:chit_chat/res/fonts.dart';
import 'package:chit_chat/view/widget/circular_profile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  @override
  void initState() {
    BlocProvider.of<ProfileCubit>(context).editProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceDim,
        centerTitle: true,
        title: const Text(
          'EDIT PROFILE',
          style: TextStyle(
            color: AppColor.black,
            fontFamily: Roboto.bold,
            fontSize: 20,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceDim,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileInitial) {
            var inputDecoration = InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.only(left: 10),
              fillColor: AppColor.white,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10),
              ),
            );
            const textStyle =
                TextStyle(fontSize: 16, fontFamily: Roboto.medium);
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
                        child: Stack(
                          children: [
                            SizedBox(
                              height: 120,
                              width: 120,
                              child: CircularProfileImage(
                                isNetworkImage: state.user.profileURL != null,
                                image: state.user.profileURL,
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
                    const Gap(30),
                    const Text(
                      'Name',
                      style: textStyle,
                    ),
                    const Gap(5),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: TextFormField(
                        decoration: inputDecoration,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z ]'))
                        ],
                      ),
                    ),
                    const Text(
                      'Email',
                      style: textStyle,
                    ),
                    const Gap(5),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: TextFormField(
                        decoration: inputDecoration,
                      ),
                    ),
                    const Text(
                      'Phone number',
                      style: textStyle,
                    ),
                    const Gap(5),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: TextFormField(
                        decoration: inputDecoration,
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
    );
  }
}
