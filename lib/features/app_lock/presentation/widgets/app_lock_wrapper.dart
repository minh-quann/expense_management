import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/features/app_lock/presentation/bloc/app_lock_bloc.dart';
import 'package:expense_management/features/app_lock/presentation/bloc/app_lock_event.dart';
import 'package:expense_management/features/app_lock/presentation/bloc/app_lock_state.dart';
import 'package:expense_management/features/app_lock/presentation/screens/lock_screen.dart';

/// Wrapper widget that shows lock screen overlay when app is locked.
/// Wraps the entire app and listens to AppLockBloc state.
class AppLockWrapper extends StatefulWidget {
  final Widget child;

  const AppLockWrapper({super.key, required this.child});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper> with WidgetsBindingObserver {
  bool _wasInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Check lock status on app start
    context.read<AppLockBloc>().add(CheckAppLockStatus());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _wasInBackground = true;
    }

    if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground = false;
      // Re-lock app when returning from background
      context.read<AppLockBloc>().add(LockApp());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLockBloc, AppLockState>(
      builder: (context, state) {
        return Stack(
          children: [
            // Main app content
            widget.child,

            // Lock screen overlay
            if (state is AppLocked)
              Positioned.fill(
                child: LockScreen(
                  onUnlocked: () {
                    // AppLockBloc will emit AppUnlocked state,
                    // which removes this overlay automatically
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
