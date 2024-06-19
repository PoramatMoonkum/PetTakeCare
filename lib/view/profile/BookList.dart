import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookListView extends StatefulWidget {
  const BookListView({Key? key}) : super(key: key);

  @override
  State<BookListView> createState() => _BookListViewState();
}

class _BookListViewState extends State<BookListView> {
  List<Map<String, dynamic>> _books = [];
  late QuerySnapshot _querySnapshotUser;

  @override
  void initState() {
    super.initState();
    getBooks();
  }

  Future<void> getBooks() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore.collection('books').get();
    QuerySnapshot querySnapshotUser = await firestore.collection('users').get();
    final allData = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    allData.sort((a, b) => (b['expiry'] as Timestamp)
        .compareTo(a['expiry'] as Timestamp)); // เรียงลำดับตามวันที่หมดอายุ
    // กรองเฉพาะหนังสือที่มีสถานะการจับคู่สำเร็จ
    final matchedBooks =
        allData.where((book) => book['status'] == 'matched').toList();
    setState(() {
      _books = matchedBooks;
      _querySnapshotUser = querySnapshotUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return ListView.separated(
      itemCount: _books.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: 10), // ความสูงของ space ระหว่างวันที่
      itemBuilder: (context, index) {
        var book = _books[index];
        for (DocumentSnapshot userDataMap in _querySnapshotUser.docs) {
          if (userDataMap.id == book['user_id']) {
            var expiryDateTime = book['expiry'];
            String dateString =
                DateFormat('dd/MM/yyyy').format(expiryDateTime.toDate());

            return Card(
              color: Color.fromARGB(
                  255, 253, 253, 253), // Set the background color to white
              // ใส่การ์ดที่นี่
              child: ListTile(
                title: Text('ชื่อ: ${userDataMap['name'] ?? ''}'),
                subtitle: Text(
                    'Status: ${book['status'] ?? ''}\nชื่อสัตว์เลี้ยง: ${book['pet_name'].toString() ?? ''}\nวันที่: $dateString \n ระยะเวลาที่ฝาก: ${book['day'].toString() ?? ''}วัน'),
              ),
            );
          }
        }
      },
    );
  }
}
