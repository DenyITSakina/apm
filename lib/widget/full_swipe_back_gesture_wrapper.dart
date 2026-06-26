import 'package:flutter/material.dart';

/// Wrapper ini disediakan agar mudah dipakai di project.
class FullSwipeBackGestureWrapper extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const FullSwipeBackGestureWrapper({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Implementation intentionally left empty because gesture support is handled
    // by using `BackSwipePageRoute` for pushed pages (see lib/func/navigation_helpers.dart).
    return enabled ? child : child;
  }
}
