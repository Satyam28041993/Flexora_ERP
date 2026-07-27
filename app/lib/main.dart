import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/order_intake/presentation/screens/order_list_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? firebaseInitError;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (error) {
    firebaseInitError = error;
  }

  runApp(ProviderScope(child: FlexoraApp(firebaseInitError: firebaseInitError)));
}

class FlexoraApp extends StatelessWidget {
  const FlexoraApp({super.key, this.firebaseInitError});

  final Object? firebaseInitError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flexora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: firebaseInitError != null
          ? _FirebaseNotConfiguredScreen(error: firebaseInitError!)
          : const OrderListScreen(),
    );
  }
}

/// Shown instead of crashing when Firebase hasn't been configured for this
/// environment yet (see main() above).
class _FirebaseNotConfiguredScreen extends StatelessWidget {
  const _FirebaseNotConfiguredScreen({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: AppTheme.textSecondary),
              const SizedBox(height: 16),
              const Text(
                'Firebase is not configured yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Run `flutterfire configure` for the Flexora Firebase project, '
                'then restart the app.\n\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
