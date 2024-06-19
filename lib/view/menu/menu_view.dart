import 'package:flutter/material.dart';
import 'package:pettakecare/view/menu/PetOwner_view.dart';
import 'package:pettakecare/view/menu/PetSitter_view.dart';
import 'package:pettakecare/view/profile/PetSitter_page.dart';

class MenuView extends StatefulWidget {
  const MenuView({Key? key}) : super(key: key);

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  void _navigateToDepositPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => PetSitterPage()));
  }

  void _navigateToPetOwnerPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => PetOwnerView()));
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: media.height * 0.05),
                child: Image.asset(
                  "assets/img/app_logo.png",
                  width: media.width * 0.55,
                  height: media.width * 0.55,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: media.height * 0.05), // Increase spacing
              GestureDetector(
                onTap: _navigateToDepositPage,
                child: Container(
                  width: media.width * 0.4,
                  height: media.width * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Center(
                    child: Text(
                      "รับดูแลสัตว์เลี้ยง",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _navigateToPetOwnerPage,
                child: Container(
                  width: media.width * 0.4,
                  height: media.width * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Center(
                    child: Text(
                      "ฝากสัตว์เลี้ยง",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MenuView(),
  ));
}
