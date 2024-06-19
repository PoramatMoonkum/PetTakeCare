import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pettakecare/common/color_extension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
String memberCollection = 'members';
String pointField = 'point';

class Member {
  String? id;
  String? name;
  String? email;
  String? mobile;
  String? address;
  int? point;

  Member({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.address,
    this.point,
  });

  factory Member.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ){
    final data = snapshot.data();
    return Member(
      id: snapshot.id,
      name: data?['name'],
      email: data?['email'],
      mobile: data?['mobile'],
      address: data?['address'],
      point: data?['point'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      if (name != null) "name": name,
      if (email != null) "email": email,
      if (mobile != null) "mobile": mobile,
      if (address != null) "address": address,
      if (point != null) "point": point,
    };
  }
}

Future<void> addpointToMember(String memberId, int pointToAdd) async {
  try {
    // Get reference to Firestore collection
    CollectionReference membersCollection =
        FirebaseFirestore.instance.collection(memberCollection);

    // Update member's point
    await membersCollection.doc(memberId).update({
      'point': FieldValue.increment(pointToAdd),
    });

    log('point added successfully!');
  } catch (e) {
    log('Error adding point: $e');
  }
}

Future<Member?> getCurrentUser(FirebaseAuth auth) async {
  User? user = auth.currentUser;
  if (user != null) {
    DocumentSnapshot<Map<String, dynamic>> memberSnapshot =
        await FirebaseFirestore.instance.collection(memberCollection).doc(user.uid).get();
    if (memberSnapshot.exists) {
      return Member.fromFirestore(memberSnapshot);
    }
  }
  return null;
}

Future<void> calculatePoint() async {
  Member? currentUser = await getCurrentUser(_auth);
  if (currentUser != null) {
    log('Current user: ${currentUser.id} ${currentUser.email}, point: ${currentUser.point}');
    //TODO: add logic to calculate point
    int newPoint = 10; // example fix point
    if (currentUser.id != ''){
      await addpointToMember(currentUser.id ?? '', newPoint);
      currentUser = await getCurrentUser(_auth);
      if (currentUser != null) {
        log('Current user: ${currentUser.id} ${currentUser.email}, point: ${currentUser.point}');
      }
    }
  } else {
    log('No user logged in.');
  }
}

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xfffDfDfD),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const SizedBox(
                  height: 46,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Welcome to PetTakeCare",
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Image.asset(
                          "assets/img/shopping_cart.png",
                          width: 25,
                          height: 25,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                    onPressed: () => {
                      calculatePoint()
                    }, child: const Text("Checkout"))
              ],
            ),
          ),
        ));
  }
}