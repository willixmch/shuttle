import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuttle/pages/home.dart';

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
  bool _hasLocationPermission = false;

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      setState(() {
        _hasLocationPermission = true;
      });
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
          hasLocationPermission: _hasLocationPermission,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // PNG illustration
            Image.asset(
              'lib/assets/location_illustration.png',
              width: double.infinity,
            ),
            // Content below illustration
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Description text
                  Text(
                    'Allow location access while using HK Shuttle ETA to find the closest stop',
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
                          child: const Text('Show Closest Stop'),
                        ),
                        TextButton(
                          onPressed: _skipLocationPermission,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48), // Fill available width
                          ),
                          child: Text(
                            'Not now',
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