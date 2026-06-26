import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/login_form_card.dart';
import '../widgets/login_header.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _MeshBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      LoginHeader(),
                      SizedBox(height: AppSpacing.xl),
                      LoginFormCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeshBackground extends StatelessWidget {
  const _MeshBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.7, -0.5),
          radius: 1.2,
          colors: [Color(0x550FA958), Colors.transparent],
          stops: [0, 0.7],
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.75, 0.7),
            radius: 1,
            colors: [Color(0x45FF3D7A), Colors.transparent],
            stops: [0, 0.7],
          ),
        ),
        child: const ColoredBox(color: AppColors.background),
      ),
    );
  }
}
