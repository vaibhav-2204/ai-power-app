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

class DietGeneratorScreen extends StatefulWidget {
  const DietGeneratorScreen({super.key});

  @override
  State<DietGeneratorScreen> createState() => _DietGeneratorScreenState();
}

class _DietGeneratorScreenState extends State<DietGeneratorScreen> {
  bool _isLoading = false;
  String? _dietPlan;
  String _selectedDietType = 'Vegetarian';
  String _selectedGoal = 'Muscle Gain';
  String _selectedCuisine = 'Indian';
  int _calories = 2500;

  final List<String> _dietTypes = [
    'Vegetarian',
    'Non-Vegetarian',
    'Vegan',
    'Eggetarian',
  ];

  final List<String> _goals = [
    'Fat Loss',
    'Muscle Gain',
    'Maintenance',
    'Lean Bulk',
  ];

  final List<String> _cuisines = [
    'Indian',
    'Mediterranean',
    'American',
    'Asian',
    'Mixed',
  ];

  @override
  void initState() {
    super.initState();
    _dietPlan = PrefService.getLastDietPlan();
    final user = PrefService.getCurrentUser();
    if (user != null) {
      _selectedGoal = user.goal ?? _selectedGoal;
    }
  }

  Future<void> _generatePlan() async {
    setState(() {
      _isLoading = true;
      _dietPlan = null;
    });

    final plan = await GeminiService.generateDietPlan(
      dietType: _selectedDietType,
      goal: _selectedGoal,
      calories: _calories,
      cuisine: _selectedCuisine,
    );

    await PrefService.saveLastDietPlan(plan);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _dietPlan = plan;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'AI Diet Generator'),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Diet Type
              FadeInDown(
                child: CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        Icons.restaurant_rounded,
                        'Diet Type',
                        AppColors.accentGreen,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _dietTypes.map((type) {
                          final isSelected = _selectedDietType == type;
                          return _buildChip(type, isSelected, () {
                            setState(() => _selectedDietType = type);
                          });
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Goal
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        Icons.flag_rounded,
                        'Goal',
                        AppColors.accent,
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

              // Cuisine
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        Icons.public_rounded,
                        'Cuisine Preference',
                        AppColors.accentPink,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _cuisines.map((cuisine) {
                          final isSelected = _selectedCuisine == cuisine;
                          return _buildChip(cuisine, isSelected, () {
                            setState(() => _selectedCuisine = cuisine);
                          });
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Calories
              FadeInDown(
                delay: const Duration(milliseconds: 300),
                child: CustomCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildSectionHeader(
                            Icons.local_fire_department_rounded,
                            'Daily Calories',
                            AppColors.accentOrange,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: AppColors.warmGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$_calories',
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
                          activeTrackColor: AppColors.accentOrange,
                          inactiveTrackColor: AppColors.bgCardLight,
                          thumbColor: AppColors.accentOrange,
                          overlayColor:
                              AppColors.accentOrange.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: _calories.toDouble(),
                          min: 1200,
                          max: 4000,
                          divisions: 28,
                          onChanged: (v) =>
                              setState(() => _calories = v.round()),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1200 cal',
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: AppColors.textHint)),
                          Text('4000 cal',
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: AppColors.textHint)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Generate Button
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: CustomButton(
                  text: 'Generate Diet Plan',
                  icon: Icons.auto_awesome_rounded,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _generatePlan,
                  gradient: AppColors.accentGradient,
                ),
              ),
              const SizedBox(height: 24),

              // Result
              if (_isLoading)
                _buildShimmerLoading()
              else if (_dietPlan != null)
                FadeIn(
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.restaurant_menu_rounded,
                                color: AppColors.accentGreen, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Your Diet Plan',
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
                          _dietPlan!,
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
