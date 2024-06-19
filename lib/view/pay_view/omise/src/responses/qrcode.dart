part of '../responses.dart';

class Image {
  String? object;
  bool? livemode;
  String? id;
  bool? deleted;
  String? filename;
  String? location;
  String? kind;
  String? download_uri;
  String? created_at;

  Image({
    this.object,
    this.livemode,
    this.id,
    this.deleted,
    this.filename,
    this.location,
    this.kind,
    this.download_uri,
    this.created_at,
  });

  Image.fromJson(Map<String, dynamic> json) {
    object = json['object'];
    livemode = json['livemode'];
    id = json['id'];
    deleted = json['deleted'];
    filename = json['filename'];
    location = json['location'];
    kind = json['kind'];
    download_uri = json['download_uri'];
    created_at = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['object'] = this.object;
    data['livemode'] = this.livemode;
    data['id'] = this.id;
    data['deleted'] = this.deleted;
    data['filename'] = this.filename;
    data['location'] = this.location;
    data['kind'] = this.kind;
    data['download_uri'] = this.download_uri;
    data['created_at'] = this.created_at;

    return data;
  }
}

class QRCode {
  String? object;
  String? type;
  Image? image;

  QRCode({this.object, this.type, this.image});

  QRCode.fromJson(Map<String, dynamic> json) {
    object = json['object'];
    type = json['type'];
    image = json['image'] != null ? new Image.fromJson(json['image']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['object'] = this.object;
    data['type'] = this.type;
    if (this.image != null) {
      data['image'] = this.image!.toJson();
    }

    return data;
  }
}
