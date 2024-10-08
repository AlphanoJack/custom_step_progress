# custom_step_progress

Flutter Step Progress is a customizable widget for displaying step-by-step progress in Flutter applications.
It provides an intuitive interface for multi-step processes or forms.

# Features

- Customizable step indicator
- Animated back and continue buttons
- Glow effect on the finish button
- User-definable colors and button height
- Responsive design

Installation

Add this to your package's "pubspec.yaml" file:

<img alt="sample" width="700" src=https://github.com/user-attachments/assets/ee6e69ec-b63d-4f38-a6e1-08a2a1948dfb>

Then run:

<img alt="sample" width="700" src=https://github.com/user-attachments/assets/c9f0fd5f-a9dc-4953-9066-39a91232927e>

# Usage

Import the package in your Dart code:

<img alt="sample" width="700" src=https://github.com/user-attachments/assets/c17a9086-08e2-440c-aeab-d9782500f173>

Then, you can use the "StepProgress" widget in your Flutter app:

<img alt="sample" width="700" src=https://github.com/user-attachments/assets/46439b90-876d-408a-9886-c5d6936167a9>

#Customization
You can customize the following properties:

- currentStep: The current step (0-indexed)
- totalSteps: Total number of steps
- onNext: Callback function when the "Continue" button is pressed
- onBack: Callback function when the "Back" button is pressed
- activeColor: Color of the active step indicators
- inactiveColor: Color of the inactive step indicators
- backButtonColor: Color of the "Back" button
- continueButtonColor: Color of the "Continue" button
- finishButtonColor: Color of the "Finish" button (last step)
- buttonHeight: Height of the buttons

![sample](https://github.com/user-attachments/assets/3ea286a1-0f86-4426-8604-28c171c6c32f)


