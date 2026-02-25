class Contact {
  final int? id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final bool isFavorite;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Contact({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.email = '',
    this.isFavorite = false,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed Properties

  /// Full display name.
  String get fullName => '$firstName $lastName'.trim();

  /// Initials for the avatar (max 2 characters).
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  /// Whether this contact has a valid avatar image path.
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;

  // SQLite Serialization

  /// Converts the [Contact] to a map for SQLite insertion/update.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'email': email,
      'is_favorite': isFavorite ? 1 : 0,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a [Contact] from a SQLite row map.
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      firstName: map['first_name'] as String? ?? '',
      lastName: map['last_name'] as String? ?? '',
      phoneNumber: map['phone_number'] as String? ?? '',
      email: map['email'] as String? ?? '',
      isFavorite: (map['is_favorite'] as int?) == 1,
      imagePath: map['image_path'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  // Copy With

  /// Returns a new [Contact] with the given fields replaced.
  ///
  /// Use [clearImage] to explicitly set [imagePath] to null (since passing
  /// `imagePath: null` is ambiguous with "not provided").
  Contact copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    bool? isFavorite,
    String? imagePath,
    bool clearImage = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Contact(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      isFavorite: isFavorite ?? this.isFavorite,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Equality & Debugging

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Contact && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Contact(id: $id, name: $fullName, phone: $phoneNumber)';
  }
}
