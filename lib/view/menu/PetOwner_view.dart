import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pettakecare/common_widget/round_button.dart';
import 'package:pettakecare/common_widget/round_textfield.dart';
import 'package:pettakecare/view/match/matching_view.dart';
import 'package:uuid/uuid.dart';

class PetOwnerView extends StatefulWidget {
  const PetOwnerView({super.key});

  @override
  State<PetOwnerView> createState() => _PetOwnerViewState();
}

class Option {
  final String key;
  final String label;
  bool value;

  Option(this.key, this.label, this.value);
}

class _PetOwnerViewState extends State<PetOwnerView> {
  var uuid = Uuid();
  final storageRef = FirebaseStorage.instance.ref();
  TextEditingController txtSearch = TextEditingController();
  TextEditingController textDisease = TextEditingController();

  final ImagePicker picker = ImagePicker();
  late XFile? image;

  Future<String> uploadFileFirebase(File file) async {
    final imgRef = storageRef.child('images');
    String fileName =
        uuid.v4() + '.' + file.path.split('.')[file.path.split('.').length - 1];
    final petRef = imgRef.child(fileName);
    return (await petRef.putFile(file)).ref.getDownloadURL();
  }

  Map<String, Option> options = <String, Option>{
    'cat': Option('cat', 'แมว', false),
    'dog': Option('dog', 'หมา', false),
    'condo': Option('condo', 'คอนโดแมว', false),
    'fountain': Option('fountain', 'น้ำพุแมว', false),
    'large': Option('large', 'พื้นที่สำหรับหมา', false),
  };

  int depositDays = 1;
  bool isHomeCareSelected = true;
  Map<String, String> uploadImage = {
    'url': 'assets/img/upload.png',
    'type': 'asset'
  };

  void incrementDepositDays() {
    setState(() {
      depositDays++;
    });
  }

  void setUploadImage(newImage) {
    setState(() {
      uploadImage = newImage;
    });
  }

  void decrementDepositDays() {
    setState(() {
      if (depositDays > 0) {
        depositDays--;
      }
    });
  }

  Future<String?> _createBooking() async {
    CollectionReference books = FirebaseFirestore.instance.collection('books');
    String? currentUser = FirebaseAuth.instance.currentUser?.uid;

    if (currentUser == null) {
      return null;
    }

    DateTime currentTime = DateTime.now();
    DateTime expirationTime = currentTime.add(Duration(minutes: 3));

    try {
      Map<String, Object>? data = {
        'user_id': currentUser,
        'day': depositDays,
        'onsite': isHomeCareSelected,
        'status': 'waiting',
        'pet_name': txtSearch.value.text.toString(),
        'pet_disease': textDisease.value.text.toString(),
        'pet_image': uploadImage['url'] ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'expiry': expirationTime,
      };
      data['options'] =
          options.map<String, bool>((key, value) => MapEntry(key, value.value));
      DocumentReference docRef = await books.add(data);
      return docRef.id;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error adding data to Firestore')),
      );
    }

    return null;
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Pet Owner"),
        leading: BackButton(),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: Form(
        key: _formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/img/app_logo.png",
                width: media.width * 0.35,
                height: media.width * 0.35,
                fit: BoxFit.contain,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(media.width * 0.2),
                ),
                child: const Center(
                  child: Text(
                    "สัตว์เลี้ยง",
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoundTextfield(
                  hintText: "ชื่อ :",
                  controller: txtSearch,
                  left: Container(
                    alignment: Alignment.center,
                    width: 30,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoundTextfield(
                  hintText: "โรคประจำตัว :",
                  controller: textDisease,
                  left: Container(
                    alignment: Alignment.center,
                    width: 30,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () async {
                  // log('work');
                  final img =
                      await picker.pickImage(source: ImageSource.gallery);
                  // log('Read file ${img?.path}');
                  try {
                    final url = await uploadFileFirebase(File(img!.path));
                    // log('Uploaded: ${url}');
                    setUploadImage({'type': 'network', 'url': url});
                  } catch (e) {
                    log(e.toString());
                  }
                },
                child: uploadImage['type'] == 'asset'
                    ? Image.asset(
                        uploadImage['url']!,
                        width: media.width * 0.5,
                        height: media.width * 0.3,
                        fit: BoxFit.contain,
                      )
                    : Image.network(
                        uploadImage['url']!,
                        width: media.width * 0.5,
                        height: media.width * 0.3,
                        fit: BoxFit.contain,
                      ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(media.width * 0.2),
                ),
                child: const Center(
                  child: Text(
                    "แท็กสื่อที่ต้องการ",
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
              Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: createOptionWidget(options)),
              const SizedBox(
                height: 20,
              ),
              Text(
                'ฝากกี่วัน: $depositDays',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: decrementDepositDays,
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: incrementDepositDays,
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isHomeCareSelected =
                            true; // กำหนดให้เลือก "ดูแลที่บ้าน"
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isHomeCareSelected ? Colors.green : Colors.grey,
                    ),
                    child: const Text('ดูแลที่บ้าน'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isHomeCareSelected =
                            false; // กำหนดให้เลือก "ฝากผู้ดูแล"
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !isHomeCareSelected ? Colors.green : Colors.grey,
                    ),
                    child: const Text('ฝากผู้ดูแล'),
                  ),
                ],
              ),
              RoundButton(
                  title: "ค้นหาผู้รับฝาก",
                  onPressed: () async {
                    String? bookId = await _createBooking();
                    if (bookId == null) {
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MatchingView(
                          bookId: bookId,
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ),
      )),
    );
  }

  List<Widget> createOptionWidget(Map<String, Option> options) {
    List<Widget> list = [];
    options.forEach((key, option) {
      list.add(
        ChoiceChip(
          label: Text(option.label),
          selected: option.value,
          onSelected: (isSelected) {
            setState(() {
              option.value = !option.value;
            });
          },
          selectedColor: Colors.green,
          labelStyle: TextStyle(
            color: option.value ? Colors.black : Colors.white,
          ),
          backgroundColor: option.value ? Colors.white : Colors.green,
        ),
      );
    });
    return list;
  }
}
