import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 44, this.showName = true});

  static const String assetPath = 'assets/icon/app_logo.png';

  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final cacheSize = (size * MediaQuery.devicePixelRatioOf(context)).round();
    final mark = Image.asset(
      assetPath,
      width: size,
      height: size,
      cacheWidth: cacheSize,
      filterQuality: FilterQuality.medium,
    );
    if (!showName) return mark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        Gaps.w8,
        Flexible(
          child: Text(
            AppConstants.appName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: size * 0.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.fontSize = 46});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: Colors.white,
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      height: 0.95,
      letterSpacing: -1,
    );
    return Semantics(
      label: AppConstants.appName,
      excludeSemantics: true,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.skewX(-0.18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dream', style: style),
            Padding(
              padding: EdgeInsets.only(left: fontSize * 0.35),
              child: Text('Catchers', style: style),
            ),
          ],
        ),
      ),
    );
  }
}
