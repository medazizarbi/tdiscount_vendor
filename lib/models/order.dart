import 'product.dart';

class Order {
  final String number;
  final String status;
  final DateTime dateCreated;
  final String total;
  final String customerNote;
  final List<OrderItem> lineItems; // Changed from LineItem to OrderItem
  final BillingInfo billing;
  final ShippingInfo shipping;

  Order({
    required this.number,
    required this.status,
    required this.dateCreated,
    required this.total,
    required this.customerNote,
    required this.lineItems,
    required this.billing,
    required this.shipping,
  });
}

class OrderItem {
  final Product product;
  final int quantity;

  OrderItem({
    required this.product,
    required this.quantity,
  });
}

class BillingInfo {
  final String firstName;
  final String lastName;
  final String address1;
  final String city;
  final String email;
  final String phone;

  BillingInfo({
    required this.firstName,
    required this.lastName,
    required this.address1,
    required this.city,
    required this.email,
    required this.phone,
  });
}

class ShippingInfo {
  final String firstName;
  final String lastName;
  final String address1;
  final String city;
  final String email;
  final String phone;

  ShippingInfo({
    required this.firstName,
    required this.lastName,
    required this.address1,
    required this.city,
    required this.email,
    required this.phone,
  });
}
