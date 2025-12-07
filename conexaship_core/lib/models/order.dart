class Order {
  final int? id;
  final String orderNumber;
  final int customerId;
  final String status; // pending, processing, shipped, delivered, cancelled
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final String? shippingAddress;
  final String? shippingCity;
  final String? shippingState;
  final String? shippingZipCode;
  final String? shippingCountry;
  final String? notes;
  final List<OrderItem>? items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    this.id,
    required this.orderNumber,
    required this.customerId,
    required this.status,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    this.shippingAddress,
    this.shippingCity,
    this.shippingState,
    this.shippingZipCode,
    this.shippingCountry,
    this.notes,
    this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int?,
      orderNumber: json['order_number'] ?? json['orderNumber'] ?? '',
      customerId: json['customer_id'] ?? json['customerId'] ?? 0,
      status: json['status'] ?? 'pending',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      shipping: (json['shipping'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      shippingAddress: json['shipping_address'] ?? json['shippingAddress'],
      shippingCity: json['shipping_city'] ?? json['shippingCity'],
      shippingState: json['shipping_state'] ?? json['shippingState'],
      shippingZipCode: json['shipping_zip_code'] ?? json['shippingZipCode'],
      shippingCountry: json['shipping_country'] ?? json['shippingCountry'],
      notes: json['notes'],
      items: json['items'] != null
          ? (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList()
          : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'status': status,
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'total': total,
      'shipping_address': shippingAddress,
      'shipping_city': shippingCity,
      'shipping_state': shippingState,
      'shipping_zip_code': shippingZipCode,
      'shipping_country': shippingCountry,
      'notes': notes,
      'items': items?.map((i) => i.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class OrderItem {
  final int? id;
  final int? orderId;
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final double total;

  OrderItem({
    this.id,
    this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int?,
      orderId: json['order_id'] ?? json['orderId'],
      productId: json['product_id'] ?? json['productId'] ?? 0,
      productName: json['product_name'] ?? json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }
}
