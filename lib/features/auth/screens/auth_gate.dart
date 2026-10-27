import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../home/screens/home_shell.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import 'get_started_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthController _auth;
  late AuthStatus _lastStatus;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthController>();
    _lastStatus = _auth.status;
    _auth.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (_auth.status == _lastStatus || !mounted) return;
    _lastStatus = _auth.status;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = context.select((AuthController a) => a.status);
    return switch (status) {
      AuthStatus.unknown => const _BlankSplash(),
      AuthStatus.unauthenticated => const GetStartedScreen(),
      AuthStatus.authenticated => const HomeShell(),
    };
  }
}

class _BlankSplash extends StatelessWidget {
  const _BlankSplash();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.brandGradient),
      child: SizedBox.expand(),
    ),
  );
}
