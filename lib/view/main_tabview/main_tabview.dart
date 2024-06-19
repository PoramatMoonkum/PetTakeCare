import 'package:flutter/material.dart';
import 'package:pettakecare/common/color_extension.dart';
import 'package:pettakecare/common_widget/tab_button.dart';
import 'package:pettakecare/view/chat/chatlist.dart';
import 'package:pettakecare/view/home/home_view.dart';
import 'package:pettakecare/view/menu/menu_view.dart';
import 'package:pettakecare/view/more/more_view.dart';
import 'package:pettakecare/view/profile/profile_view.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selctTab = 2;
  PageStorageBucket storageBucket = PageStorageBucket();
  Widget selectPageView = const HomeView();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: storageBucket, child: selectPageView),
      backgroundColor: const Color(0xffF5F5F5),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () {
            if (selctTab != 2) {
              selctTab = 2;
              selectPageView = const HomeView();
            }
            if (mounted) {
              setState(() {});
            }
          },
          shape: const CircleBorder(),
          backgroundColor: selctTab == 2 ? TColor.primary : TColor.placeholder,
          child: Image.asset(
            "assets/img/tab_home.png",
            width: 30,
            height: 30,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        surfaceTintColor: TColor.white,
        shadowColor: Colors.black,
        elevation: 1,
        notchMargin: 12,
        height: 64,
        shape: const CircularNotchedRectangle(),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TabButton(
                  title: "Menu",
                  icon: "assets/img/tab_menu.png",
                  onTap: () {
                    if (selctTab != 0) {
                      selctTab = 0;
                      selectPageView = const MenuView();
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  isSelected: selctTab == 0),
              TabButton(
                  title: "chat",
                  icon: "assets/img/chat.png",
                  onTap: () {
                    if (selctTab != 1) {
                      selctTab = 1;
                      selectPageView = UserListView();
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  isSelected: selctTab == 1),
              const SizedBox(
                width: 40,
                height: 40,
              ),
              TabButton(
                  title: "Profile",
                  icon: "assets/img/tab_profile.png",
                  onTap: () {
                    if (selctTab != 3) {
                      selctTab = 3;
                      selectPageView = const ProfileView();
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  isSelected: selctTab == 3),
              TabButton(
                  title: "more",
                  icon: "assets/img/tab_more.png",
                  onTap: () {
                    if (selctTab != 4) {
                      selctTab = 4;
                      selectPageView = MoreView();
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  isSelected: selctTab == 4),
            ],
          ),
        ),
      ),
    );
  }
}
