import '../client.dart';
import '../responses.dart';
import './resource.dart';

class ChargeResource extends Resource {
  final String host = "api.omise.co";
  ChargeResource(Client client, String publicKey, String apiVersion)
      : super(client, publicKey, apiVersion);

  /// Create a Charge
  ///
  /// See Omise API documentation for details
  /// https://www.omise.co/tokens-api#create
  ///
  /// ```dart
  /// final Charge = await omise.Charge.create("John Doe", "4242424242424242", "12", "2020", "123");
  /// ```
  Future<Charge> create(int amount, String currency, String source,
      {String? returnUri}) async {
    final data = {
      'amount': amount,
      'currency': currency,
      'source': source,
      'return_uri': returnUri,
    };

    final response = await client.post(host, ['charges'], data: data);
    return Charge.fromJson(response);
  }

  Future<Charge> query(String charge) async {
    final response = await client.get(host, ['charges', charge]);
    return Charge.fromJson(response);
  }
}
