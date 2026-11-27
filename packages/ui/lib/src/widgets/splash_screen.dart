import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:flutter/material.dart';

/// Launch moment: a single choreographed waypoint reveal, then a quiet
/// progress ring. Reduced motion renders the settled state immediately.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.appName});

  final String appName;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduced) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _phase(double begin, double end) => CurvedAnimation(
    parent: _controller,
    curve: Interval(begin, end, curve: AppMotion.expressive),
  );

  @override
  Widget build(BuildContext context) {
    final mark = _phase(0, 0.55);
    final lanes = _phase(0.12, 0.7);
    final words = _phase(0.3, 0.85);

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: 0.86 + 0.14 * mark.value,
                    child: Opacity(
                      opacity: mark.value,
                      child: Container(
                        width: 106,
                        height: 106,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.signalPale,
                          border: Border.all(
                            color: AppColors.signal.withValues(alpha: 0.65),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.local_shipping_rounded,
                          size: 48,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final delay in [0.0, 0.12])
                        Padding(
                          padding: EdgeInsets.only(right: delay == 0 ? 6 : 0),
                          child: Transform.translate(
                            offset: Offset(0, (1 - lanes.value) * 10),
                            child: Opacity(
                              opacity: lanes.value,
                              child: Container(
                                width: 22,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: AppColors.signal,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Opacity(
                    opacity: words.value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - words.value) * 12),
                      child: Text(
                        widget.appName,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(color: AppColors.paper),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.signal,
                      backgroundColor: AppColors.signal.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
