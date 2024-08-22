import 'package:flutter/material.dart';

class SquareStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;

  const SquareStepIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.activeColor,
    required this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalSteps,
            (index) => Container(
          width: 20,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: index <= currentStep ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
