import 'dart:convert';

String str(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString();
}

int intValue(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(str(value)) ?? fallback;
}

double doubleValue(dynamic value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  return double.tryParse(str(value)) ?? fallback;
}

bool boolValue(dynamic value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = str(value).toLowerCase();
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return fallback;
}

List<String> stringList(dynamic value) {
  if (value is List) return value.map((e) => str(e)).where((e) => e.trim().isNotEmpty).toList();
  if (value is String && value.trim().isNotEmpty) {
    try {
      final parsed = jsonDecode(value);
      if (parsed is List) return stringList(parsed);
    } catch (_) {}
    return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }
  return const [];
}

Map<String, dynamic> mapValue(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, val) => MapEntry(key.toString(), val));
  return const {};
}

String money(dynamic value) => '৳${doubleValue(value).toStringAsFixed(doubleValue(value) % 1 == 0 ? 0 : 2)}';

class StatItem {
  const StatItem({required this.value, required this.label});
  final String value;
  final String label;

  factory StatItem.fromJson(dynamic json) {
    final map = mapValue(json);
    return StatItem(value: str(map['value']), label: str(map['label']));
  }
}

class AppSettings {
  const AppSettings({
    required this.siteName,
    required this.tagline,
    required this.description,
    required this.heroHighlight,
    required this.heroTitleLine,
    required this.whatsapp,
    required this.phones,
    required this.location,
    required this.email,
    required this.facebookUrl,
    required this.serviceTags,
    required this.serviceIcons,
    required this.serviceDescriptions,
    required this.stats,
    required this.storePageTitle,
    required this.storePageCopy,
    required this.doctorsPageTitle,
    required this.doctorsPageCopy,
    required this.bloodPageTitle,
    required this.bloodPageCopy,
    required this.ambulancePageTitle,
    required this.ambulancePageCopy,
    required this.ambulanceDescription,
    required this.ambulancePhone,
    required this.ambulanceWhatsapp,
    required this.howPageTitle,
    required this.howPageCopy,
    required this.contactPageTitle,
    required this.contactPageCopy,
  });

  final String siteName;
  final String tagline;
  final String description;
  final String heroHighlight;
  final String heroTitleLine;
  final String whatsapp;
  final List<String> phones;
  final String location;
  final String email;
  final String facebookUrl;
  final List<String> serviceTags;
  final Map<String, dynamic> serviceIcons;
  final Map<String, dynamic> serviceDescriptions;
  final List<StatItem> stats;
  final String storePageTitle;
  final String storePageCopy;
  final String doctorsPageTitle;
  final String doctorsPageCopy;
  final String bloodPageTitle;
  final String bloodPageCopy;
  final String ambulancePageTitle;
  final String ambulancePageCopy;
  final String ambulanceDescription;
  final String ambulancePhone;
  final String ambulanceWhatsapp;
  final String howPageTitle;
  final String howPageCopy;
  final String contactPageTitle;
  final String contactPageCopy;

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      siteName: str(json['siteName'], 'Medicare At Home'),
      tagline: str(json['tagline'], 'Professional Home Visit Medical Service'),
      description: str(json['description'], 'Professional home visit medical services.'),
      heroHighlight: str(json['heroHighlight'], 'Medical care'),
      heroTitleLine: str(json['heroTitleLine'], 'at your home.'),
      whatsapp: str(json['whatsapp'], '8801647139287'),
      phones: stringList(json['phones']).isEmpty ? ['01647139287'] : stringList(json['phones']),
      location: str(json['location'], 'Bangladesh'),
      email: str(json['email']),
      facebookUrl: str(json['facebookUrl']),
      serviceTags: stringList(json['serviceTags']).isEmpty
          ? ['Injection', 'Cannula', 'Dressing', 'Plaster', 'Home Medical Care']
          : stringList(json['serviceTags']),
      serviceIcons: mapValue(json['serviceIcons']),
      serviceDescriptions: mapValue(json['serviceDescriptions']),
      stats: (json['stats'] is List ? json['stats'] as List : const [])
          .map(StatItem.fromJson)
          .where((s) => s.value.isNotEmpty && s.label.isNotEmpty)
          .toList(),
      storePageTitle: str(json['storePageTitle'], 'Buy medicine online'),
      storePageCopy: str(json['storePageCopy'], 'Browse available medicines and order easily.'),
      doctorsPageTitle: str(json['doctorsPageTitle'], 'Choose the right professional'),
      doctorsPageCopy: str(json['doctorsPageCopy'], 'Tap a card to open the full doctor profile.'),
      bloodPageTitle: str(json['bloodPageTitle'], 'Available blood people'),
      bloodPageCopy: str(json['bloodPageCopy'], 'Tap a card to view details.'),
      ambulancePageTitle: str(json['ambulancePageTitle'], 'Need an ambulance?'),
      ambulancePageCopy: str(json['ambulancePageCopy'], 'Send an ambulance request quickly.'),
      ambulanceDescription: str(json['ambulanceDescription'], 'Fast ambulance contact support.'),
      ambulancePhone: str(json['ambulancePhone'], '+8801609672748'),
      ambulanceWhatsapp: str(json['ambulanceWhatsapp'], '+8801609672748'),
      howPageTitle: str(json['howPageTitle'], 'About Medicare At Home'),
      howPageCopy: str(json['howPageCopy'], 'Meet the Medicare At Home team and read published updates.'),
      contactPageTitle: str(json['contactPageTitle'], 'Need service today?'),
      contactPageCopy: str(json['contactPageCopy'], 'Use WhatsApp for the fastest booking.'),
    );
  }
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.productType,
    required this.photoUrl,
    required this.price,
    required this.deliveryCharge,
    required this.feniDeliveryCharge,
    required this.outsideFeniDeliveryCharge,
    required this.stock,
    required this.description,
    required this.additionalPhotos,
  });

  final String id;
  final String name;
  final String productType;
  final String photoUrl;
  final double price;
  final double deliveryCharge;
  final double feniDeliveryCharge;
  final double outsideFeniDeliveryCharge;
  final int stock;
  final String description;
  final List<String> additionalPhotos;

  List<String> get gallery => [photoUrl, ...additionalPhotos].where((e) => e.trim().isNotEmpty).toList();

  factory Product.fromJson(dynamic json) {
    final map = mapValue(json);
    return Product(
      id: str(map['id']),
      name: str(map['name'], 'Product'),
      productType: str(map['productType'], 'medicine'),
      photoUrl: str(map['photoUrl']),
      price: doubleValue(map['price']),
      deliveryCharge: doubleValue(map['deliveryCharge']),
      feniDeliveryCharge: doubleValue(map['feniDeliveryCharge'], doubleValue(map['deliveryCharge'])),
      outsideFeniDeliveryCharge: doubleValue(map['outsideFeniDeliveryCharge'], doubleValue(map['deliveryCharge'])),
      stock: intValue(map['stock']),
      description: str(map['description']),
      additionalPhotos: stringList(map['additionalPhotos']),
    );
  }
}

class UserProfile {
  const UserProfile({required this.id, required this.fullName, required this.photoUrl, required this.age, required this.email, required this.phone});
  final String id;
  final String fullName;
  final String photoUrl;
  final int age;
  final String email;
  final String phone;

  factory UserProfile.fromJson(dynamic json) {
    final map = mapValue(json);
    return UserProfile(
      id: str(map['id']),
      fullName: str(map['fullName'], 'User'),
      photoUrl: str(map['photoUrl']),
      age: intValue(map['age']),
      email: str(map['email']),
      phone: str(map['phone']),
    );
  }
}

class CartItem {
  const CartItem({required this.id, required this.productId, required this.quantity, required this.product});
  final String id;
  final String productId;
  final int quantity;
  final Product? product;

  factory CartItem.fromJson(dynamic json) {
    final map = mapValue(json);
    return CartItem(
      id: str(map['id']),
      productId: str(map['productId']),
      quantity: intValue(map['quantity'], 1),
      product: map['product'] == null ? null : Product.fromJson(map['product']),
    );
  }
}

class OrderItem {
  const OrderItem({
    required this.id,
    required this.orderType,
    required this.productName,
    required this.quantity,
    required this.productPrice,
    required this.deliveryCharge,
    required this.status,
    required this.paymentMethod,
    required this.deliveryPaymentMethod,
    required this.transactionId,
    required this.senderNumber,
    required this.createdAt,
  });

  final String id;
  final String orderType;
  final String productName;
  final int quantity;
  final double productPrice;
  final double deliveryCharge;
  final String status;
  final String paymentMethod;
  final String deliveryPaymentMethod;
  final String transactionId;
  final String senderNumber;
  final String createdAt;

  double get total => productPrice * quantity + deliveryCharge;

  factory OrderItem.fromJson(dynamic json) {
    final map = mapValue(json);
    return OrderItem(
      id: str(map['id']),
      orderType: str(map['orderType'], 'product'),
      productName: str(map['productName'], 'Order'),
      quantity: intValue(map['quantity'], 1),
      productPrice: doubleValue(map['productPrice']),
      deliveryCharge: doubleValue(map['deliveryCharge']),
      status: str(map['status'], 'pending'),
      paymentMethod: str(map['paymentMethod'], 'cod'),
      deliveryPaymentMethod: str(map['deliveryPaymentMethod']),
      transactionId: str(map['transactionId']),
      senderNumber: str(map['senderNumber']),
      createdAt: str(map['createdAt']),
    );
  }
}

class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.designation,
    required this.specialty,
    required this.degrees,
    required this.experience,
    required this.hospital,
    required this.serviceArea,
    required this.available,
    required this.phone,
    required this.whatsapp,
    required this.fee,
    required this.services,
    required this.languages,
    required this.photoUrl,
    required this.bio,
    required this.chambers,
  });

  final String id;
  final String name;
  final String designation;
  final String specialty;
  final String degrees;
  final String experience;
  final String hospital;
  final String serviceArea;
  final String available;
  final String phone;
  final String whatsapp;
  final String fee;
  final List<String> services;
  final List<String> languages;
  final String photoUrl;
  final String bio;
  final List<Map<String, dynamic>> chambers;

  factory Doctor.fromJson(dynamic json) {
    final map = mapValue(json);
    final chamberItems = map['chambers'] is List
        ? (map['chambers'] as List).map(mapValue).toList()
        : <Map<String, dynamic>>[];
    return Doctor(
      id: str(map['id']),
      name: str(map['name'], 'Doctor'),
      designation: str(map['designation']),
      specialty: str(map['specialty']),
      degrees: str(map['degrees']),
      experience: str(map['experience']),
      hospital: str(map['hospital']),
      serviceArea: str(map['serviceArea']),
      available: str(map['available']),
      phone: str(map['phone']),
      whatsapp: str(map['whatsapp']),
      fee: str(map['fee']),
      services: stringList(map['services']),
      languages: stringList(map['languages']),
      photoUrl: str(map['photoUrl']),
      bio: str(map['bio']),
      chambers: chamberItems,
    );
  }
}

class BloodProfile {
  const BloodProfile({
    required this.id,
    required this.fullName,
    required this.bloodGroup,
    required this.gender,
    required this.phone,
    required this.whatsapp,
    required this.homeAddress,
    required this.contactAdminRequired,
  });

  final String id;
  final String fullName;
  final String bloodGroup;
  final String gender;
  final String phone;
  final String whatsapp;
  final String homeAddress;
  final bool contactAdminRequired;

  factory BloodProfile.fromJson(dynamic json) {
    final map = mapValue(json);
    return BloodProfile(
      id: str(map['id']),
      fullName: str(map['fullName'], 'Donor'),
      bloodGroup: str(map['bloodGroup']),
      gender: str(map['gender']),
      phone: str(map['phone']),
      whatsapp: str(map['whatsapp']),
      homeAddress: str(map['homeAddress']),
      contactAdminRequired: boolValue(map['contactAdminRequired']),
    );
  }
}

class AboutProfile {
  const AboutProfile({required this.name, required this.role, required this.photoUrl, required this.description});
  final String name;
  final String role;
  final String photoUrl;
  final String description;

  factory AboutProfile.fromJson(dynamic json) {
    final map = mapValue(json);
    return AboutProfile(
      name: str(map['name'], 'Team member'),
      role: str(map['role'], 'Team member'),
      photoUrl: str(map['photoUrl']),
      description: str(map['description']),
    );
  }
}

class AboutPost {
  const AboutPost({required this.title, required this.author, required this.coverImage, required this.excerpt, required this.content});
  final String title;
  final String author;
  final String coverImage;
  final String excerpt;
  final String content;

  factory AboutPost.fromJson(dynamic json) {
    final map = mapValue(json);
    return AboutPost(
      title: str(map['title'], 'Post'),
      author: str(map['author'], 'Medicare At Home'),
      coverImage: str(map['coverImage']),
      excerpt: str(map['excerpt']),
      content: str(map['content']),
    );
  }
}

class PaymentSettings {
  const PaymentSettings({required this.bkashNumber, required this.nagadNumber, required this.instructions});
  final String bkashNumber;
  final String nagadNumber;
  final String instructions;

  factory PaymentSettings.fromJson(dynamic json) {
    final map = mapValue(json);
    return PaymentSettings(
      bkashNumber: str(map['bkashNumber']),
      nagadNumber: str(map['nagadNumber']),
      instructions: str(map['instructions']),
    );
  }
}
