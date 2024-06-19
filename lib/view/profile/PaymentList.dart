import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentListView extends StatefulWidget {
  const PaymentListView({Key? key}) : super(key: key);

  @override
  State<PaymentListView> createState() => _PaymentListViewState();
}

class _PaymentListViewState extends State<PaymentListView> {
  List<Map<String, dynamic>> _payments = [];
  late QuerySnapshot _querySnapshotUser;

  @override
  void initState() {
    super.initState();
    getPayments();
  }

  Future<void> getPayments() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore.collection('payments').get();
    QuerySnapshot querySnapshotUser = await firestore.collection('users').get();
    final allData = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    allData.sort((a, b) => (b['created_at'] as Timestamp)
        .compareTo(a['created_at'] as Timestamp)); // เรียงลำดับตามวันที่สร้าง
    setState(() {
      _payments = allData;
      _querySnapshotUser = querySnapshotUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return ListView.separated(
      itemCount: _payments.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: 10), // ความสูงของ space ระหว่างวันที่
      itemBuilder: (context, index) {
        var payment = _payments[index];
        for (DocumentSnapshot userDataMap in _querySnapshotUser.docs) {
          if (userDataMap.id == payment['user_id']) {
            var createdDateTime = payment['created_at'];
            // ignore: unused_local_variable
            String dateString =
                DateFormat('dd/MM/yyyy').format(createdDateTime.toDate());

            return Card(
              // ใส่การ์ดที่นี่
              child: ListTile(
                title: Text('ชื่อ: ${userDataMap['name'] ?? ''}'),
                subtitle: Text(
                    'Status: ${payment['created_at'] ?? ''}\nชื่อสัตว์เลี้ยง: ${payment['amount'].toString() ?? ''} \n ระยะเวลาที่ฝาก: ${payment['status'].toString() ?? ''}วัน'),
              ),
            );
          }
        }
      },
    );
  }
}
