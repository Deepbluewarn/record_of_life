import 'package:uuid/uuid.dart';

// 현상소 (film lab). 필름을 맡기고 현상·스캔 받는 외부 서비스.
class Lab {
  final String id;
  final String title;
  final String? phone;
  final String? address;
  final String? website;
  final String? notes;
  final DateTime? lastUsedAt;

  Lab({
    String? id,
    required this.title,
    this.phone,
    this.address,
    this.website,
    this.notes,
    this.lastUsedAt,
  }) : id = id ?? const Uuid().v4();

  Lab copyWith({
    String? title,
    String? phone,
    String? address,
    String? website,
    String? notes,
    DateTime? lastUsedAt,
  }) => Lab(
    id: id,
    title: title ?? this.title,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    website: website ?? this.website,
    notes: notes ?? this.notes,
    lastUsedAt: lastUsedAt ?? this.lastUsedAt,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'phone': phone,
    'address': address,
    'website': website,
    'notes': notes,
    'lastUsedAt': lastUsedAt?.toIso8601String(),
  };

  factory Lab.fromMap(Map<String, Object?> m) => Lab(
    id: m['id'] as String,
    title: m['title'] as String,
    phone: m['phone'] as String?,
    address: m['address'] as String?,
    website: m['website'] as String?,
    notes: m['notes'] as String?,
    lastUsedAt: m['lastUsedAt'] == null
        ? null
        : DateTime.parse(m['lastUsedAt'] as String),
  );
}
