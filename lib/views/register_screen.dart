import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants/colors.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../main.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isPrivacyPolicyAccepted = false;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
      appBar: AppBar(
        title: Text(
          'Inscription Vendeur',
          style: TextStyle(
            color: themedColor(context, TColors.textPrimary, TColors.textWhite),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 60,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themedColor(context, TColors.textPrimary, TColors.textWhite),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
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
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Créez un compte vendeur',
                      style: TextStyle(
                        fontSize: 16,
                        color: themedColor(
                            context, TColors.textSecondary, TColors.darkGrey),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    // Name Field
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nom complet*',
                      icon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom complet';
                        }
                        if (value.length < 2) {
                          return 'Le nom doit contenir au moins 2 caractères';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Email Field
                    _buildTextField(
                      controller: _emailController,
                      label: 'Adresse e-mail*',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
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

                    const SizedBox(height: 20),

                    // Password Field
                    _buildPasswordField(
                      controller: _passwordController,
                      label: 'Mot de Passe*',
                      obscureText: _obscurePassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre mot de passe';
                        }
                        if (value.length < 6) {
                          return 'Le mot de passe doit contenir\nau moins 6 caractères';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Confirm Password Field
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: 'Confirmer Mot de Passe*',
                      obscureText: _obscureConfirmPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez confirmer votre mot de passe';
                        }
                        if (value != _passwordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Privacy Policy Checkbox
                    Container(
                      width: 320,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isPrivacyPolicyAccepted,
                            activeColor: TColors.primary,
                            onChanged: (value) {
                              setState(() {
                                _isPrivacyPolicyAccepted = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isPrivacyPolicyAccepted =
                                      !_isPrivacyPolicyAccepted;
                                });
                              },
                              child: Text(
                                "J'accepte les conditions d'utilisation et la politique de confidentialité",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: themedColor(context,
                                      TColors.textSecondary, TColors.darkGrey),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Register Button with Consumer
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
                            key: const Key('vendor_register_submit'),
                            onPressed: authViewModel.isLoading
                                ? null
                                : () => _handleRegister(context, authViewModel),
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
                                    'Créer Compte',
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

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Avez-vous déjà un compte ? ',
                          style: TextStyle(
                            color: themedColor(context, TColors.textSecondary,
                                TColors.darkGrey),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Se Connecter',
                            style: TextStyle(
                              color: TColors.primary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build text field widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: themedColor(context, TColors.cardlight, TColors.carddark),
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
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: themedColor(context, TColors.textPrimary, TColors.textWhite),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color:
                themedColor(context, TColors.textSecondary, TColors.darkGrey),
          ),
          prefixIcon: Icon(
            icon,
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
        validator: validator,
      ),
    );
  }

  // Build password field widget
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: themedColor(context, TColors.cardlight, TColors.carddark),
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
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
          color: themedColor(context, TColors.textPrimary, TColors.textWhite),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color:
                themedColor(context, TColors.textSecondary, TColors.darkGrey),
          ),
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: TColors.primary,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color:
                  themedColor(context, TColors.textSecondary, TColors.darkGrey),
            ),
            onPressed: onToggleVisibility,
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
        validator: validator,
      ),
    );
  }

  // Handle register logic
  Future<void> _handleRegister(
      BuildContext context, AuthViewModel authViewModel) async {
    // Validate form
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Check privacy policy acceptance
    if (!_isPrivacyPolicyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Vous devez accepter les conditions d\'utilisation et la politique de confidentialité'),
          backgroundColor: TColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Get form data
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Call register method from ViewModel
    final success = await authViewModel.register(name, email, password);

    // Handle result
    if (success && mounted) {
      // Registration successful - navigate to main app
      Navigator.of(this.context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MyHomePage(),
        ),
      );
    }
  }
}
