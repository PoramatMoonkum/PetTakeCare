import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pettakecare/view/more/notifications.dart';

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final notificaions = FirebaseFirestore.instance.collection('notifications');
    final currentUser = FirebaseAuth.instance.currentUser?.uid;

    return IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationsView(),
            ),
          );
        },
        icon: StreamBuilder(
            stream: notificaions
                .where('user_id', isEqualTo: currentUser)
                .where('read', isEqualTo: false)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {}

              if (snapshot.data!.docs.length > 0) {
                return Badge(
                  label: Text((snapshot.data!.docs.length).toString()),
                  offset: const Offset(5, -5),
                  child: Image.asset(
                    "assets/img/more_notification.png",
                    width: 25,
                    height: 25,
                  ),
                );
              }

              return Image.asset(
                "assets/img/more_notification.png",
                width: 25,
                height: 25,
              );
            }));
  }
}
