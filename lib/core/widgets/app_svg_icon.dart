import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract final class AppIcons {
  static const String navHome = 'assets/icons/nav_home.svg';
  static const String navPost = 'assets/icons/nav_post.svg';
  static const String navProfile = 'assets/icons/nav_profile.svg';
  static const String profile = 'assets/icons/menu_profile.svg';
  static const String posts = 'assets/icons/menu_posts.svg';
  static const String logout = 'assets/icons/menu_logout.svg';

  static const String reportShare = 'assets/icons/report_share.svg';
}

class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon(this.asset, {super.key, this.size, this.color});

  final String asset;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final dimension = size ?? theme.size ?? 24;
    return SvgPicture.asset(
      asset,
      width: dimension,
      height: dimension,
      colorFilter: ColorFilter.mode(
        color ?? theme.color ?? Colors.black,
        BlendMode.srcIn,
      ),
    );
  }
}
