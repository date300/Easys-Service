import 'package:flutter/material.dart';

// আপনার যদি আলাদা ফাইলে স্ক্রিনগুলো থাকে, তবে এখানে ইমপোর্ট করুন:
// import '../features/home/home_screen.dart';
// import '../features/reselling/reselling_screen.dart';
// import '../features/microjobs/microjobs_screen.dart';
// import '../features/campaigns/campaigns_screen.dart';
// import '../features/drive/drive_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _CurrentPage extends StatelessWidget {
  final String title;
  const _CurrentPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  // ৫টি পেজের লিস্ট
  final List<Widget> _pages = const [
    _CurrentPage(title: "Home Screen"),
    _CurrentPage(title: "Reselling Screen"),
    _CurrentPage(title: "Microjobs Screen"),
    _CurrentPage(title: "Campaigns Screen"),
    _CurrentPage(title: "Drive Offers Screen"),
  ];

  @override
  Widget build(BuildContext context) {
    const Color skyBlue = Color(0xFF29B6F6);

    return Scaffold(
      // ব্যাকগ্রাউন্ড আকাশি যাতে কার্ভের পেছনে গ্যাপ না থাকে
      backgroundColor: skyBlue,

      // ১. সাইডবার (Drawer)
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: skyBlue),
              accountName: Text("Easy Service User", style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text("user@easyservice.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: skyBlue, size: 40),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("History"),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {},
            ),
          ],
        ),
      ),

      appBar: AppBar(
        backgroundColor: skyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Easy Service',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        // ২. ড্রয়ার খোলার বাটন
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_open_rounded, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),

      // ৩. আপনার সেই পছন্দের রাউন্ডেড বডি
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
        ),
      ),

      // ৪. কাস্টমাইজড নেভিগেশন বার
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: skyBlue.withOpacity(0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: skyBlue, fontWeight: FontWeight.bold, fontSize: 12);
            }
            return const TextStyle(color: Colors.grey, fontSize: 11);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: skyBlue, size: 28);
            }
            return const IconThemeData(color: Colors.grey, size: 24);
          }),
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          height: 70,
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront),
              label: 'Reselling',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: 'Microjobs',
            ),
            NavigationDestination(
              icon: Icon(Icons.campaign_outlined),
              selectedIcon: Icon(Icons.campaign),
              label: 'Campaigns',
            ),
            NavigationDestination(
              icon: Icon(Icons.directions_car_outlined),
              selectedIcon: Icon(Icons.directions_car),
              label: 'Drive',
            ),
          ],
        ),
      ),
    );
  }
}
