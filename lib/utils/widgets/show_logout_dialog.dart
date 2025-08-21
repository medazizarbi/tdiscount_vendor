import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../views/login_screen.dart';

Future<void> showLogoutDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Déconnexion'),
      content: const Text('Voulez-vous vraiment vous déconnecter ?'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Annuler',
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextButton(
          onPressed: () async {
            // Close the confirmation dialog first
            Navigator.of(context).pop();

            // Show loading dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const AlertDialog(
                content: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Déconnexion en cours...'),
                  ],
                ),
              ),
            );

            try {
              // Perform logout
              final success =
                  await Provider.of<AuthViewModel>(context, listen: false)
                      .logout();

              // Close loading dialog first
              if (context.mounted) {
                Navigator.of(context).pop(); // Close loading dialog
              }

              // Always navigate to login screen after logout attempt
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );

                // Show appropriate message
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Déconnexion réussie'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Déconnexion effectuée'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            } catch (e) {
              // Close loading dialog
              if (context.mounted) {
                Navigator.of(context).pop(); // Close loading dialog
              }

              // Still navigate to login screen even if there's an error
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Erreur lors de la déconnexion, mais vous avez été déconnecté'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: const Text(
            'Déconnexion',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}
