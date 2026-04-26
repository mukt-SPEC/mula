import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AnimatedFabAction {
  final PhosphorIconData icon;
  final void Function(BuildContext context) onPressed;

  const AnimatedFabAction({required this.icon, required this.onPressed});
}

class AnimatedFabOverlay extends StatefulWidget {
  final BuildContext pageContext;
  final List<AnimatedFabAction> actions;
  final double actionSpacing;
  final double scrimOpacity;
  final EdgeInsets margin;
  final String heroTagPrefix;

  const AnimatedFabOverlay({
    super.key,
    required this.pageContext,
    required this.actions,
    this.actionSpacing = 74,
    this.scrimOpacity = 0.35,
    this.margin = const EdgeInsets.all(16),
    this.heroTagPrefix = 'overview-fab',
  });

  @override
  State<AnimatedFabOverlay> createState() => _AnimatedFabOverlayState();
}

class _AnimatedFabOverlayState extends State<AnimatedFabOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 320),
      )..addListener(_onTick);

  bool get _isFabOpen => _controller.value > 0.0;

  void _onTick() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFab() {
    if (_controller.status == AnimationStatus.completed ||
        _controller.status == AnimationStatus.forward) {
      _controller.reverse();
      return;
    }
    _controller.forward();
  }

  void _closeFab() {
    if (_controller.value > 0) {
      _controller.reverse();
    }
  }

  Widget _buildActionButton(int index) {
    final action = widget.actions[index];
    final slotsFromMain = widget.actions.length - index;
    final endOffset = widget.actionSpacing * slotsFromMain;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeOutBack.transform(_controller.value);

        return Positioned(
          right: endOffset * t,
          bottom: 12, 
          child: IgnorePointer(
            ignoring: _controller.value == 0,
            child: Opacity(
              opacity: _controller.value.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.75 + (0.25 * t),
                child: child,
              ),
            ),
          ),
        );
      },
      child: FloatingActionButton.small(
        heroTag: '${widget.heroTagPrefix}-action-$index',
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        onPressed: () {
          _closeFab();
          Future.delayed(const Duration(milliseconds: 150), () {
            if (context.mounted) {
              action.onPressed(widget.pageContext);
            }
          });
        },
        child: PhosphorIcon(action.icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.actions.isEmpty) {
      return const SizedBox.shrink();
    }

    final fabWidth = widget.actionSpacing * (widget.actions.length + 1);

    return Stack(
      children: [
        IgnorePointer(
          ignoring: !_isFabOpen,
          child: GestureDetector(
            onTap: _closeFab,
            child: ColoredBox(
              color: Colors.black.withOpacity(widget.scrimOpacity * _controller.value),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        Positioned.fill(
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: widget.margin,
                child: SizedBox(
                  width: fabWidth,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    clipBehavior: Clip.none,
                    children: [
                      for (var i = 0; i < widget.actions.length; i++)
                        _buildActionButton(i),
                      FloatingActionButton(
                        heroTag: '${widget.heroTagPrefix}-main',
                        elevation: 0,
                        onPressed: _toggleFab,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, animation) {
                            return RotationTransition(
                              turns: Tween<double>(
                                begin: 0.85,
                                end: 1.0,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOut,
                                ),
                              ),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: PhosphorIcon(
                            _isFabOpen
                                ? PhosphorIconsRegular.x
                                : PhosphorIconsRegular.plus,
                            key: ValueKey<bool>(_isFabOpen),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

