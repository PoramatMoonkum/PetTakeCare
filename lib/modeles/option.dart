class Option {
  bool? cat;
  bool? condo;
  bool? dog;
  bool? fountain;
  bool? home;

  Option({
    this.cat,
    this.condo,
    this.dog,
    this.fountain,
    this.home,
  });

  Option.fromJson(Map<String, Object?> json)
      : this(
          cat: json['cat'] as bool?,
          condo: json['condo'] as bool?,
          dog: json['dog'] as bool?,
          fountain: json['fountain'] as bool?,
          home: json['home'] as bool?,
        );

  Map<String, Object?> toJson() {
    return {
      'cat': cat,
      'condo': condo,
      'dog': dog,
      'fountain': fountain,
      'home': home,
    };
  }
}
