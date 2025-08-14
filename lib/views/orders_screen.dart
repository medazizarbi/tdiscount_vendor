import 'package:flutter/material.dart';
import '../utils/constants/colors.dart';
import '../utils/widgets/custom_app_bar.dart';
import '../utils/widgets/screen_container.dart';
import '../utils/widgets/order_card.dart';
import '../models/order.dart';
import '../models/product.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  static final List<Order> _staticOrders = [
    Order(
      number: '#001',
      status: 'refunded',
      dateCreated: DateTime.now().subtract(const Duration(hours: 2)),
      total: '\$125.50',
      customerNote: 'Please deliver after 3 PM',
      lineItems: [
        OrderItem(product: Product.getProductById(1)!, quantity: 2),
        OrderItem(product: Product.getProductById(3)!, quantity: 1),
      ],
      billing: BillingInfo(
        firstName: 'John',
        lastName: 'Doe',
        address1: '123 Main St',
        city: 'New York',
        email: 'john.doe@email.com',
        phone: '+1234567890',
      ),
      shipping: ShippingInfo(
        firstName: 'John',
        lastName: 'Doe',
        address1: '123 Main St',
        city: 'New York',
        email: 'john.doe@email.com',
        phone: '+1234567890',
      ),
    ),
    Order(
      number: '#002',
      status: 'failed',
      dateCreated: DateTime.now().subtract(const Duration(hours: 5)),
      total: '\$89.99',
      customerNote: 'Handle with care',
      lineItems: [
        OrderItem(product: Product.getProductById(1)!, quantity: 1),
      ],
      billing: BillingInfo(
        firstName: 'Jane',
        lastName: 'Smith',
        address1: '456 Oak Ave',
        city: 'Los Angeles',
        email: 'jane.smith@email.com',
        phone: '+0987654321',
      ),
      shipping: ShippingInfo(
        firstName: 'Jane',
        lastName: 'Smith',
        address1: '456 Oak Ave',
        city: 'Los Angeles',
        email: 'jane.smith@email.com',
        phone: '+0987654321',
      ),
    ),
    Order(
      number: '#003',
      status: 'on-hold',
      dateCreated: DateTime.now().subtract(const Duration(hours: 8)),
      total: '\$150.75',
      customerNote: 'Payment verification required',
      lineItems: [
        OrderItem(product: Product.getProductById(2)!, quantity: 1),
        OrderItem(product: Product.getProductById(3)!, quantity: 1),
      ],
      billing: BillingInfo(
        firstName: 'David',
        lastName: 'Brown',
        address1: '654 Maple Dr',
        city: 'Seattle',
        email: 'david.brown@email.com',
        phone: '+9988776655',
      ),
      shipping: ShippingInfo(
        firstName: 'David',
        lastName: 'Brown',
        address1: '654 Maple Dr',
        city: 'Seattle',
        email: 'david.brown@email.com',
        phone: '+9988776655',
      ),
    ),
    Order(
      number: '#004',
      status: 'completed',
      dateCreated: DateTime.now().subtract(const Duration(days: 1)),
      total: '\$199.00',
      customerNote: 'Thank you for your business',
      lineItems: [
        OrderItem(product: Product.getProductById(4)!, quantity: 1),
        OrderItem(product: Product.getProductById(5)!, quantity: 2),
      ],
      billing: BillingInfo(
        firstName: 'Mike',
        lastName: 'Johnson',
        address1: '789 Pine Rd',
        city: 'Chicago',
        email: 'mike.johnson@email.com',
        phone: '+1122334455',
      ),
      shipping: ShippingInfo(
        firstName: 'Mike',
        lastName: 'Johnson',
        address1: '789 Pine Rd',
        city: 'Chicago',
        email: 'mike.johnson@email.com',
        phone: '+1122334455',
      ),
    ),
    Order(
      number: '#005',
      status: 'cancelled',
      dateCreated: DateTime.now().subtract(const Duration(days: 2)),
      total: '\$75.25',
      customerNote: 'Customer requested cancellation',
      lineItems: [
        OrderItem(product: Product.getProductById(6)!, quantity: 1),
      ],
      billing: BillingInfo(
        firstName: 'Sarah',
        lastName: 'Wilson',
        address1: '321 Elm St',
        city: 'Miami',
        email: 'sarah.wilson@email.com',
        phone: '+5566778899',
      ),
      shipping: ShippingInfo(
        firstName: 'Sarah',
        lastName: 'Wilson',
        address1: '321 Elm St',
        city: 'Miami',
        email: 'sarah.wilson@email.com',
        phone: '+5566778899',
      ),
    ),
    Order(
      number: '#006',
      status: 'refunded',
      dateCreated: DateTime.now().subtract(const Duration(days: 3)),
      total: '\$320.00',
      customerNote: 'Product was defective, full refund processed',
      lineItems: [
        OrderItem(product: Product.getProductById(7)!, quantity: 1),
        OrderItem(product: Product.getProductById(8)!, quantity: 1),
      ],
      billing: BillingInfo(
        firstName: 'Lisa',
        lastName: 'Anderson',
        address1: '987 Cedar Lane',
        city: 'Boston',
        email: 'lisa.anderson@email.com',
        phone: '+1357924680',
      ),
      shipping: ShippingInfo(
        firstName: 'Lisa',
        lastName: 'Anderson',
        address1: '987 Cedar Lane',
        city: 'Boston',
        email: 'lisa.anderson@email.com',
        phone: '+1357924680',
      ),
    ),
    Order(
      number: '#007',
      status: 'failed',
      dateCreated: DateTime.now().subtract(const Duration(days: 4)),
      total: '\$45.99',
      customerNote: 'Payment failed due to insufficient funds',
      lineItems: [
        OrderItem(product: Product.getProductById(9)!, quantity: 1),
        OrderItem(product: Product.getProductById(10)!, quantity: 1),
      ],
      billing: BillingInfo(
        firstName: 'Robert',
        lastName: 'Taylor',
        address1: '159 Birch St',
        city: 'Phoenix',
        email: 'robert.taylor@email.com',
        phone: '+2468135790',
      ),
      shipping: ShippingInfo(
        firstName: 'Robert',
        lastName: 'Taylor',
        address1: '159 Birch St',
        city: 'Phoenix',
        email: 'robert.taylor@email.com',
        phone: '+2468135790',
      ),
    ),
    Order(
      number: '#008',
      status: 'pending',
      dateCreated: DateTime.now().subtract(const Duration(hours: 1)),
      total: '\$67.50',
      customerNote: 'First time customer',
      lineItems: [
        OrderItem(product: Product.getProductById(5)!, quantity: 1),
      ],
      billing: BillingInfo(
        firstName: 'Emma',
        lastName: 'Davis',
        address1: '741 Willow Ave',
        city: 'Denver',
        email: 'emma.davis@email.com',
        phone: '+3691472580',
      ),
      shipping: ShippingInfo(
        firstName: 'Emma',
        lastName: 'Davis',
        address1: '741 Willow Ave',
        city: 'Denver',
        email: 'emma.davis@email.com',
        phone: '+3691472580',
      ),
    ),
    Order(
      number: '#009',
      status: 'processing',
      dateCreated: DateTime.now().subtract(const Duration(hours: 6)),
      total: '\$234.99',
      customerNote: 'Express shipping requested',
      lineItems: [
        OrderItem(product: Product.getProductById(4)!, quantity: 1),
        OrderItem(product: Product.getProductById(5)!, quantity: 1),
      ],
      billing: BillingInfo(
        firstName: 'Chris',
        lastName: 'Martinez',
        address1: '852 Spruce Rd',
        city: 'Portland',
        email: 'chris.martinez@email.com',
        phone: '+1472583690',
      ),
      shipping: ShippingInfo(
        firstName: 'Chris',
        lastName: 'Martinez',
        address1: '852 Spruce Rd',
        city: 'Portland',
        email: 'chris.martinez@email.com',
        phone: '+1472583690',
      ),
    ),
    Order(
      number: '#010',
      status: 'completed',
      dateCreated: DateTime.now().subtract(const Duration(days: 5)),
      total: '\$412.75',
      customerNote: 'Excellent service, very satisfied',
      lineItems: [
        OrderItem(product: Product.getProductById(7)!, quantity: 1),
        OrderItem(product: Product.getProductById(8)!, quantity: 2),
        OrderItem(product: Product.getProductById(5)!, quantity: 1),
      ],
      billing: BillingInfo(
        firstName: 'Amanda',
        lastName: 'Garcia',
        address1: '963 Poplar Blvd',
        city: 'Austin',
        email: 'amanda.garcia@email.com',
        phone: '+5836914720',
      ),
      shipping: ShippingInfo(
        firstName: 'Amanda',
        lastName: 'Garcia',
        address1: '963 Poplar Blvd',
        city: 'Austin',
        email: 'amanda.garcia@email.com',
        phone: '+5836914720',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: TColors.black),
                onPressed: () {
                  // Handle filter
                },
              ),
            ],
            showThemeToggle: true,
            pinned: true,
            floating: false,
            snap: false,
          ),
          SliverToBoxAdapter(
            child: ScreenContainer(
              title: 'Orders',
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _staticOrders.length,
                    itemBuilder: (context, index) {
                      final order = _staticOrders[index];
                      return OrderCard(
                        orderNumber: order.number,
                        status: order.status,
                        dateTime: order.dateCreated,
                        totalPrice: order.total,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderDetailScreen(order: order),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 300), // Extra space for scrolling
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
