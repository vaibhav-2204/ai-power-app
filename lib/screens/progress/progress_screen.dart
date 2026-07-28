import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/gradient_app_bar.dart';
import '../../models/progress_entry.dart';
import '../../services/gemini_service.dart';
import '../../services/pref_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<ProgressEntry> _entries = [];
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isAnalyzing = false;
  String? _analysis;

  @override
  void initState() {
    super.initState();
    _entries = PrefService.getProgressEntries();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addEntry() async {
    final weight = double.tryParse(_weightController.text.trim());
    if (weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid weight',
              style: GoogleFonts.poppins()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final entry = ProgressEntry(
      date: DateTime.now(),
      weight: weight,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    setState(() {
      _entries.add(entry);
      _weightController.clear();
      _notesController.clear();
    });

    await PrefService.saveProgressEntries(_entries);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _analyzeProgress() async {
    if (_entries.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Add at least 2 entries to analyze',
              style: GoogleFonts.poppins()),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysis = null;
    });

    final dateFormat = DateFormat('MMM dd');
    final buffer = StringBuffer();
    for (int i = 0; i < _entries.length; i++) {
      buffer.writeln(
          '${dateFormat.format(_entries[i].date)}: ${_entries[i].weight}kg${_entries[i].notes != null ? ' (${_entries[i].notes})' : ''}');
    }

    final result = await GeminiService.analyzeProgress(buffer.toString());

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _analysis = result;
      });
    }
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.bgCardLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Log Weight',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _weightController,
              labelText: 'Weight (kg)',
              hintText: 'e.g. 72.5',
              prefixIcon: Icons.monitor_weight_outlined,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _notesController,
              labelText: 'Notes (optional)',
              hintText: 'How are you feeling?',
              prefixIcon: Icons.note_outlined,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Add Entry',
              icon: Icons.add_rounded,
              onPressed: _addEntry,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Progress Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.accent),
            onPressed: _showAddDialog,
            tooltip: 'Log Weight',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats summary
              if (_entries.isNotEmpty)
                FadeInDown(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Current',
                          '${_entries.last.weight} kg',
                          Icons.monitor_weight_outlined,
                          AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Start',
                          '${_entries.first.weight} kg',
                          Icons.flag_outlined,
                          AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Change',
                          '${(_entries.last.weight - _entries.first.weight).toStringAsFixed(1)} kg',
                          Icons.trending_down_rounded,
                          _entries.last.weight <= _entries.first.weight
                              ? AppColors.accentGreen
                              : AppColors.accentOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Weight chart
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.show_chart_rounded,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Weight Trend',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _entries.isEmpty
                          ? SizedBox(
                              height: 200,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.insert_chart_outlined_rounded,
                                        size: 48,
                                        color:
                                            AppColors.textHint.withValues(alpha: 0.5)),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No data yet.\nTap + to log your weight!',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: AppColors.textHint,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 220,
                              child: _buildChart(),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // AI Analysis button
              if (_entries.length >= 2) ...[
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: CustomButton(
                    text: 'AI Progress Analysis',
                    icon: Icons.auto_awesome_rounded,
                    isLoading: _isAnalyzing,
                    onPressed: _isAnalyzing ? null : _analyzeProgress,
                    gradient: AppColors.accentGradient,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Analysis result
              if (_isAnalyzing)
                Shimmer.fromColors(
                  baseColor: AppColors.bgCard,
                  highlightColor: AppColors.bgCardLight,
                  child: Column(
                    children: List.generate(
                      4,
                      (i) => Container(
                        height: 18,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                )
              else if (_analysis != null)
                FadeIn(
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.insights_rounded,
                                color: AppColors.accentGreen, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'AI Analysis',
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
                          _analysis!,
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

              // History list
              if (_entries.isNotEmpty) ...[
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    'History',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(_entries.length, (i) {
                  final entry = _entries[_entries.length - 1 - i];
                  return FadeInUp(
                    delay: Duration(milliseconds: 350 + (i * 50)),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.bgCardLight.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.monitor_weight_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${entry.weight} kg',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (entry.notes != null)
                                  Text(
                                    entry.notes!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd').format(entry.date),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return CustomCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final spots = _entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight);
    }).toList();

    final minY =
        _entries.map((e) => e.weight).reduce((a, b) => a < b ? a : b) - 2;
    final maxY =
        _entries.map((e) => e.weight).reduce((a, b) => a > b ? a : b) + 2;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.bgCardLight.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= _entries.length) {
                  return const SizedBox();
                }
                if (_entries.length > 7 && index % 2 != 0) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('dd/MM').format(_entries[index].date),
                    style: GoogleFonts.poppins(
                        fontSize: 10, color: AppColors.textHint),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: GoogleFonts.poppins(
                      fontSize: 10, color: AppColors.textHint),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: AppColors.primaryGradient,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)} kg',
                  GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
