import 'package:flutter/material.dart';
import 'package:pettakecare/view/pay_view/checkout_view.dart';

class MyOrderView extends StatefulWidget {
  const MyOrderView({Key? key}) : super(key: key);

  @override
  State<MyOrderView> createState() => _MyOrderViewState();
}

class _MyOrderViewState extends State<MyOrderView> {
  PaymentMethod selectedPaymentMethod = PaymentMethod.QRCode;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Payment"),
        leading: BackButton(),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              RadioListTile<PaymentMethod>(
                title: const Text('QR Code'),
                value: PaymentMethod.QRCode,
                groupValue: selectedPaymentMethod,
                onChanged: (PaymentMethod? value) {
                  setState(() {
                    selectedPaymentMethod = value!;
                  });
                },
              ),
              RadioListTile<PaymentMethod>(
                title: const Text('PayPal'),
                value: PaymentMethod.paypal,
                groupValue: selectedPaymentMethod,
                onChanged: (PaymentMethod? value) {
                  setState(() {
                    selectedPaymentMethod = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CheckoutView()));
                  // ดำเนินการชำระเงินตามวิธีที่เลือก
                },
                child: Text("ชำระเงิน"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum PaymentMethod {
  QRCode,
  paypal,
}
