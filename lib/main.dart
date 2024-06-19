import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pettakecare/firebase_options.dart';
import 'package:pettakecare/view/main_tabview/main_tabview.dart';
import 'package:pettakecare/view/on_boarding/on_boarding_view.dart';
import 'package:pettakecare/view/on_boarding/startup_view.dart';
import 'package:flutter/foundation.dart';

void main() async {
  // _initializeFirebase();
  WidgetsFlutterBinding
      .ensureInitialized(); // ensure that Flutter is initialized

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform); // initialize Firebase
  runApp(MyApp(defaultHome: StartupView()));
}

class MyApp extends StatefulWidget {
  final Widget defaultHome;
  const MyApp({super.key, required this.defaultHome});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Pet Take Care',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: "Metropolis",
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a blue toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          // flutter no use hot reload and pub dev upgrade
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          // useMaterial3: true,
        ),
        home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            // initialData: FirebaseAuth.instance.currentUser,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else {
                if (!snapshot.hasData) {
                  return const StartupView();
                }

                return const MainTabView();
              }
            }));
  }
}

//  _initializeFirebase() async {
//      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   }