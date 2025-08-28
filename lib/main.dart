import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import 'package:tdiscount_vendor/viewmodels/product_viewmodel.dart';
import 'package:tdiscount_vendor/viewmodels/store_viewmodel.dart';
import 'provider/theme_provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'utils/constants/colors.dart';
import 'utils/widgets/nav_bar.dart';
import 'views/dashboard_screen.dart';
import 'views/orders_screen.dart';
import 'views/store_screen.dart';
import 'views/login_screen.dart';

// Global key for navigation access
// ignore: library_private_types_in_public_api
final GlobalKey<_MyHomePageState> homePageKey = GlobalKey<_MyHomePageState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Check if user is logged in
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final isLoggedIn = token != null && token.isNotEmpty;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => StoreViewModel()),
        ChangeNotifierProvider(create: (context) => ProductViewModel()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'TDiscount Vendor',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.amber,
            scaffoldBackgroundColor: TColors.light,
            appBarTheme: const AppBarTheme(
              backgroundColor: TColors.primary,
              foregroundColor: TColors.textPrimary,
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: TColors.textPrimary),
              bodyMedium: TextStyle(color: TColors.textSecondary),
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.amber,
            scaffoldBackgroundColor: TColors.dark,
            appBarTheme: const AppBarTheme(
              backgroundColor: TColors.primary,
              foregroundColor: TColors.textWhite,
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: TColors.textWhite),
              bodyMedium: TextStyle(color: TColors.textSecondary),
            ),
            useMaterial3: true,
          ),
          // Navigate based on login status
          home: isLoggedIn ? const MyHomePage() : const LoginScreen(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();

  static void navigateTo(int index) {
    homePageKey.currentState?.onItemTapped(index);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 2; // Start with Dashboard

  final List<Widget> _pages = const [
    DashboardScreen(),
    OrdersScreen(),
    StoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize auth and store state when homepage loads
    _initializeState();
  }

  Future<void> _initializeState() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final storeViewModel = Provider.of<StoreViewModel>(context, listen: false);

    // Set authentication state
    await authViewModel.checkAuthStatus();

    // Initialize store state
    await storeViewModel.initializeStoreState();
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavBar(
        onItemTapped: onItemTapped,
        selectedIndex: _selectedIndex,
      ),
    );
  }
}
