import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pettakecare/view/card/card.dart';
import 'package:pettakecare/view/card/match.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final notificaions = FirebaseFirestore.instance.collection('notifications');
    final books = FirebaseFirestore.instance.collection('books');
    final currentUser = FirebaseAuth.instance.currentUser?.uid;

    Future<void> _acceptBook(bookId) async {
      await books.doc(bookId).update({
        'status': 'matched',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 30,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(media.width * 0.2),
                ),
                child: const Center(
                  child: Text(
                    "แจ้งเตือน",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder(
                stream: notificaions
                    .where('user_id', isEqualTo: currentUser)
                    .where('read', isEqualTo: false)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {}

                  List<Widget> items = [];

                  for (var item in snapshot.data!.docs.toList()) {
                    if (item.get('type') == 'booking') {
                      items.add(BookingCard(
                          bookId: item.get('extras')['book_id'].toString(),
                          onAcceptChanged: (accepted) async {
                            if (accepted) {
                              // call accept function and redirect to list page
                              await _acceptBook(
                                  item.get('extras')['book_id'].toString());
                            }
                            // mark as read
                            notificaions.doc(item.id).update({'read': true});
                          }));
                    }
                  }

                  if (items.length == 0) {
                    items.add(Container());
                  }

                  return Column(
                    children: items,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
