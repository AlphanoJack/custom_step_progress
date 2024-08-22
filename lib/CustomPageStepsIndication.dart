import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_custom_page_steps_indication/StepIndicator.dart';

class StepProgress extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final Function(int) onNext;
  final Function(int) onBack;
  final Color activeColor;
  final Color inactiveColor;
  final Color backButtonColor;
  final Color continueButtonColor;
  final Color finishButtonColor;
  final double buttonHeight;
  final bool enableFinishButtonGlow;

  const StepProgress({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onBack,
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.grey,
    this.backButtonColor = Colors.black,
    this.continueButtonColor = Colors.green,
    this.finishButtonColor = Colors.blue,
    this.buttonHeight = 50.0,
    this.enableFinishButtonGlow = true,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SquareStepIndicator(
          currentStep: widget.currentStep,
          totalSteps: widget.totalSteps,
          activeColor: widget.activeColor,
          inactiveColor: widget.inactiveColor,
        ),
        const SizedBox(height: 16),
        _buildButtons(),
      ],
    );
  }

  Widget _buildButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        const horizontalPadding = 16.0;
        const buttonSpacing = 8.0;

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final backButtonWidth = _animation.value * (screenWidth * 0.25);
            final continueButtonWidth = screenWidth - backButtonWidth -
                (2 * horizontalPadding) - buttonSpacing;
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
                        backgroundColor: widget.backButtonColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        widget.currentStep == 0 ? '' : 'Back',
                        softWrap: false,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: buttonSpacing),
                _buildContinueButton(isLastStep, continueButtonWidth),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildContinueButton(bool isLastStep, double width) {
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
                  // Glow effect (if enabled)
                  if (isLastStep && widget.enableFinishButtonGlow)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          gradient: LinearGradient(
                            colors: [
                              widget.finishButtonColor.withOpacity(0.6),
                              widget.finishButtonColor,
                              widget.finishButtonColor.withOpacity(0.6),
                            ],
                            stops: [0, _glowAnimation.value, 1],
                          ),
                        ),
                      ),
                    ),
                  // Base button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: width,
                    height: widget.buttonHeight,
                    child: ElevatedButton(
                      onPressed: isLastStep ? null : () =>
                          widget.onNext(widget.currentStep),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLastStep
                            ? widget.finishButtonColor
                            : widget.continueButtonColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: widget.enableFinishButtonGlow
                            ? widget.finishButtonColor.withOpacity(0.2) : widget.finishButtonColor,
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
                          color: Colors.white, // Explicitly set text color
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

