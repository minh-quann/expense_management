import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/core/utils/app_settings_manager.dart';

/// Animated container for StatefulShellRoute branch switching.
/// Uses a fade-through transition (Material Design recommended pattern)
/// for smooth, non-jarring tab switching in bottom navigation.
///
/// This follows Material Design guidelines:
/// - Bottom nav tabs are peer-level destinations (no parent-child hierarchy)
/// - Fade-through reinforces that tabs are independent, not sequential
/// - Avoids lateral slide which implies swipeable/hierarchical content
class AnimatedBranchContainer extends StatefulWidget {
  final int currentIndex;
  final List<Widget> children;

  const AnimatedBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  @override
  State<AnimatedBranchContainer> createState() =>
      _AnimatedBranchContainerState();
}

class _AnimatedBranchContainerState extends State<AnimatedBranchContainer>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeOutAnimation;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;

  int _currentIndex = 0;
  int _previousIndex = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _previousIndex = widget.currentIndex;

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );

    // Fade-through pattern:
    // First half: old content fades out with slight scale down
    // Second half: new content fades in with slight scale up
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
      ),
    );

    // Subtle scale: content scales up slightly from 96% to 100%
    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
      ),
    );

    _fadeController.addStatusListener(_onAnimationStatus);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _isAnimating = false;
      });
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _currentIndex = widget.currentIndex;
      
      final bool disableAnimation = AppSettingsManager.isTabAnimationDisabled();
      if (disableAnimation) {
        _isAnimating = false;
        _fadeController.value = 1.0;
      } else {
        _isAnimating = true;
        _fadeController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _fadeController.removeStatusListener(_onAnimationStatus);
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the actual app background color to prevent gray flash
    // during fade transition (scaffoldBackgroundColor is #121212 but
    // the app screens use AppColors.background which is #000000)
    return ColoredBox(
      color: AppColors.background(context),
      child: Stack(
      children: List.generate(widget.children.length, (index) {
        final isCurrentTarget = index == _currentIndex;
        final isPreviousTarget = index == _previousIndex;
        final shouldShow = isCurrentTarget ||
            (isPreviousTarget && _isAnimating);

        return Offstage(
          offstage: !shouldShow,
          child: TickerMode(
            enabled: isCurrentTarget,
            child: _buildAnimatedChild(index, isCurrentTarget, isPreviousTarget),
          ),
        );
      }),
      ),
    );
  }

  Widget _buildAnimatedChild(int index, bool isCurrent, bool isPrevious) {
    // No animation needed - static display
    if (!_isAnimating) {
      return widget.children[index];
    }

    // Old tab fading out
    if (isPrevious && !isCurrent) {
      return AnimatedBuilder(
        animation: _fadeOutAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeOutAnimation.value,
            child: child,
          );
        },
        child: widget.children[index],
      );
    }

    // New tab fading in with subtle scale
    if (isCurrent) {
      return AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeInAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          );
        },
        child: widget.children[index],
      );
    }

    return widget.children[index];
  }
}
