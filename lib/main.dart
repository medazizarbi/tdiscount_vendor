import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/theme_provider.dart';
import 'utils/constants/colors.dart';
import 'utils/widgets/nav_bar.dart';
import 'views/dashboard_screen.dart';
import 'views/orders_screen.dart';
import 'views/store_screen.dart';
import 'views/login_screen.dart'; // Add this import

// Global key for navigation access
// ignore: library_private_types_in_public_api
final GlobalKey<_MyHomePageState> homePageKey = GlobalKey<_MyHomePageState>();

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          home: const LoginScreen(), // Changed from MyHomePage to LoginScreen
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

  // Expose a method to navigate to specific screen
  static void navigateTo(int index) {
    homePageKey.currentState?.onItemTapped(index);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1; // Start with Dashboard

  final List<Widget> _pages = const [
    DashboardScreen(),
    OrdersScreen(),
    StoreScreen(),
  ];

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
