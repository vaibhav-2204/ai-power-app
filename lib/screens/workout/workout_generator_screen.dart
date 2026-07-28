import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/gradient_app_bar.dart';
import '../../services/gemini_service.dart';
import '../../services/pref_service.dart';

class WorkoutGeneratorScreen extends StatefulWidget {
  const WorkoutGeneratorScreen({super.key});

  @override
  State<WorkoutGeneratorScreen> createState() => _WorkoutGeneratorScreenState();
}

class _WorkoutGeneratorScreenState extends State<WorkoutGeneratorScreen> {
  bool _isLoading = false;
  String? _workoutPlan;
  String _selectedGoal = 'Muscle Gain';
  String _selectedLevel = 'Beginner';
  int _daysPerWeek = 5;

  final List<String> _goals = [
    'Fat Loss',
    'Muscle Gain',
    'Strength',
    'Endurance',
  ];

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _loadUserDefaults();
    _workoutPlan = PrefService.getLastWorkoutPlan();
  }

  void _loadUserDefaults() {
    final user = PrefService.getCurrentUser();
    if (user != null) {
      setState(() {
        _selectedGoal = user.goal ?? _selectedGoal;
        _selectedLevel = user.level ?? _selectedLevel;
        _daysPerWeek = user.daysPerWeek ?? _daysPerWeek;
      });
    }
  }

  Future<void> _generatePlan() async {
    final user = PrefService.getCurrentUser();
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _workoutPlan = null;
    });

    final plan = await GeminiService.generateWorkoutPlan(
      age: user.age ?? 25,
      weight: user.weight ?? 70,
      height: user.height ?? 170,
      goal: _selectedGoal,
      level: _selectedLevel,
      daysPerWeek: _daysPerWeek,
    );

    await PrefService.saveLastWorkoutPlan(plan);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _workoutPlan = plan;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'AI Workout Generator'),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goal Selection
              FadeInDown(
                child: CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        Icons.flag_rounded,
                        'Fitness Goal',
                        AppColors.accentGreen,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _goals.map((goal) {
                          final isSelected = _selectedGoal == goal;
                          return _buildChip(goal, isSelected, () {
                            setState(() => _selectedGoal = goal);
                          });
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Level Selection
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        Icons.speed_rounded,
                        'Level',
                        AppColors.accent,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: _levels.map((level) {
                          final isSelected = _selectedLevel == level;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedLevel = level),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? AppColors.primaryGradient
                                      : null,
                                  color:
                                      isSelected ? null : AppColors.bgCardLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  level,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Days per week
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: CustomCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildSectionHeader(
                            Icons.calendar_today_rounded,
                            'Days/Week',
                            AppColors.accentOrange,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$_daysPerWeek',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.bgCardLight,
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primary.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: _daysPerWeek.toDouble(),
                          min: 1,
                          max: 7,
                          divisions: 6,
                          onChanged: (v) =>
                              setState(() => _daysPerWeek = v.round()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Generate Button
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: CustomButton(
                  text: 'Generate Workout Plan',
                  icon: Icons.auto_awesome_rounded,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _generatePlan,
                ),
              ),
              const SizedBox(height: 24),

              // Result
              if (_isLoading)
                _buildShimmerLoading()
              else if (_workoutPlan != null)
                FadeIn(
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.fitness_center_rounded,
                                color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Your Workout Plan',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SelectableText(
                          _workoutPlan!,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.6,
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
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: AppColors.bgCard,
      highlightColor: AppColors.bgCardLight,
      child: Column(
        children: List.generate(
          5,
          (i) => Container(
            height: 20,
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
