import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuttle/pages/home.dart';
import 'package:shuttle/l10n/generated/app_localizations.dart';

class OnboardingLocationPermission extends StatefulWidget {
  final void Function(VoidCallback) toggleLanguage;
  final ValueNotifier<String> languageNotifier;

  const OnboardingLocationPermission({
    super.key,
    required this.toggleLanguage,
    required this.languageNotifier,
  });

  @override
  OnboardingLocationPermissionState createState() => OnboardingLocationPermissionState();
}

class OnboardingLocationPermissionState extends State<OnboardingLocationPermission> {
  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    await _completeOnboarding();
    _navigateToHome();
  }

  Future<void> _skipLocationPermission() async {
    await _completeOnboarding();
    _navigateToHome();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Home(
          toggleLanguage: widget.toggleLanguage,
          languageNotifier: widget.languageNotifier,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // PNG illustration
            Image.asset(
              'lib/assets/location_illustration.png',
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.4,
              fit: BoxFit.contain,
            ),
            // Content below illustration
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Description text
                  Text(
                    localizations.locationPermissionText,
                    style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16), // Spacing between text and buttons
                  // Buttons with fixed width
                  SizedBox(
                    width: 200, // Fixed width of 200px
                    child: Column(
                      children: [
                        FilledButton(
                          onPressed: _requestLocationPermission,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48), // Fill available width
                          ),
                          child: Text(localizations.showClosestStop),
                        ),
                        const SizedBox(height: 8), // Spacing between buttons
                        TextButton(
                          onPressed: _skipLocationPermission,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48), // Fill available width
                          ),
                          child: Text(
                            localizations.notNow,
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}