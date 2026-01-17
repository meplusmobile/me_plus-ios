import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:me_plus/data/services/token_storage_service.dart';
import 'package:me_plus/core/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashCheckScreen extends StatefulWidget {
  const SplashCheckScreen({super.key});

  @override
  State<SplashCheckScreen> createState() => _SplashCheckScreenState();
}

class _SplashCheckScreenState extends State<SplashCheckScreen>
    with SingleTickerProviderStateMixin {
  final TokenStorageService _tokenStorage = TokenStorageService();
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -200.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.repeat(reverse: true);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndRedirect();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndRedirect() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    try {
      final isLoggedIn = await _tokenStorage.isLoggedIn();

      if (isLoggedIn) {
        final role = await _tokenStorage.getUserRole();

        if (!mounted) return;

        switch (role?.toLowerCase()) {
          case 'student':
            context.go('/student/home');
            break;
          case 'marketowner':
          case 'market_owner':
            context.go('/market-owner/home');
            break;
          case 'parent':
            context.go('/parent/home');
            break;
          default:
            context.go('/login');
        }
      } else {
        if (!mounted) return;
        context.go('/login');
      }
    } catch (e) {
      debugPrint('Error during auth check: $e');
      if (!mounted) return;
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/MEPLUS splash.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Transform.scale(
                  scale: _controller.value > 0.6 ? _pulseAnimation.value : 1.0,
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: 150,
                    height: 150,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
