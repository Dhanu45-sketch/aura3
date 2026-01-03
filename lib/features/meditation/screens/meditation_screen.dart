import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/meditation_program.dart';
import '../providers/meditation_provider.dart';
import 'meditation_session_screen.dart';

class MeditationScreen extends StatelessWidget {
  const MeditationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundDark,
              AppColors.secondaryGlass.withOpacity(0.1),
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<MeditationProvider>(
            builder: (context, meditationProvider, _) {
              if (meditationProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (meditationProvider.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        meditationProvider.errorMessage!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final programs = meditationProvider.programs;

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    backgroundColor: Colors.transparent,
                    title: const Text('Meditation'),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildWelcomeCard(context),
                        const SizedBox(height: 24),
                        Text(
                          'Programs',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                      ]),
                    ),
                  ),
                  // RESPONSIVE: Grid or List based on orientation
                  _buildResponsiveProgramCards(context, programs, meditationProvider),
                  const SliverPadding(
                    padding: EdgeInsets.only(bottom: 100),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // RESPONSIVE: Build grid for landscape, list for portrait
  Widget _buildResponsiveProgramCards(
      BuildContext context,
      List<MeditationProgram> programs,
      MeditationProvider provider,
      ) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      // LANDSCAPE: 2-column grid
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3, // Slightly wider cards
          ),
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              return _buildProgramCard(
                context,
                programs[index],
                provider,
                index,
              );
            },
            childCount: programs.length,
          ),
        ),
      );
    } else {
      // PORTRAIT: Single column list
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildProgramCard(
                  context,
                  programs[index],
                  provider,
                  index,
                ),
              );
            },
            childCount: programs.length,
          ),
        ),
      );
    }
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return GlassContainer(
      gradient: LinearGradient(
        colors: [
          AppColors.secondaryGlass.withOpacity(0.3),
          AppColors.tertiaryGlass.withOpacity(0.3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryGlass.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.self_improvement_rounded,
                  size: 32,
                  color: AppColors.secondaryGlass,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Your Journey',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'Choose a program below',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildProgramCard(
      BuildContext context,
      MeditationProgram program,
      MeditationProvider provider,
      int index,
      ) {
    final completionPercentage = provider.getCompletionPercentage(program.id);
    final completedDay = provider.getCompletedDay(program.id);
    final isCompleted = provider.isProgramCompleted(program.id);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // RESPONSIVE: Calculate max height for scrollable content
    final screenHeight = MediaQuery.of(context).size.height;
    final maxContentHeight = isLandscape
        ? screenHeight * 0.35  // 35% in landscape
        : screenHeight * 0.45; // 45% in portrait

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MeditationSessionScreen(program: program),
          ),
        );
      },
      child: GlassContainer(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxContentHeight,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Level badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getLevelColor(program.level).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getLevelColor(program.level),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        program.level.toUpperCase(),
                        style: TextStyle(
                          color: _getLevelColor(program.level),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Days badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGlass.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: AppColors.primaryGlass,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${program.totalDays} days',
                            style: const TextStyle(
                              color: AppColors.primaryGlass,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  program.title,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  program.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: isLandscape ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                // Progress bar
                if (completedDay > 0) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: completionPercentage,
                            backgroundColor: AppColors.borderGlass,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isCompleted
                                  ? Colors.green
                                  : AppColors.secondaryGlass,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isCompleted
                            ? 'Completed!'
                            : 'Day $completedDay/${program.totalDays}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isCompleted
                              ? Colors.green
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                // Action button
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  MeditationSessionScreen(program: program),
                            ),
                          );
                        },
                        icon: Icon(
                          isCompleted
                              ? Icons.replay_rounded
                              : completedDay > 0
                              ? Icons.play_arrow_rounded
                              : Icons.start_rounded,
                          size: 20,
                        ),
                        label: Text(
                          isCompleted
                              ? 'Restart'
                              : completedDay > 0
                              ? 'Continue'
                              : 'Start',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryGlass,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ).animate(delay: (100 * index).ms).fadeIn(duration: 600.ms).slideX(
        begin: 0.2,
        end: 0,
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.blue;
      case 'advanced':
        return Colors.purple;
      default:
        return AppColors.textSecondary;
    }
  }
}