import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../profile/domain/entities/user_entity.dart';
import '../cubit/sign_in_cubit.dart';
import '../cubit/sign_in_state.dart';
import '../widgets/dot_grid_painter.dart';

class SignInScreen extends StatelessWidget {
  final Function(UserEntity) onSignIn;
  const SignInScreen({super.key, required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SignInCubit>(),
      child: _SignInView(onSignIn: onSignIn),
    );
  }
}

class _SignInView extends StatefulWidget {
  final Function(UserEntity) onSignIn;
  const _SignInView({required this.onSignIn});

  @override
  State<_SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<_SignInView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocConsumer<SignInCubit, SignInState>(
      listener: (context, state) {
        if (state is SignInSuccess) {
          widget.onSignIn(state.user);
        }
        if (state is SignInError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger(isDark),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is SignInLoading;
        return Scaffold(
          backgroundColor: AppColors.bg(isDark),
          body: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: DotGridPainter(dotColor: AppColors.dot(isDark)),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 420,
                child: _HeroGlow(isDark: isDark),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                right: 20,
                child: _ThemeToggle(isDark: isDark),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: FadeTransition(
                    opacity: _opacity,
                    child: SlideTransition(
                      position: _slide,
                      child: _SignInCard(
                        isDark: isDark,
                        isLoading: isLoading,
                        onSignIn: () =>
                            context.read<SignInCubit>().signInWithGitHub(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroGlow extends StatelessWidget {
  final bool isDark;
  const _HeroGlow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.0,
          colors: [
            AppColors.dot(isDark).withValues(alpha: isDark ? 0.6 : 0.4),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7],
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  const _ThemeToggle({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<ThemeCubit>().toggle(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface(isDark),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border(isDark)),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          size: 16,
          color: AppColors.muted(isDark),
        ),
      ),
    );
  }
}

class _SignInCard extends StatelessWidget {
  final bool isDark;
  final bool isLoading;
  final VoidCallback onSignIn;
  const _SignInCard({
    required this.isDark,
    required this.isLoading,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(isDark)),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.85),
                  blurRadius: 60,
                  offset: const Offset(0, 24),
                ),
              ]
            : [
                BoxShadow(
                  color: const Color(0xFF1F2328).withValues(alpha: 0.04),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
                BoxShadow(
                  color: const Color(0xFF1F2328).withValues(alpha: 0.08),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Logo(),
          const SizedBox(height: 32),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 160),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.text(isDark),
              height: 1.3,
            ),
            child: const Text('GitMind'),
          ),
          const SizedBox(height: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 160),
            style: TextStyle(
              fontSize: 15,
              color: AppColors.secondary(isDark),
              height: 1.5,
            ),
            child: const Text('Understand any repository at a glance.'),
          ),
          const SizedBox(height: 32),
          _GitHubButton(isDark: isDark, isLoading: isLoading, onTap: onSignIn),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.shield_outlined, size: 14, color: AppColors.muted(isDark)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'We only read public metadata you authorize.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.muted(isDark),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset('assets/appicon.png', width: 36, height: 36, fit: BoxFit.cover),
        ),
        const SizedBox(width: 10),
        const Text(
          'GitMind',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _GitHubButton extends StatelessWidget {
  final bool isDark;
  final bool isLoading;
  final VoidCallback onTap;
  const _GitHubButton({
    required this.isDark,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.btn(isDark),
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.btn(isDark).withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GitHubIcon(),
                  SizedBox(width: 8),
                  Text(
                    'Continue with GitHub',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GitHubIcon extends StatelessWidget {
  const _GitHubIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _GitHubMarkPainter(),
    );
  }
}

class _GitHubMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final s = size.width / 16.0;

    path.moveTo(8 * s, 0);
    path.cubicTo(3.58 * s, 0, 0, 3.58 * s, 0, 8 * s);
    path.cubicTo(0, 11.54 * s, 2.29 * s, 14.47 * s, 5.47 * s, 15.54 * s);
    path.cubicTo(5.87 * s, 15.61 * s, 6.02 * s, 15.37 * s, 6.02 * s, 15.17 * s);
    path.cubicTo(6.02 * s, 14.99 * s, 6.01 * s, 14.51 * s, 6.01 * s, 13.86 * s);
    path.cubicTo(3.78 * s, 14.34 * s, 3.31 * s, 12.83 * s, 3.31 * s, 12.83 * s);
    path.cubicTo(2.95 * s, 11.9 * s, 2.44 * s, 11.66 * s, 2.44 * s, 11.66 * s);
    path.cubicTo(1.74 * s, 11.17 * s, 2.49 * s, 11.18 * s, 2.49 * s, 11.18 * s);
    path.cubicTo(3.26 * s, 11.23 * s, 3.67 * s, 11.97 * s, 3.67 * s, 11.97 * s);
    path.cubicTo(4.36 * s, 13.18 * s, 5.47 * s, 12.84 * s, 6.04 * s, 12.64 * s);
    path.cubicTo(6.11 * s, 12.13 * s, 6.31 * s, 11.79 * s, 6.54 * s, 11.6 * s);
    path.cubicTo(4.72 * s, 11.4 * s, 2.8 * s, 10.71 * s, 2.8 * s, 7.63 * s);
    path.cubicTo(2.8 * s, 6.75 * s, 3.1 * s, 6.02 * s, 3.68 * s, 5.45 * s);
    path.cubicTo(3.6 * s, 5.25 * s, 3.34 * s, 4.42 * s, 3.76 * s, 3.3 * s);
    path.cubicTo(3.76 * s, 3.3 * s, 4.41 * s, 3.09 * s, 6.01 * s, 4.14 * s);
    path.cubicTo(6.68 * s, 3.96 * s, 7.34 * s, 3.87 * s, 8 * s, 3.87 * s);
    path.cubicTo(8.66 * s, 3.87 * s, 9.32 * s, 3.96 * s, 9.99 * s, 4.14 * s);
    path.cubicTo(11.59 * s, 3.09 * s, 12.24 * s, 3.3 * s, 12.24 * s, 3.3 * s);
    path.cubicTo(12.66 * s, 4.42 * s, 12.4 * s, 5.25 * s, 12.32 * s, 5.45 * s);
    path.cubicTo(12.9 * s, 6.02 * s, 13.2 * s, 6.75 * s, 13.2 * s, 7.63 * s);
    path.cubicTo(13.2 * s, 10.72 * s, 11.28 * s, 11.4 * s, 9.45 * s, 11.59 * s);
    path.cubicTo(9.74 * s, 11.83 * s, 10 * s, 12.3 * s, 10 * s, 13.02 * s);
    path.cubicTo(10 * s, 14.08 * s, 9.99 * s, 14.93 * s, 9.99 * s, 15.17 * s);
    path.cubicTo(9.99 * s, 15.37 * s, 10.14 * s, 15.62 * s, 10.55 * s, 15.54 * s);
    path.cubicTo(13.72 * s, 14.47 * s, 16 * s, 11.54 * s, 16 * s, 8 * s);
    path.cubicTo(16 * s, 3.58 * s, 12.42 * s, 0, 8 * s, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
