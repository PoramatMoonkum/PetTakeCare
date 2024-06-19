import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pettakecare/view/menu/PetSitter_view.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:pettakecare/common_widget/notification.dart';

class PetSitterPage extends StatefulWidget {
  @override
  PetSitterPageState createState() {
    return PetSitterPageState();
  }
}

class Option {
  final String key;
  final String label;
  bool value;

  Option(this.key, this.label, this.value);
}

class PetSitterPageState extends State<PetSitterPage> {
  final _formKey = GlobalKey<FormState>();
  String? sitterId;
  CollectionReference sitters =
      FirebaseFirestore.instance.collection('sitters');

  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtMobile = TextEditingController();
  TextEditingController txtAddress = TextEditingController();

  Map<String, Option> options = <String, Option>{
    'cat': Option('cat', 'แมว', false),
    'dog': Option('dog', 'หมา', false),
    'condo': Option('condo', 'คอนโดแมว', false),
    'fountain': Option('fountain', 'น้ำพุแมว', false),
    'large': Option('large', 'พื้นที่สำหรับหมา', false),
  };

  void setOption(Option option, bool value) {
    options[option.key]?.value = value;
  }

  Future<String?> _createSistter(String? sitter) async {
    String? currentUser = FirebaseAuth.instance.currentUser?.uid;

    if (currentUser == null) {
      return null;
    }

    try {
      Map<String, Object>? data = {
        'user_id': currentUser,
        'name': txtName.value.text.toString(),
        'address': txtAddress.value.text.toString(),
        'mobile': txtMobile.value.text.toString(),
        'email': txtEmail.value.text.toString(),
        ...options
            .map<String, bool>((key, value) => MapEntry(key, value.value)),
        'timestamp': FieldValue.serverTimestamp(),
      };
      if (sitter != null) {
        log('updated!');
        await sitters.doc(sitter).update(data);
        return 'success';
      }
      DocumentReference docRef = await sitters.add(data);
      return docRef.id;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error adding data to Firestore')),
      );
    }

    return null;
  }

  Future<void> _fetchSitter() async {
    String? currentUser = FirebaseAuth.instance.currentUser?.uid;
    if (currentUser == null) {
      return;
    }
    QuerySnapshot<Object?> snapshot =
        await sitters.where('user_id', isEqualTo: currentUser).get();

    final sitter = snapshot.docs.firstOrNull;
    if (sitter!.exists) {
      setState(() {
        sitterId = sitter.id;
      });

      Map<String, dynamic> data = sitter.data()! as Map<String, dynamic>;
      txtName.text = data.containsKey('name') ? data['name'] : '';
      txtEmail.text = data.containsKey('email') ? data['email'] : '';
      txtAddress.text = data.containsKey('address') ? data['address'] : '';
      txtMobile.text = data.containsKey('mobile') ? data['mobile'] : '';

      sitterId = sitter.id;

      options.forEach((key, option) {
        if (data.containsKey(key)) {
          option.value = data[key];
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _fetchSitter();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pet Sitter"),
        leading: BackButton(),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: const [NotificationBadge()],
      ),
      body: SingleChildScrollView(
          child: Column(children: [
        Center(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: txtName,
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                TextFormField(
                  controller: txtEmail,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                TextFormField(
                  controller: txtMobile,
                  decoration: InputDecoration(
                    labelText: 'Mobile',
                  ),
                ),
                TextFormField(
                  controller: txtAddress,
                  decoration: InputDecoration(
                    labelText: 'Address',
                  ),
                ),
                ...createOptionWidget(options),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Processing Data')));

                        String? sitter_id = await _createSistter(sitterId);
                        if (sitter_id == null) {
                          return;
                        }

                        QuickAlert.show(
                            context: context,
                            type: QuickAlertType.success,
                            text: 'ทำรายการสำเร็จ!',
                            title: 'สำเร็จ!',
                            confirmBtnText: 'ตกลง');
                      }
                    },
                    child: Text('บันทึก'),
                  ),
                ),
              ],
            ),
          ),
        )
      ])),
    );
  }

  List<Widget> createOptionWidget(Map<String, Option> options) {
    List<Widget> list = [];
    options.forEach((key, option) {
      list.add(
        CheckboxListTile(
          title: Text(option.label),
          value: option.value,
          onChanged: (isSelected) {
            log('change');
            setState(() {
              option.value = !option.value;
            });
          },
        ),
      );
    });
    return list;
  }
}
