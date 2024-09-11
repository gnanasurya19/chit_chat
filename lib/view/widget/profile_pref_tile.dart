import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:chit_chat_1/res/colors.dart';
import 'package:chit_chat_1/res/common_instants.dart';
import 'package:chit_chat_1/res/custom_widget/svg_icon.dart';

class ProfilePrefTile extends StatelessWidget {
  const ProfilePrefTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.action,
  });

  final String leadingIcon;
  final String title;
  final String subtitle;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: leadingIcon == 'logout'
                  ? Theme.of(context).colorScheme.surfaceTint.withOpacity(0.5)
                  : Theme.of(context).colorScheme.surface.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: SVGIcon(
              name: leadingIcon,
              size: 17,
            ),
          ),
          const Gap(15),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: style.text.boldMedium.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiaryContainer),
                      ),
                      Text(
                        subtitle,
                        style: style.text.semiBoldSmall
                            .copyWith(color: AppColor.greyText),
                      )
                    ],
                  ),
                ),
                action,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
