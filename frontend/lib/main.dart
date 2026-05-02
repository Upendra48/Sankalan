import 'package:flutter/material.dart';
import 'package:trash_map/analytics/fetch.dart';
import 'package:trash_map/pages/analyticspage.dart';
import 'package:trash_map/pages/mappage.dart';
import 'package:trash_map/requestbin/user_form.dart';
import 'package:trash_map/fohor/report_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sankalan - Waste Management',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: Colors.green.shade50,
          indicatorColor: Colors.green.shade200,
          selectedIconTheme: IconThemeData(color: Colors.green.shade600),
          selectedLabelTextStyle: TextStyle(
            color: Colors.green.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const MapScreen(),
       AnalyticsPage(),
      const Center(child: Text('Settings')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline, size: 28),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sankalan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Smart Waste Management',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Tooltip(
                message: 'Home',
                child: IconButton(
                  icon: const Icon(Icons.home_outlined),
                  onPressed: () {
                    setState(() => _selectedIndex = 0);
                  },
                  isSelected: _selectedIndex == 0,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Tooltip(
                message: 'Analytics',
                child: IconButton(
                  icon: const Icon(Icons.analytics_outlined),
                  onPressed: () {
                    setState(() => _selectedIndex = 1);
                  },
                  isSelected: _selectedIndex == 1,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Tooltip(
                message: 'Settings',
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    setState(() => _selectedIndex = 2);
                  },
                  isSelected: _selectedIndex == 2,
                ),
              ),
            ),
          ),
        ],
      ),
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar Navigation
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() => _selectedIndex = index);
          },
          labelType: NavigationRailLabelType.all,
          destinations: [
            NavigationRailDestination(
              icon: const Icon(Icons.map_outlined),
              selectedIcon: const Icon(Icons.map),
              label: const Text('Map View'),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: const Icon(Icons.bar_chart),
              label: const Text('Analytics'),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.info_outlined),
              selectedIcon: const Icon(Icons.info),
              label: const Text('About'),
            ),
          ],
          trailing: Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton.extended(
                    heroTag: 'request',
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => RequestBinForm(),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Request Bin'),
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton.extended(
                    heroTag: 'report',
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) =>  ReportFohor(),
                      );
                    },
                    icon: const Icon(Icons.flag_outlined),
                    label: const Text('Report Issue'),
                    backgroundColor: Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Main Content
        Expanded(
          child: Container(
            color: Colors.grey.shade50,
            child: _pages[_selectedIndex],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        _pages[_selectedIndex],
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                heroTag: 'report',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) =>  ReportFohor(),
                  );
                },
                icon: const Icon(Icons.flag_outlined),
                label: const Text('Report'),
                backgroundColor: Colors.orange,
              ),
              const SizedBox(height: 12),
              FloatingActionButton.extended(
                heroTag: 'request',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) =>  RequestBinForm(),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Request'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
