// Modelo: Vendor (Vendedor)
class Vendor {
  final int id;
  final String vendorCode;
  final String email;
  final String fullName;
  final String? phone;
  
  // Comisiones
  final String commissionLevel; // bronze, silver, gold, platinum
  final double commissionRate;
  
  // Estadísticas
  final int totalSales;
  final double totalRevenue;
  final double totalCommission;
  
  // Estado
  final bool isActive;
  final bool isVerified;
  
  // Metadata
  final String? profileImage;
  final String? bio;
  final Map<String, dynamic>? socialLinks;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime? lastSaleAt;

  Vendor({
    required this.id,
    required this.vendorCode,
    required this.email,
    required this.fullName,
    this.phone,
    required this.commissionLevel,
    required this.commissionRate,
    this.totalSales = 0,
    this.totalRevenue = 0.0,
    this.totalCommission = 0.0,
    this.isActive = true,
    this.isVerified = false,
    this.profileImage,
    this.bio,
    this.socialLinks,
    required this.createdAt,
    this.lastSaleAt,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] ?? 0,
      vendorCode: json['vendor_code'] ?? json['vendorCode'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      phone: json['phone'],
      commissionLevel: json['commission_level'] ?? json['commissionLevel'] ?? 'bronze',
      commissionRate: (json['commission_rate'] ?? json['commissionRate'] ?? 5.0).toDouble(),
      totalSales: json['total_sales'] ?? json['totalSales'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? json['totalRevenue'] ?? 0.0).toDouble(),
      totalCommission: (json['total_commission'] ?? json['totalCommission'] ?? 0.0).toDouble(),
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
      profileImage: json['profile_image'] ?? json['profileImage'],
      bio: json['bio'],
      socialLinks: json['social_links'] ?? json['socialLinks'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      lastSaleAt: json['last_sale_at'] != null 
          ? DateTime.parse(json['last_sale_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_code': vendorCode,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'commission_level': commissionLevel,
      'commission_rate': commissionRate,
      'total_sales': totalSales,
      'total_revenue': totalRevenue,
      'total_commission': totalCommission,
      'is_active': isActive,
      'is_verified': isVerified,
      'profile_image': profileImage,
      'bio': bio,
      'social_links': socialLinks,
      'created_at': createdAt.toIso8601String(),
      'last_sale_at': lastSaleAt?.toIso8601String(),
    };
  }

  // Helper: Obtener color según nivel
  String get levelColor {
    switch (commissionLevel.toLowerCase()) {
      case 'platinum':
        return '#E5E4E2'; // Platinum
      case 'gold':
        return '#FFD700'; // Gold
      case 'silver':
        return '#C0C0C0'; // Silver
      case 'bronze':
      default:
        return '#CD7F32'; // Bronze
    }
  }

  // Helper: Obtener emoji según nivel
  String get levelEmoji {
    switch (commissionLevel.toLowerCase()) {
      case 'platinum':
        return '💎';
      case 'gold':
        return '🥇';
      case 'silver':
        return '🥈';
      case 'bronze':
      default:
        return '🥉';
    }
  }

  // Helper: Próximo nivel
  String? get nextLevel {
    switch (commissionLevel.toLowerCase()) {
      case 'bronze':
        return 'Silver (20 ventas)';
      case 'silver':
        return 'Gold (50 ventas)';
      case 'gold':
        return 'Platinum (100 ventas)';
      case 'platinum':
      default:
        return null; // Ya está en el nivel máximo
    }
  }

  // Helper: Ventas faltantes para siguiente nivel
  int get salesToNextLevel {
    switch (commissionLevel.toLowerCase()) {
      case 'bronze':
        return 20 - totalSales;
      case 'silver':
        return 50 - totalSales;
      case 'gold':
        return 100 - totalSales;
      case 'platinum':
      default:
        return 0;
    }
  }
}

// Modelo: VendorSale (Venta de Vendedor)
class VendorSale {
  final int id;
  final int vendorId;
  final int orderId;
  final double saleAmount;
  final double commissionRate;
  final double commissionAmount;
  final String status; // pending, approved, paid, cancelled
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? paidAt;
  final String? notes;

  VendorSale({
    required this.id,
    required this.vendorId,
    required this.orderId,
    required this.saleAmount,
    required this.commissionRate,
    required this.commissionAmount,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    this.paidAt,
    this.notes,
  });

  factory VendorSale.fromJson(Map<String, dynamic> json) {
    return VendorSale(
      id: json['id'] ?? 0,
      vendorId: json['vendor_id'] ?? json['vendorId'] ?? 0,
      orderId: json['order_id'] ?? json['orderId'] ?? 0,
      saleAmount: (json['sale_amount'] ?? json['saleAmount'] ?? 0.0).toDouble(),
      commissionRate: (json['commission_rate'] ?? json['commissionRate'] ?? 0.0).toDouble(),
      commissionAmount: (json['commission_amount'] ?? json['commissionAmount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      approvedAt: json['approved_at'] != null 
          ? DateTime.parse(json['approved_at']) 
          : null,
      paidAt: json['paid_at'] != null 
          ? DateTime.parse(json['paid_at']) 
          : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'order_id': orderId,
      'sale_amount': saleAmount,
      'commission_rate': commissionRate,
      'commission_amount': commissionAmount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'notes': notes,
    };
  }
}

// Modelo: VendorStats (Estadísticas de Vendedor)
class VendorStats {
  final int totalSales;
  final double totalRevenue;
  final double totalCommission;
  final int salesThisMonth;
  final double commissionThisMonth;
  final DateTime? lastSaleDate;

  VendorStats({
    this.totalSales = 0,
    this.totalRevenue = 0.0,
    this.totalCommission = 0.0,
    this.salesThisMonth = 0,
    this.commissionThisMonth = 0.0,
    this.lastSaleDate,
  });

  factory VendorStats.fromJson(Map<String, dynamic> json) {
    return VendorStats(
      totalSales: json['total_sales'] ?? json['totalSales'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? json['totalRevenue'] ?? 0.0).toDouble(),
      totalCommission: (json['total_commission'] ?? json['totalCommission'] ?? 0.0).toDouble(),
      salesThisMonth: json['sales_this_month'] ?? json['salesThisMonth'] ?? 0,
      commissionThisMonth: (json['commission_this_month'] ?? json['commissionThisMonth'] ?? 0.0).toDouble(),
      lastSaleDate: json['last_sale_date'] != null 
          ? DateTime.parse(json['last_sale_date']) 
          : null,
    );
  }
}
