class Sitter {
  String? name;
  String? address;
  bool? cat;
  bool? condo;
  bool? dog;
  bool? fountain;
  bool? home;
  bool? onsite;
  String? userId;

  Sitter({
    this.name,
    this.address,
    this.cat,
    this.condo,
    this.dog,
    this.fountain,
    this.home,
    this.onsite,
    this.userId,
  });

  Sitter.fromJson(Map<String, Object?> json)
      : this(
            name: json['name'] as String?,
            address: json['address'] as String?,
            cat: json['cat'] as bool?,
            condo: json['condo'] as bool?,
            dog: json['dog'] as bool?,
            fountain: json['fountain'] as bool?,
            home: json['home'] as bool?,
            onsite: json['onsite'] as bool?,
            userId: json['user_id'] as String?);

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'address': address,
      'cat': cat,
      'condo': condo,
      'dog': dog,
      'fountain': fountain,
      'home': home,
      'onsite': onsite,
      'user_id': userId,
    };
  }
}
