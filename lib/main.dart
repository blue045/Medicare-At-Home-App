import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/app_state.dart';
import 'core/app_theme.dart';
import 'screens/ambulance_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/blood_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/doctors_screen.dart';
import 'screens/home_screen.dart';
import 'screens/more_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/services_screen.dart';
import 'screens/store_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiClient();
  final state = AppState(api);
  await state.restore();
  runApp(MedicareApp(api: api, state: state));
}

class MedicareApp extends StatelessWidget {
  const MedicareApp({super.key, required this.api, required this.state});

  final ApiClient api;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: api),
        ChangeNotifierProvider<AppState>.value(value: state),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Medicare At Home',
        theme: AppTheme.light,
        home: const RootShell(),
        routes: {
          AuthScreen.route: (_) => const AuthScreen(),
          ProfileScreen.route: (_) => const ProfileScreen(),
          AmbulanceScreen.route: (_) => const AmbulanceScreen(),
          ServicesScreen.route: (_) => const ServicesScreen(),
          ContactScreen.route: (_) => const ContactScreen(),
        },
      ),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int index = 0;

  final pages = const [
    HomeScreen(),
    StoreScreen(),
    DoctorsScreen(),
    BloodScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: index, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Store'),
          NavigationDestination(icon: Icon(Icons.medical_services_outlined), selectedIcon: Icon(Icons.medical_services), label: 'Doctors'),
          NavigationDestination(icon: Icon(Icons.bloodtype_outlined), selectedIcon: Icon(Icons.bloodtype), label: 'Blood'),
          NavigationDestination(icon: Icon(Icons.menu_rounded), label: 'More'),
        ],
      ),
    );
  }
}
