import 'package:flutter/material.dart';
import 'package:trash_map/api.dart';
import 'package:trash_map/auth/auth_service.dart';
import 'package:trash_map/fohor/report_form.dart';
import 'package:trash_map/pages/analyticspage.dart';
import 'package:trash_map/pages/mappage.dart';
import 'package:trash_map/requestbin/user_form.dart';

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
          seedColor: const Color(0xFF059669),
          primary: const Color(0xFF059669),
          secondary: const Color(0xFF0F172A),
          surface: const Color(0xFFF8FAFC),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF0F172A),
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: const Color(0xFF0F172A),
          indicatorColor: const Color(0xFF059669).withOpacity(0.24),
          selectedIconTheme: const IconThemeData(color: Color(0xFF34D399)),
          unselectedIconTheme: const IconThemeData(color: Color(0xFF64748B)),
          selectedLabelTextStyle: const TextStyle(
            color: Color(0xFF34D399),
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelTextStyle: const TextStyle(color: Color(0xFF64748B)),
        ),
      ),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await AuthService.instance.loadSession();
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleLogin(
    String email,
    String name,
    String photoUrl,
  ) async {
    final success = await AuthService.instance.loginWithGoogle(
      email: email,
      name: name,
      photoUrl: photoUrl,
    );

    if (!mounted) return;

    if (success) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome, ${AuthService.instance.currentUserName}!'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.instance.logout();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!AuthService.instance.isLoggedIn) {
      return GoogleLoginPage(onLogin: _handleLogin);
    }

    return HomePage(onLogout: _handleLogout);
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback onLogout;

  const HomePage({super.key, required this.onLogout});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  double? _targetLat;
  double? _targetLng;

  int _totalBins = 0;
  int _fullBins = 0;
  int _pendingRequests = 0;
  int _unresolvedReports = 0;
  bool _statsLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDashboardStats();
  }

  Future<void> _fetchDashboardStats() async {
    setState(() => _statsLoading = true);
    try {
      final analyticsResponse = await apiGet('waste-bin-analytics/');
      final requestsResponse = await apiGet('bin-requests/');
      final reportsResponse = await apiGet('waste-reports/');

      if (mounted) {
        setState(() {
          if (analyticsResponse.statusCode == 200) {
            final data = unwrapMap(analyticsResponse);
            _totalBins = data['total_bins'] ?? 0;
            _fullBins = data['full_bins'] ?? 0;
          }
          if (requestsResponse.statusCode == 200) {
            _pendingRequests = unwrapList(requestsResponse).length;
          }
          if (reportsResponse.statusCode == 200) {
            _unresolvedReports = unwrapList(reportsResponse).length;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');
    } finally {
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final isMobile = MediaQuery.of(context).size.width < 700;

    final pages = [
      _buildDashboardHub(auth.currentUserName ?? 'User'),
      MapScreen(targetLat: _targetLat, targetLng: _targetLng),
      AnalyticsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.recycling_rounded,
                size: 24,
                color: Color(0xFF34D399),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SANKALAN',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Smart Waste Management',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'logout') widget.onLogout();
            },
            offset: const Offset(0, 48),
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF059669),
                  backgroundImage: NetworkImage(
                    auth.currentUserPhoto ?? 'https://www.gravatar.com/avatar/',
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  auth.currentUserName ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.currentUserName ?? 'User',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      auth.currentUserEmail ?? '',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Sign Out', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchDashboardStats,
            )
          else
            TextButton.icon(
              onPressed: _fetchDashboardStats,
              icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
              label: const Text(
                'Refresh',
                style: TextStyle(color: Colors.white),
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          if (!isMobile)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => _selectedIndex = index),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_customize_outlined),
                  selectedIcon: Icon(Icons.dashboard_customize),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map),
                  label: Text('Map'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart),
                  label: Text('Analytics'),
                ),
              ],
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: pages[_selectedIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              selectedItemColor: const Color(0xFF059669),
              unselectedItemColor: const Color(0xFF64748B),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_customize_outlined),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map_outlined),
                  label: 'Map',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_outlined),
                  label: 'Analytics',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildDashboardHub(String userName) {
    return _statsLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _fetchDashboardStats,
            color: const Color(0xFF059669),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Welcome, $userName',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Real-time metrics and community actions for Pokhara Smart City.',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final gridCols = constraints.maxWidth > 800 ? 4 : 2;
                    return GridView.count(
                      crossAxisCount: gridCols,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      childAspectRatio: 1.4,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatCard(
                          'Total Waste Bins',
                          _totalBins.toString(),
                          Icons.delete_outline,
                          Colors.teal,
                        ),
                        _buildStatCard(
                          'Critical Full Bins',
                          _fullBins.toString(),
                          Icons.report_gmailerrorred_rounded,
                          Colors.red,
                        ),
                        _buildStatCard(
                          'Pending Requests',
                          _pendingRequests.toString(),
                          Icons.add_location_outlined,
                          Colors.amber,
                        ),
                        _buildStatCard(
                          'Waste Incidents',
                          _unresolvedReports.toString(),
                          Icons.warning_amber_outlined,
                          Colors.orange,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => RequestBinForm(),
                          ).then((_) => _fetchDashboardStats());
                        },
                        icon: const Icon(Icons.add_location_alt_rounded),
                        label: const Text('Request New Bin Setup'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => ReportFohor(),
                          ).then((_) => _fetchDashboardStats());
                        },
                        icon: const Icon(Icons.report_gmailerrorred_rounded),
                        label: const Text('Report Waste Issue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_fullBins > 0) ...[
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '$_fullBins bin(s) currently at full capacity and need collection.',
                            style: TextStyle(color: Colors.red.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
  }

  Widget _buildStatCard(
    String title,
    String val,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Icon(icon, color: color, size: 24),
              ],
            ),
            Text(
              val,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoogleLoginPage extends StatelessWidget {
  final Future<void> Function(String email, String name, String photoUrl)
      onLogin;

  const GoogleLoginPage({super.key, required this.onLogin});

  void _showAccountChooser(BuildContext context) {
    final mockAccounts = [
      {
        'name': 'Community User',
        'email': 'user@sankalan.gov.np',
        'photo': 'https://api.dicebear.com/7.x/avataaars/png?seed=user',
      },
      {
        'name': 'Field Reporter',
        'email': 'reporter@sankalan.org',
        'photo': 'https://api.dicebear.com/7.x/avataaars/png?seed=reporter',
      },
    ];

    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final emailController = TextEditingController();

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Sign in to Sankalan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...mockAccounts.map((account) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(account['photo']!),
                    ),
                    title: Text(account['name']!),
                    subtitle: Text(account['email']!),
                    onTap: () {
                      Navigator.pop(context);
                      onLogin(
                        account['email']!,
                        account['name']!,
                        account['photo']!,
                      );
                    },
                  );
                }),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_add_alt_1_outlined),
                  ),
                  title: const Text('Use another account'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Enter your details'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                              ),
                            ),
                            TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (nameController.text.isNotEmpty &&
                                  emailController.text.isNotEmpty) {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                onLogin(
                                  emailController.text.trim(),
                                  nameController.text.trim(),
                                  'https://api.dicebear.com/7.x/avataaars/png?seed=${emailController.text}',
                                );
                              }
                            },
                            child: const Text('Sign In'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.recycling_rounded,
                  size: 56,
                  color: Color(0xFF059669),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to Sankalan',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sign in to view waste bins, report issues, and track community analytics.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                onPressed: () => _showAccountChooser(context),
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
