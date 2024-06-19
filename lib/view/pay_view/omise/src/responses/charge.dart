part of '../responses.dart';

/// Token API: please check https://www.omise.co/tokens-api
class Charge {
  String? object;
  String? id;
  bool? livemode;
  String? location;
  String? chargeStatus;
  String? createdAt;
  bool? used;
  String? currency;
  Source? source;
  String? authorizeUri;
  String? status;

  Charge({
    this.object,
    this.id,
    this.livemode,
    this.location,
    this.createdAt,
    this.currency,
    this.chargeStatus,
    this.used,
    this.source,
    this.authorizeUri,
    this.status,
  });

  Charge.fromJson(Map<String, dynamic> json) {
    object = json['object'];
    id = json['id'];
    livemode = json['livemode'];
    location = json['location'];
    chargeStatus = json['charge_status'];
    createdAt = json['created_at'];
    currency = json['currency'];
    used = json['used'];
    source = json['source'] != null ? Source.fromJson(json['source']) : null;
    authorizeUri = json['authorize_uri'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['object'] = this.object;
    data['id'] = this.id;
    data['livemode'] = this.livemode;
    data['location'] = this.location;
    data['charge_status'] = this.chargeStatus;
    data['created_at'] = this.createdAt;
    data['currency'] = this.currency;
    data['used'] = this.used;
    if (this.source != null) {
      data['source'] = this.source!.toJson();
    }
    data['authorize_uri'] = this.authorizeUri;
    data['status'] = this.status;
    return data;
  }
}
