import 'package:chit_chat/res/colors.dart';
import 'package:chit_chat/res/common_instants.dart';
import 'package:chit_chat/view/widget/circular_profile_image.dart';
import 'package:flutter/material.dart';

class SharePage extends StatefulWidget {
  const SharePage({super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: SizedBox(
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close_rounded, color: AppColor.white),
          ),
        ),
        iconTheme: IconThemeData(),
        titleSpacing: 0,
        title: Text(
          'Select recipients',
          style: style.text.semiBoldLarge.copyWith(color: AppColor.white),
        ),
      ),
      body: ListView(
        children: [
          UserSharingCard(),
          UserSharingCard(),
          UserSharingCard(),
        ],
      ),
    );
  }
}

class UserSharingCard extends StatelessWidget {
  const UserSharingCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 1.5),
        leading: CircularProfileImage(
            image:
                "https://media2.dev.to/dynamic/image/width=800%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/https%3A%2F%2Fwww.gravatar.com%2Favatar%2F2c7d99fe281ecd3bcd65ab915bac6dd5%3Fs%3D250",
            isNetworkImage: true),
        title: Text(
          "User Name",
          style: style.text.semiBoldMedium,
        ),
      ),
    );
  }
}
