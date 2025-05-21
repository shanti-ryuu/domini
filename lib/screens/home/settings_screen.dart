import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:domini/services/auth_service.dart';
import 'package:domini/services/theme_service.dart';
import 'package:domini/screens/auth/pin_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _signOut(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              final authService = Provider.of<AuthService>(context, listen: false);
              authService.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const PinScreen()),
                (route) => false,
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _changePinLength(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentLength = authService.pinLength;
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('PIN Length'),
        content: const Text('Choose your preferred PIN length'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: currentLength == 4,
            onPressed: () {
              Navigator.pop(context);
              authService.setPinLength(4);
            },
            child: const Text('4 Digits'),
          ),
          CupertinoDialogAction(
            isDefaultAction: currentLength == 6,
            onPressed: () {
              Navigator.pop(context);
              authService.setPinLength(6);
            },
            child: const Text('6 Digits'),
          ),
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _changePin(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.logout();
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => const PinScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final themeService = Provider.of<ThemeService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SectionHeader(title: 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeService.isDarkMode,
            onChanged: (value) {
              themeService.toggleDarkMode();
            },
            secondary: const Icon(CupertinoIcons.moon),
          ),
          SwitchListTile(
            title: const Text('Use System Theme'),
            value: themeService.useSystemTheme,
            onChanged: (value) {
              themeService.setUseSystemTheme(value);
            },
            secondary: const Icon(CupertinoIcons.device_phone_portrait),
          ),
          const Divider(),
          
          const SectionHeader(title: 'Security'),
          ListTile(
            title: const Text('Change PIN'),
            leading: const Icon(CupertinoIcons.lock),
            trailing: const Icon(CupertinoIcons.chevron_right),
            onTap: () => _changePin(context),
          ),
          ListTile(
            title: const Text('PIN Length'),
            subtitle: Text('${authService.pinLength} digits'),
            leading: const Icon(CupertinoIcons.number),
            trailing: const Icon(CupertinoIcons.chevron_right),
            onTap: () => _changePinLength(context),
          ),
          SwitchListTile(
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Use fingerprint or face ID'),
            value: authService.biometricEnabled,
            onChanged: (value) {
              authService.setBiometricEnabled(value);
            },
            secondary: const Icon(CupertinoIcons.person_crop_circle),
          ),
          const Divider(),
          
          const SectionHeader(title: 'About'),
          ListTile(
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
            leading: const Icon(CupertinoIcons.info),
          ),
          const Divider(),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () => _signOut(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
