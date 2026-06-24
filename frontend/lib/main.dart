import 'package:flutter/material.dart';
import 'package:trash_map/pages/analyticspage.dart';
import 'package:trash_map/pages/mappage.dart';
import 'package:trash_map/pages/admin_console_page.dart';
import 'package:trash_map/requestbin/user_form.dart';
import 'package:trash_map/fohor/report_form.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trash_map/api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sankalan - Waste Management Console',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF059669), // Emerald primary
          primary: const Color(0xFF059669),
          secondary: const Color(0xFF0F172A), // Slate secondary
          surface: const Color(0xFFF8FAFC),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF0F172A), // Sleek Slate header
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: const Color(0xFF0F172A), // Dark side rail
          indicatorColor: const Color(0xFF059669).withOpacity(0.24),
          selectedIconTheme: const IconThemeData(color: Color(0xFF34D399)),
          unselectedIconTheme: const IconThemeData(
            color: Color(0xFF64748B),
          ), // Slate-500 equivalent
          selectedLabelTextStyle: const TextStyle(
            color: Color(0xFF34D399),
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelTextStyle: const TextStyle(color: Color(0xFF64748B)),
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
  double? _targetLat;
  double? _targetLng;

  // Dashboard Stats
  int _totalBins = 0;
  int _fullBins = 0;
  int _pendingRequests = 0;
  int _unresolvedReports = 0;
  List<dynamic> _recentAlerts = [];
  bool _statsLoading = false;

  // Auth State
  bool _isLoggedIn = false;
  bool _isVerified = false;
  String? _currentUserEmail;
  String? _currentUserName;
  String? _currentUserPhoto;

  Future<void> _loginWithGoogle(
    String email,
    String name,
    String photoUrl,
  ) async {
    try {
      final response = await http.post(
        apiUri('auth/google-login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'name': name,
          'google_id': email.hashCode.toString(),
          'photo_url': photoUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = data['user'];
        setState(() {
          _isLoggedIn = true;
          _isVerified = user['is_verified'] ?? false;
          _currentUserEmail = user['email'];
          _currentUserName = user['name'];
          _currentUserPhoto = user['photo_url'];

          AuthManager.isLoggedIn = _isLoggedIn;
          AuthManager.isVerified = _isVerified;
          AuthManager.currentUserEmail = _currentUserEmail;
          AuthManager.currentUserName = _currentUserName;
          AuthManager.currentUserPhoto = _currentUserPhoto;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isVerified
                  ? "Welcome, $_currentUserName! Authenticated successfully."
                  : "Signed in as $_currentUserName. Pending administrator verification.",
            ),
            backgroundColor: _isVerified
                ? const Color(0xFF059669)
                : Colors.orange,
          ),
        );
      } else {
        throw Exception(
          "Failed to authenticate with backend: ${response.body}",
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Authentication error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _checkVerification() async {
    if (_currentUserEmail == null) return;
    try {
      final response = await http.post(
        apiUri('auth/google-login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _currentUserEmail,
          'name': _currentUserName,
          'google_id': _currentUserEmail.hashCode.toString(),
          'photo_url': _currentUserPhoto,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = data['user'];
        setState(() {
          _isVerified = user['is_verified'] ?? false;

          AuthManager.isVerified = _isVerified;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isVerified
                  ? "Verification complete! Welcome to the Admin Console."
                  : "Verification status is still pending approval.",
            ),
            backgroundColor: _isVerified
                ? const Color(0xFF059669)
                : Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error checking verification: $e");
    }
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
      _isVerified = false;
      _currentUserEmail = null;
      _currentUserName = null;
      _currentUserPhoto = null;
      _selectedIndex = 0; // Go back to dashboard

      AuthManager.isLoggedIn = false;
      AuthManager.isVerified = false;
      AuthManager.currentUserEmail = null;
      AuthManager.currentUserName = null;
      AuthManager.currentUserPhoto = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Logged out successfully."),
        backgroundColor: Color(0xFF0F172A),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchDashboardStats();
  }

  Future<void> _fetchDashboardStats() async {
    setState(() => _statsLoading = true);
    try {
      final analyticsResponse = await http.get(
        Uri.parse(apiPath('waste-bin-analytics/')),
      );
      final requestsResponse = await http.get(Uri.parse(apiPath('requests/')));
      final reportsResponse = await http.get(
        Uri.parse(apiPath('report-waste/')),
      );
      final alertsResponse = await http.get(
        Uri.parse(apiPath('admin-notifications/')),
      );

      if (mounted) {
        setState(() {
          if (analyticsResponse.statusCode == 200) {
            final data = json.decode(analyticsResponse.body);
            _totalBins = data['total_bins'] ?? 0;
            _fullBins = data['full_bins'] ?? 0;
          }
          if (requestsResponse.statusCode == 200) {
            final List data = json.decode(requestsResponse.body);
            _pendingRequests = data.length;
          }
          if (reportsResponse.statusCode == 200) {
            final List data = json.decode(reportsResponse.body);
            _unresolvedReports = data.length;
          }
          if (alertsResponse.statusCode == 200) {
            _recentAlerts = json.decode(alertsResponse.body);
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading dashboard stats: $e");
    } finally {
      if (mounted) {
        setState(() => _statsLoading = false);
      }
    }
  }

  void _navigateToMapAndLocate(double lat, double lng) {
    setState(() {
      _targetLat = lat;
      _targetLng = lng;
      _selectedIndex = 1; // Map View
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    final List<Widget> pages = [
      _buildDashboardHub(),
      MapScreen(targetLat: _targetLat, targetLng: _targetLng),
      _isLoggedIn
          ? (_isVerified
                ? AdminConsolePage(onLocateBin: _navigateToMapAndLocate)
                : PendingVerificationPage(
                    email: _currentUserEmail ?? "",
                    name: _currentUserName ?? "",
                    onCheckStatus: _checkVerification,
                    onSignOut: _logout,
                  ))
          : GoogleLoginPage(onLogin: _loginWithGoogle),
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
                  'Waste Collection Administration',
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
          if (_isLoggedIn) ...[
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'logout') {
                  _logout();
                }
              },
              offset: const Offset(0, 48),
              icon: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isVerified
                          ? const Color(0xFF059669)
                          : Colors.amber,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: const Color(0xFF059669),
                        backgroundImage: NetworkImage(
                          _currentUserPhoto ??
                              'https://www.gravatar.com/avatar/',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _currentUserName ?? "Admin",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isVerified
                            ? Icons.verified_user
                            : Icons.hourglass_empty,
                        color: _isVerified
                            ? const Color(0xFF34D399)
                            : Colors.amber,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentUserName ?? "User",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        _currentUserEmail ?? "",
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
                      Text("Sign Out", style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
          ],
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchDashboardStats,
            )
          else ...[
            TextButton.icon(
              onPressed: _fetchDashboardStats,
              icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
              label: const Text(
                "Refresh console",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ],
      ),
      body: Row(
        children: [
          if (!isMobile)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() => _selectedIndex = index);
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_customize_outlined),
                  selectedIcon: Icon(Icons.dashboard_customize),
                  label: Text('Console'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map),
                  label: Text('Map View'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.admin_panel_settings_outlined),
                  selectedIcon: Icon(Icons.admin_panel_settings),
                  label: Text('Admin'),
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
                  label: 'Console',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map_outlined),
                  label: 'Map',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.admin_panel_settings_outlined),
                  label: 'Admin',
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

  Widget _buildDashboardHub() {
    return _statsLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _fetchDashboardStats,
            color: const Color(0xFF059669),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Top welcome banner
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome Back, Administrator",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Real-time metrics and operations hub for Pokhara Smart City.",
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Grid cards section
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
                          "Total Waste Bins",
                          _totalBins.toString(),
                          Icons.delete_outline,
                          Colors.teal,
                        ),
                        _buildStatCard(
                          "Critical Full Bins",
                          _fullBins.toString(),
                          Icons.report_gmailerrorred_rounded,
                          Colors.red,
                        ),
                        _buildStatCard(
                          "Pending Requests",
                          _pendingRequests.toString(),
                          Icons.add_location_outlined,
                          Colors.amber,
                        ),
                        _buildStatCard(
                          "Waste Incidents",
                          _unresolvedReports.toString(),
                          Icons.warning_amber_outlined,
                          Colors.orange,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Quick operational actions
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
                        label: const Text("Request New Bin Setup"),
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
                        label: const Text("Report Waste Issue"),
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
                const SizedBox(height: 28),

                // Alerts feed
                const Text(
                  "Recent System Alerts Feed",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                _recentAlerts.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Center(
                          child: Text(
                            "All systems functional. No critical alerts reported.",
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recentAlerts.length > 5
                            ? 5
                            : _recentAlerts.length,
                        itemBuilder: (context, index) {
                          final alert = _recentAlerts[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: 0,
                            color: Colors.red.shade50.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: Colors.red.shade200,
                                width: 0.5,
                              ),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.notification_important,
                                color: Colors.red,
                              ),
                              title: Text(
                                "Bin #${alert['waste_bin']} needs collection immediately",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                "Status: Full | Reported at: ${alert['date_reported'] != null ? alert['date_reported'].substring(11, 16) : ''}",
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
  }

  Widget _buildStatCard(String title, String val, IconData icon, Color color) {
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
  final Function(String email, String name, String photoUrl) onLogin;

  const GoogleLoginPage({super.key, required this.onLogin});

  void _showAccountChooser(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final List<Map<String, String>> mockAccounts = [
          {
            'name': 'Sankalan Admin',
            'email': 'admin@sankalan.gov.np',
            'photo': 'https://api.dicebear.com/7.x/bottts/png?seed=admin',
          },
          {
            'name': 'District Supervisor',
            'email': 'supervisor@sankalan.org',
            'photo': 'https://api.dicebear.com/7.x/bottts/png?seed=supervisor',
          },
          {
            'name': 'Field Operator 1',
            'email': 'operator1@sankalan.gov.np',
            'photo': 'https://api.dicebear.com/7.x/bottts/png?seed=op1',
          },
        ];

        final TextEditingController nameController = TextEditingController();
        final TextEditingController emailController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Column(
                children: [
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                    height: 36,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "G",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Choose a Google account",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "to continue to Sankalan Admin Console",
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Divider(),
                      ...mockAccounts.map((account) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey.shade100,
                            backgroundImage: NetworkImage(account['photo']!),
                          ),
                          title: Text(
                            account['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            account['email']!,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            onLogin(
                              account['email']!,
                              account['name']!,
                              account['photo']!,
                            );
                          },
                        );
                      }).toList(),
                      const Divider(),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFF1F5F9),
                          child: Icon(
                            Icons.person_add_alt_1_outlined,
                            color: Color(0xFF475569),
                          ),
                        ),
                        title: const Text(
                          "Use another account",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF475569),
                          ),
                        ),
                        onTap: () {
                          // Show input fields for custom account
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Enter Google Credentials"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                      labelText: "Full Name",
                                    ),
                                  ),
                                  TextField(
                                    controller: emailController,
                                    decoration: const InputDecoration(
                                      labelText: "Google Email",
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (nameController.text.isNotEmpty &&
                                        emailController.text.isNotEmpty) {
                                      Navigator.pop(
                                        context,
                                      ); // close credentials dialog
                                      Navigator.pop(
                                        context,
                                      ); // close chooser dialog
                                      onLogin(
                                        emailController.text.trim(),
                                        nameController.text.trim(),
                                        'https://api.dicebear.com/7.x/bottts/png?seed=${emailController.text}',
                                      );
                                    }
                                  },
                                  child: const Text("Sign In"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                size: 56,
                color: Color(0xFF059669),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Sankalan Admin Console",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Access is restricted to authorized operators. Please authenticate using your corporate Google Workspace account.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              onPressed: () => _showAccountChooser(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F172A),
                elevation: 0,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                    height: 20,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "G",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Sign in with Google",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PendingVerificationPage extends StatelessWidget {
  final String email;
  final String name;
  final VoidCallback onCheckStatus;
  final VoidCallback onSignOut;

  const PendingVerificationPage({
    super.key,
    required this.email,
    required this.name,
    required this.onCheckStatus,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hourglass_empty_rounded,
                size: 56,
                color: Colors.amber.shade700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Verification Pending",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.amber.shade800,
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.5,
                  fontFamily: 'Outfit',
                ),
                children: [
                  const TextSpan(text: "Hello "),
                  TextSpan(
                    text: name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const TextSpan(text: " ("),
                  TextSpan(
                    text: email,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const TextSpan(
                    text:
                        "). Your administrator request is pending approval. A backend administrator must verify your account in the Django Admin Console before access is granted.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onCheckStatus,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("Check Verification Status"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onSignOut,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text("Sign Out"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 1.2),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthManager {
  static bool isLoggedIn = false;
  static bool isVerified = false;
  static String? currentUserEmail;
  static String? currentUserName;
  static String? currentUserPhoto;
}
