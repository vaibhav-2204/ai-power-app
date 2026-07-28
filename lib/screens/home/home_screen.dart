import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_card.dart';
import '../../services/pref_service.dart';
import '../auth/login_screen.dart';
import '../profile/profile_setup_screen.dart';
import '../workout/workout_generator_screen.dart';
import '../diet/diet_generator_screen.dart';
import '../chatbot/chatbot_screen.dart';
import '../progress/progress_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _DashboardTab(),
    WorkoutGeneratorScreen(),
    DietGeneratorScreen(),
    ChatbotScreen(),
    ProgressScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          border: Border(
            top: BorderSide(
              color: AppColors.bgCardLight.withValues(alpha: 0.3),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home'),
                _buildNavItem(1, Icons.fitness_center_rounded, 'Workout'),
                _buildNavItem(2, Icons.restaurant_menu_rounded, 'Diet'),
                _buildNavItem(3, Icons.smart_toy_rounded, 'Chat'),
                _buildNavItem(4, Icons.insert_chart_rounded, 'Progress'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textHint,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard Home Tab ───
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final user = PrefService.getCurrentUser();
    final userName = user?.name ?? 'Champ';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                FadeInDown(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello,',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              userName,
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton(
                        icon: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              userName[0].toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        color: AppColors.bgCard,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            child: ListTile(
                              leading: const Icon(Icons.person_outline,
                                  color: AppColors.textSecondary, size: 20),
                              title: Text('Edit Profile',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppColors.textPrimary)),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onTap: () {
                              Future.delayed(
                                const Duration(milliseconds: 200),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProfileSetupScreen(),
                                  ),
                                ),
                              );
                            },
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              leading: const Icon(Icons.logout_rounded,
                                  color: AppColors.error, size: 20),
                              title: Text('Logout',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14, color: AppColors.error)),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onTap: () async {
                              await PrefService.logout();
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Quick Stats
                if (user != null && user.profileCompleted)
                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildQuickStat(
                            Icons.monitor_weight_outlined,
                            '${user.weight ?? '-'} kg',
                            'Weight',
                            AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickStat(
                            Icons.height_rounded,
                            '${user.height ?? '-'} cm',
                            'Height',
                            AppColors.accentGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickStat(
                            Icons.flag_rounded,
                            user.goal ?? '-',
                            'Goal',
                            AppColors.accentOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 28),

                // Motivational Banner
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            color: Colors.white70, size: 28),
                        const SizedBox(height: 12),
                        Text(
                          'AI-Powered Fitness',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Get personalized workout & diet plans\ngenerated by Gemini AI, just for you.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Feature Grid
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    'AI Features',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.1,
                  children: [
                    FadeInUp(
                      delay: const Duration(milliseconds: 350),
                      child: _buildFeatureCard(
                        context,
                        Icons.fitness_center_rounded,
                        'Workout\nGenerator',
                        'AI workout plans',
                        AppColors.primary,
                        const WorkoutGeneratorScreen(),
                      ),
                    ),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: _buildFeatureCard(
                        context,
                        Icons.restaurant_menu_rounded,
                        'Diet\nGenerator',
                        'Personalized meals',
                        AppColors.accentGreen,
                        const DietGeneratorScreen(),
                      ),
                    ),
                    FadeInUp(
                      delay: const Duration(milliseconds: 450),
                      child: _buildFeatureCard(
                        context,
                        Icons.smart_toy_rounded,
                        'FitBot\nChat',
                        'Ask anything',
                        AppColors.accent,
                        const ChatbotScreen(),
                      ),
                    ),
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: _buildFeatureCard(
                        context,
                        Icons.insert_chart_rounded,
                        'Progress\nDashboard',
                        'Track & analyze',
                        AppColors.accentOrange,
                        const ProgressScreen(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Fitness tip
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: CustomCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.accentPink.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.lightbulb_outline_rounded,
                              color: AppColors.accentPink, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Tip',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Consistency beats intensity. Show up every day and results will follow! 🏆',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(
      IconData icon, String value, String label, Color color) {
    return CustomCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title,
      String subtitle, Color color, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      ),
      child: CustomCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
