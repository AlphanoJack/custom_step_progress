import 'package:custom_step_progress/StepIndicator.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

Color parseColor(dynamic color) {
  if (color is int) {
    return Color(color);
  } else if (color is String) {
    String hexColor = color.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  } else if (color is Color) {
    return color;
  }
  throw ArgumentError('Invalid color format');
}


class StepProgress extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final Function(int) onNext;
  final Function(int) onBack;
  final Function() onFinish; // New callback for Finish action
  final dynamic activeColor;
  final dynamic inactiveColor;
  final dynamic backButtonColor;
  final dynamic continueButtonColor;
  final dynamic finishButtonColor;
  final double buttonHeight;
  final bool enableFinishButtonGlow;
  final EdgeInsets padding;

  const StepProgress({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onBack,
    required this.onFinish, // New required parameter
    this.activeColor = "00FF00",
    this.inactiveColor = "808080",
    this.backButtonColor = "000000",
    this.continueButtonColor = "00FF00",
    this.finishButtonColor = "0000FF",
    this.buttonHeight = 50.0,
    this.enableFinishButtonGlow = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  }) : super(key: key);

  @override
  _StepProgressState createState() => _StepProgressState();
}

class _StepProgressState extends State<StepProgress> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    if (widget.enableFinishButtonGlow) {
      _glowController.repeat(reverse: true);
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.currentStep > 0) {
      _animationController.value = 1;
    }
  }

  @override
  void didUpdateWidget(StepProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimations(oldWidget);
  }

  void _updateAnimations(StepProgress oldWidget) {
    if (oldWidget.currentStep == 0 && widget.currentStep > 0) {
      _animationController.forward();
    } else if (widget.currentStep == 0) {
      _animationController.reverse();
    }

    if (oldWidget.currentStep != widget.totalSteps - 1 &&
        widget.currentStep == widget.totalSteps - 1) {
      _rotationController.forward(from: 0);
      _glowController.repeat(reverse: true);
    } else if (oldWidget.currentStep == widget.totalSteps - 1 &&
        widget.currentStep != widget.totalSteps - 1) {
      _rotationController.reverse(from: 1);
      _glowController.stop();
      _glowController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rotationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SquareStepIndicator(
            currentStep: widget.currentStep,
            totalSteps: widget.totalSteps,
            activeColor: parseColor(widget.activeColor),
            inactiveColor: parseColor(widget.inactiveColor),
          ),
          const SizedBox(height: 16),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        const buttonSpacing = 8.0;

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final backButtonWidth = _animation.value * (screenWidth * 0.25);
            final isLastStep = widget.currentStep == widget.totalSteps - 1;

            return Row(
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _animation.value,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: backButtonWidth,
                    height: widget.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _animation.value > 0 ? () =>
                          widget.onBack(widget.currentStep) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: parseColor(widget.backButtonColor),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        widget.currentStep == 0 ? '' : 'Back',
                        softWrap: false,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ),
                ),
                if (widget.currentStep > 0) const SizedBox(width: buttonSpacing),
                Expanded(child: _buildContinueButton(isLastStep)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildContinueButton(bool isLastStep) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationX(_rotationAnimation.value * 2 * math.pi),
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  if (isLastStep && widget.enableFinishButtonGlow)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          gradient: LinearGradient(
                            colors: [
                              parseColor(widget.finishButtonColor).withOpacity(0.6),
                              parseColor(widget.finishButtonColor),
                              parseColor(widget.finishButtonColor).withOpacity(0.6),
                            ],
                            stops: [0, _glowAnimation.value, 1],
                          ),
                        ),
                      ),
                    ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: widget.buttonHeight,
                    child: ElevatedButton(
                      onPressed: isLastStep ? widget.onFinish : () => widget.onNext(widget.currentStep),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLastStep
                            ? parseColor(widget.finishButtonColor)
                            : parseColor(widget.continueButtonColor),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: widget.enableFinishButtonGlow
                            ? parseColor(widget.finishButtonColor).withOpacity(0.2)
                            : parseColor(widget.finishButtonColor),
                        disabledForegroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: Text(
                        isLastStep ? 'Finish' : 'Continue',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
