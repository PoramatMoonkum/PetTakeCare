import 'package:flutter/material.dart';
import 'package:pettakecare/common/color_extension.dart';
import 'package:pettakecare/common_widget/round_textfield.dart';
import 'package:pettakecare/view/more/notifications.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController txtSearch = TextEditingController();

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
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NotificationsView()));},
                        icon: Image.asset(
                          "assets/img/more_notification.png",
                          width: 25,
                          height: 25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Find your PetOwner",
                        style: TextStyle(
                            color: TColor.secondaryText, fontSize: 11),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "current location",
                            style: TextStyle(
                                color: TColor.secondaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(
                            width: 25,
                          ),
                          Image.asset(
                            "assets/img/dropdown.png",
                            width: 12,
                            height: 12,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoundTextfield(
                hintText: "Search", 
                controller: txtSearch,
                left: Container(
                  alignment: Alignment.center,
                  width: 30,
                  child: Image.asset("assets/img/search.png",
                  width: 20,
                  height: 20,
                  ),
                ),
                ),
                ),
                const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Popular PetSitter",
                      style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                    Text(
                      "View All",
                      style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
                
              ],
            ),
          ),
        ));

  }
  
}
