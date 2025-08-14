import 'package:flutter/material.dart';
import '../utils/constants/colors.dart';
import '../utils/widgets/custom_app_bar.dart';
import '../utils/widgets/screen_container.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: TColors.black),
                onPressed: () {
                  // Handle notifications
                },
              ),
            ],
            showThemeToggle: true,
            pinned: true,
            floating: false,
            snap: false,
          ),
          const SliverToBoxAdapter(
            child: ScreenContainer(
              title: 'Dashboard',
              child: Column(
                children: [
                  // Dashboard content here
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.dashboard,
                              size: 60, color: TColors.primary),
                          SizedBox(height: 16),
                          Text(
                            'Welcome to Dashboard',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Here you can view your vendor statistics and manage your business.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Add more dashboard widgets here
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(Icons.monetization_on,
                                    color: TColors.primary),
                                SizedBox(height: 8),
                                Text('Total Sales'),
                                Text('1,234 TND',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(Icons.shopping_cart,
                                    color: TColors.primary),
                                SizedBox(height: 8),
                                Text('Orders'),
                                Text('45',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 300), // Extra space for scrolling
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
