import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/supabase/supabase_client.dart';
import 'providers/auth_provider.dart';
import 'providers/student_provider.dart';
import 'providers/staff_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/complaint_provider.dart';
import 'providers/lost_found_provider.dart';
import 'providers/food_provider.dart';
import 'providers/token_provider.dart';
import 'providers/timetable_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/student/student_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase configuration gracefully with local storage fallback
  await SupabaseConfig.initialize();

  runApp(const Campus360App());
}

class Campus360App extends StatelessWidget {
  const Campus360App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
        ChangeNotifierProvider(create: (_) => LostFoundProvider()),
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        ChangeNotifierProvider(create: (_) => TokenProvider()),
        ChangeNotifierProvider(create: (_) => TimetableProvider()),
      ],
      child: MaterialApp(
        title: 'Campus360',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const InitializerScreen(),
      ),
    );
  }
}

class InitializerScreen extends StatefulWidget {
  const InitializerScreen({super.key});

  @override
  State<InitializerScreen> createState() => _InitializerScreenState();
}

class _InitializerScreenState extends State<InitializerScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.checkExistingSession();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Launching Campus360...',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (auth.isAdmin) {
      return const AdminDashboardScreen();
    } else if (auth.isStudent) {
      return const StudentDashboardScreen();
    }

    return const LoginScreen();
  }
}
