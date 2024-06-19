import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pettakecare/common/consts.dart';
import 'package:pettakecare/view/home/home_view.dart';
import 'package:pettakecare/view/chat/chatlist.dart';
import 'package:pettakecare/view/pay_view/omise/omise.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';

enum Payment { promptpay, rabbit_linepay }

class PaymentView extends StatefulWidget {
  const PaymentView({super.key, required this.bookId});
  final String? bookId;

  @override
  State<PaymentView> createState() => _MenuViewState();
}

class _MenuViewState extends State<PaymentView> {
  final books = FirebaseFirestore.instance.collection('books');
  // final notifications = FirebaseFirestore.instance.collection('notifications');
  final payments = FirebaseFirestore.instance.collection('payments');

  Timer? timer;
  Payment? _payment = Payment.promptpay;
  bool isScanable = false;
  String? qrCode;
  String? payMentLink;

  /// Get your public key on Omise Dashboard
  OmiseFlutter omiseClient = OmiseFlutter(OMISE_PUBLIC_KEY);
  OmiseFlutter omise = OmiseFlutter(OMISE_PRIVATE_KEY);

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _setPayment(value) {
    setState(() {
      _payment = value;
    });
  }

  Future<void> _generatePayment(amount) async {
    // See Omise API documentation for details
    // https://www.omise.co/sources-api
    final source = await omise.source.create(
        (amount * 100), "THB", _payment.toString().split('.').last.toString());
    log('source ${source.id}');
    final charge = await omise.charge.create(
        (amount * 100), "THB", source.id.toString(),
        returnUri: 'http://localhost');

    // TODO: loop check status
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      omise.charge.query(charge.id.toString()).then((charge) {
        if (charge.status == 'successful') {
          //TODO: update payment status
          final payment = payments.add({
            'book_id': widget.bookId,
            'charge': charge.toJson(),
          });
          books
              .doc(widget.bookId)
              .update({'status': 'paid', 'payment': payment});
          QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              text: 'ทำรายการสำเร็จ!',
              title: 'สำเร็จ!',
              confirmBtnText: 'ตกลง',
              onConfirmBtnTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            UserListView()), // TODO: หลังจากจ่ายเงินไปที่หน้าอื่น
                    (route) => route.isFirst);
              });
          t.cancel();
        }
      });
    });

    // log(charge.toString());
    if (charge.source?.scannableCode != null) {
      String? url = charge.source!.scannableCode!.image!.download_uri;
      // final rawSvg = await loadImageV2(url!, {
      //   'Authorization':
      //       'Basic ${base64Encode(utf8.encode('$OMISE_PRIVATE_KEY:'))}'
      // });

      setState(() {
        isScanable = true;
        qrCode = url;
      });
      return;
    } else {
      setState(() {
        isScanable = false;
        payMentLink = charge.authorizeUri!;
      });
    }
  }

  Future<void> _launchInBrowser(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.inAppBrowserView,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<Object?> loadImageV2(String url, Map<String, String>? headers) async {
    final response = await http.get(Uri.parse(url), headers: headers);
    return response.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Payment"),
          leading: BackButton(),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            child: FutureBuilder<DocumentSnapshot>(
          future: books.doc(widget.bookId).get(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              log(snapshot.error.toString());
            }
            if (snapshot.hasData) {
              final book = snapshot.data;

              final sitterRef = book!.get('sitter') as DocumentReference?;

              return Column(
                children: [
                  FutureBuilder<DocumentSnapshot>(
                    future: sitterRef?.get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        log(snapshot.error.toString());
                      }
                      if (snapshot.connectionState == ConnectionState.done) {
                        final sitter = snapshot.data;
                        log('sitter: ${sitter.toString()}');

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'ผู้รับฝาก',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          child: Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.blueGrey,
                                              child: sitter
                                                      ?.get('image')
                                                      .startsWith('http')
                                                  ? Image.network(
                                                      sitter?.get('image') ??
                                                          '',
                                                      width: 120,
                                                      height: 80,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Image.asset(
                                                          'assets/img/app_logo.png',
                                                          width: 120,
                                                          height: 80,
                                                        );
                                                      },
                                                    )
                                                  : Image.asset(
                                                      'assets/img/app_logo.png',
                                                      width: 120,
                                                      height: 80,
                                                    )),
                                        ),
                                        Column(
                                          children: [
                                            // Text(book?.sitter?.name.toString() ?? ''),
                                            ElevatedButton(
                                              onPressed: () {},
                                              style: ButtonStyle(
                                                side: MaterialStateProperty.all<
                                                    BorderSide>(
                                                  const BorderSide(
                                                      color: Colors.orange,
                                                      width: 2.0),
                                                ),
                                              ),
                                              child: const Text(
                                                'ดูโปรไฟล์',
                                                style: TextStyle(
                                                    color: Colors.orange),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                )),
                            const Divider(),
                            Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Text(
                                      'ที่อยู่',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Text(sitter?.get('address') ?? ''),
                                  ],
                                )),
                            const Divider(),
                            const Padding(
                                padding: EdgeInsets.only(left: 20, right: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'สัตว์เลี้ยง',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                )),
                          ],
                        );
                      }
                      return Container();
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      book.get('pet_image').startsWith('http')
                          ? Image.network(
                              book.get('pet_image') ?? '',
                              width: 120,
                              height: 80,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/img/app_logo.png',
                                  width: 120,
                                  height: 80,
                                );
                              },
                            )
                          : Image.asset(
                              'assets/img/app_logo.png',
                              width: 120,
                              height: 80,
                            ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ชื่อ: ${book!.get('pet_name')}'),
                          Text('จำนวนวัน: ${book.get('day')}'),
                          ElevatedButton(
                            onPressed: () {},
                            child: Text(
                                'ยอดรวม ${(PAY_PERDAY * (book.get('day') ?? -1))} บาท'),
                          )
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'การชำระเงิน',
                            style: TextStyle(fontSize: 20),
                          ),
                          Column(
                            children: [
                              ListTile(
                                title: const Text('Prompay QR'),
                                leading: Radio<Payment>(
                                  value: Payment.promptpay,
                                  groupValue: _payment,
                                  onChanged: (value) {
                                    _setPayment(value);
                                  },
                                ),
                              ),
                              ListTile(
                                  title: const Text('Rabbit LINE Pay'),
                                  leading: Radio<Payment>(
                                    value: Payment.rabbit_linepay,
                                    groupValue: _payment,
                                    onChanged: (value) {
                                      _setPayment(value);
                                    },
                                  ))
                            ],
                          ),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: isScanable
                        ? const CircularProgressIndicator()
                        : payMentLink != null
                            ? TextButton(
                                onPressed: () {
                                  _launchInBrowser(payMentLink!);
                                },
                                child: Text(payMentLink!),
                              )
                            : Container(),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            timer?.cancel();
                            _generatePayment(
                                PAY_PERDAY * (book.get('day') ?? 1));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffFC6011),
                            foregroundColor: Color.fromARGB(255, 255, 255, 255),
                          ),
                          child: const Text(
                            'ชำระเงิน',
                          ))
                    ],
                  )
                ],
              );
            }

            return const Text('error');
          },
        )));
  }
}
