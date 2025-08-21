import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants/colors.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../main.dart';
import 'register_screen.dart'; // Import the RegisterScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Helper function for themed colors
  Color themedColor(BuildContext context, Color lightColor, Color darkColor) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkColor
        : lightColor;
  }

  // Helper function for themed image asset
  String themedLogoAsset(
      BuildContext context, String lightAsset, String darkAsset) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkAsset
        : lightAsset;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themedColor(context, TColors.light, TColors.dark),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        themedLogoAsset(
                            context,
                            'assets/images/tdiscount_images/Logo-Tdiscount-market-noire-2.0.png', // Dark logo for light theme
                            'assets/images/tdiscount_images/Logo-Tdiscount-market-2.0.png' // Light logo for dark theme
                            ),
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 35),

                    Text(
                      'Connectez-vous à votre espace vendeur',
                      style: TextStyle(
                        fontSize: 16,
                        color: themedColor(
                            context, TColors.textSecondary, TColors.darkGrey),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 35),

                    // Email Field (changed from username)
                    Container(
                      width: 320,
                      decoration: BoxDecoration(
                        color: themedColor(
                            context, TColors.cardlight, TColors.carddark),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: themedColor(
                              context,
                              TColors.black.withOpacity(0.05),
                              TColors.black.withOpacity(0.2),
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        key: const Key('vendor_login_email'),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          color: themedColor(
                              context, TColors.textPrimary, TColors.textWhite),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Email*',
                          labelStyle: TextStyle(
                            color: themedColor(context, TColors.textSecondary,
                                TColors.darkGrey),
                          ),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: TColors.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Veuillez entrer un email valide';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Password Field
                    Container(
                      width: 320,
                      decoration: BoxDecoration(
                        color: themedColor(
                            context, TColors.cardlight, TColors.carddark),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: themedColor(
                              context,
                              TColors.black.withOpacity(0.05),
                              TColors.black.withOpacity(0.2),
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        key: const Key('vendor_login_password'),
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(
                          color: themedColor(
                              context, TColors.textPrimary, TColors.textWhite),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Mot de Passe*',
                          labelStyle: TextStyle(
                            color: themedColor(context, TColors.textSecondary,
                                TColors.darkGrey),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: TColors.primary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: themedColor(context, TColors.textSecondary,
                                  TColors.darkGrey),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Login Button with Consumer
                    Container(
                      width: 320,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: TColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Consumer<AuthViewModel>(
                        builder: (context, authViewModel, child) {
                          return ElevatedButton(
                            key: const Key('vendor_login_submit'),
                            onPressed: authViewModel.isLoading
                                ? null
                                : () => _handleLogin(context, authViewModel),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: authViewModel.isLoading
                                  ? TColors.buttonDisabled
                                  : TColors.primary,
                              foregroundColor: TColors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 0,
                            ),
                            child: authViewModel.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          TColors.black),
                                    ),
                                  )
                                : const Text(
                                    'Se Connecter',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Error Message Display
                    Consumer<AuthViewModel>(
                      builder: (context, authViewModel, child) {
                        if (authViewModel.errorMessage != null) {
                          return Container(
                            width: 320,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: TColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: TColors.error.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: TColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authViewModel.errorMessage!,
                                    style: const TextStyle(
                                      color: TColors.error,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: TColors.error,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    // Clear error message
                                    Provider.of<AuthViewModel>(context,
                                            listen: false)
                                        .clearError();
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // Forgot Password
                    GestureDetector(
                      onTap: () {
                        // Handle forgot password
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Forgot password functionality to be implemented'),
                            backgroundColor: TColors.info,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Mot de passe oublié?',
                        style: TextStyle(
                          color: TColors.primary,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: themedColor(context, TColors.borderPrimary,
                                TColors.darkerGrey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OU',
                            style: TextStyle(
                              color: themedColor(context, TColors.textSecondary,
                                  TColors.darkGrey),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: themedColor(context, TColors.borderPrimary,
                                TColors.darkerGrey),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // Sign-up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pas encore vendeur ? ',
                          style: TextStyle(
                            color: themedColor(context, TColors.textSecondary,
                                TColors.darkGrey),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Devenir Vendeur',
                            style: TextStyle(
                              color: TColors.primary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Handle login logic
  Future<void> _handleLogin(
      BuildContext context, AuthViewModel authViewModel) async {
    // Validate form
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Get email and password
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Call login method from ViewModel
    final success = await authViewModel.login(email, password);

    // Handle result
    if (success && mounted) {
      // Login successful - navigate to main app
      Navigator.of(this.context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MyHomePage(),
        ),
      );
    }
    // Error handling is done by the Consumer widget displaying authViewModel.errorMessage
  }
}
