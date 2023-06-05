import 'package:appweb/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white, //#fbd064 navigation bar color
      // statusBarColor: Color.fromRGBO(251, 218, 97, 1), // status bar color
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark, // status bar icon color
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  const SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final WebViewController _controller;
  bool _isLoading = false;
  int _selectedIndex = 0;

  static const List<String> _page = [
    "https://buyview.net/",
    "https://buyview.net/orders",
    "https://buyview.net/addfunds",
    "https://buyview.net/tickets",
    "https://buyview.net/account"
  ];

  ////noti
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // FlutterNativeSplash.remove();
    _firebaseMessaging.requestPermission();
    _firebaseMessaging.getToken().then((value) => {print('Token: $value')});
    FirebaseMessaging.instance.subscribeToTopic('appweb');
    checkPermissions();
    listenNoti();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _controller.canGoBack()) {
          _controller.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(children: [
            WebViews(),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ]),
        ),
        bottomNavigationBar: buildBottomNavigationBar(),
      ),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: const Image(
            image: AssetImage('assets/icons/shoppingcart.png'),
            height: 24,
            width: 24,
          ),
          activeIcon: Image.asset(
            'assets/icons/shoppingcart.png',
            width: 24,
            height: 24,
            color: Colors.orangeAccent,
          ),
          label: "New order",
        ),
        BottomNavigationBarItem(
            icon: const Image(
              image: AssetImage('assets/icons/shoppingbag.png'),
              height: 24,
              width: 24,
            ),
            activeIcon: Image.asset(
              'assets/icons/shoppingbag.png',
              width: 24,
              height: 24,
              color: Colors.orangeAccent,
            ),
            label: "My orders"),
        BottomNavigationBarItem(
            icon: const Image(
              image: AssetImage('assets/icons/wallet.png'),
              height: 24,
              width: 24,
            ),
            activeIcon: Image.asset(
              'assets/icons/wallet.png',
              width: 24,
              height: 24,
              color: Colors.orangeAccent,
            ),
            label: "Add funds"),
        BottomNavigationBarItem(
            icon: const Image(
              image: AssetImage('assets/icons/comment.png'),
              height: 24,
              width: 24,
            ),
            activeIcon: Image.asset(
              'assets/icons/comment.png',
              width: 24,
              height: 24,
              color: Colors.orangeAccent,
            ),
            label: "Tickets"),
        BottomNavigationBarItem(
            icon: const Image(
              image: AssetImage('assets/icons/user.png'),
              height: 24,
              width: 24,
            ),
            activeIcon: Image.asset(
              'assets/icons/user.png',
              width: 24,
              height: 24,
              color: Colors.orangeAccent,
            ),
            label: "Account")
      ],
      iconSize: 24,
      type: BottomNavigationBarType.shifting,
      showSelectedLabels: false,
      selectedLabelStyle: const TextStyle(fontFamily: 'MyFont', fontSize: 14),
      currentIndex: _selectedIndex,
      // selectedIconTheme: IconThemeData(
      //   color: Colors.red,
      // ),
      selectedItemColor: Colors.orange,
      onTap: (value) {
        setState(() {
          _controller.loadUrl(_page[value]);
          setState(() {
            _selectedIndex = value;
          });
        });
      },
    );
  }

  //bottom nav
  Container NavBottom() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          blurRadius: 20,
          color: Colors.black.withOpacity(.1),
        )
      ]),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SafeArea(
            child: GNav(
              rippleColor: Colors.green[300]!,
              hoverColor: Colors.green[100]!,
              gap: 8,
              activeColor: Colors.orange,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.orange[100]!,
              color: Colors.grey[800],
              tabBorderRadius: 15,
              haptic: true,
              tabs: const [
                GButton(
                  text: "New order",
                  icon: Icons.shopping_cart_outlined,
                ),
                GButton(
                  text: "My orders",
                  icon: Icons.shopping_bag_outlined,
                ),
                GButton(
                  text: "Add funds",
                  icon: Icons.monetization_on_outlined,
                ),
                GButton(
                  text: "Account",
                  icon: Icons.account_circle_outlined,
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                _controller.loadUrl(_page[index]);
                setState(() {
                  _selectedIndex = index;
                });
              },
            )),
      ),
    );
  }

  //webview
  WebView WebViews() {
    return WebView(
        initialUrl: _page[_selectedIndex],
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) {
          _controller = controller;
        },
        onPageStarted: (String url) {
          setState(() {
            _isLoading = true;
          });
        },
        onPageFinished: (String url) {
          setState(() {
            _isLoading = false;
          });
        },
        onWebResourceError: (error) => _showErrorDialog());
  }

  //// show dialog
  _showErrorDialog() {
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: const Text(
              "No Internet",
              style: TextStyle(fontFamily: "MyFont"),
            ),
            content: const Text(
              "Please check your internet connection and try again",
              style: TextStyle(fontFamily: "MyFont"),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
              ),
            ],
          ),
    );
  }

  ///xin quyen
  void checkPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
      _firebaseMessaging.requestPermission();
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void listenNoti() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("On Mess: ${message.notification?.title}");
      showNotification(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: ${message.notification?.body}");
      showNotification(message);
    });
  }

  void showNotification(RemoteMessage message) {
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
        'channel_id', 'channel_title',
        importance: Importance.high);
    AndroidNotificationDetails details = AndroidNotificationDetails(
        channel.id, channel.name,
        icon: '@mipmap/ic_launcher');

    FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
    int id = message.notification.hashCode;
    String? title = message.notification?.title;
    String? body = message.notification?.body;

    plugin.show(id, title, body, NotificationDetails(
        android: details, iOS: const DarwinNotificationDetails()),
        payload: 'Custom_Sound');
  }
}

