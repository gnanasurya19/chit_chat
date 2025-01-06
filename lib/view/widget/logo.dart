import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Logo extends StatelessWidget {
  const Logo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.onTertiary,
          boxShadow: [
            BoxShadow(
                blurRadius: 2,
                offset: const Offset(0, 0),
                color: Theme.of(context)
                    .colorScheme
                    .tertiaryContainer
                    .withValues(alpha: 0.2)),
          ]),
      height: MediaQuery.of(context).size.height * 0.1,
      padding: const EdgeInsets.all(10.0),
      child: Lottie.asset(
        'assets/lottie/message_lottie.json',
        fit: BoxFit.contain,
        repeat: false,
      ),
    );
  }
}
