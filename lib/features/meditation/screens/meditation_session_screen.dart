import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/meditation_program.dart';
import '../providers/meditation_provider.dart';
import '../../sounds/providers/sound_provider.dart';
import '../../player/screens/player_screen.dart';

class MeditationSessionScreen extends StatelessWidget {
  final MeditationProgram program;

  const MeditationSessionScreen({
    super.key,
    required this.program,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(program.title),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundDark,
              AppColors.secondaryGlass.withOpacity(0.2),
              AppColors.tertiaryGlass.withOpacity(0.2),
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<MeditationProvider>(
            builder: (context, meditationProvider, _) {
              final completedDay = meditationProvider.getCompletedDay(program.id);
              final isCompleted = meditationProvider.isProgramCompleted(program.id);

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildProgramHeader(context, completedDay, isCompleted),
                        const SizedBox(height: 24),
                        Text(
                          'Sessions',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                      ]),
                    ),
                  ),
                  // RESPONSIVE: Grid or List based on orientation
                  _buildResponsiveSessionCards(
                    context,
                    completedDay,
                    meditationProvider,
                    isLandscape,
                  ),
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
  Widget _buildResponsiveSessionCards(
      BuildContext context,
      int completedDay,
      MeditationProvider provider,
      bool isLandscape,
      ) {
    if (isLandscape) {
      // LANDSCAPE: 2-column grid
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.0, // Wider cards in landscape
          ),
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final session = program.sessions[index];
              return _buildSessionCard(
                context,
                session,
                completedDay,
                provider,
              );
            },
            childCount: program.sessions.length,
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
              final session = program.sessions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSessionCard(
                  context,
                  session,
                  completedDay,
                  provider,
                ),
              );
            },
            childCount: program.sessions.length,
          ),
        ),
      );
    }
  }

  Widget _buildProgramHeader(
      BuildContext context,
      int completedDay,
      bool isCompleted,
      ) {
    final completionPercentage = (completedDay / program.totalDays).clamp(0.0, 1.0);

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
          Text(
            program.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                '${program.totalDays} Days Program',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
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
            ],
          ),
          if (completedDay > 0) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            isCompleted
                                ? 'Completed!'
                                : '$completedDay/${program.totalDays} days',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isCompleted
                                  ? Colors.green
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
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
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildSessionCard(
      BuildContext context,
      MeditationSession session,
      int completedDay,
      MeditationProvider provider,
      ) {
    final isCompleted = session.day <= completedDay;
    final isNext = session.day == completedDay + 1;
    final isLocked = session.day > completedDay + 1;

    return GestureDetector(
      onTap: isLocked
          ? null
          : () => _showSessionDetail(context, session, provider),
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
        child: GlassContainer(
          color: isCompleted
              ? Colors.green.withOpacity(0.1)
              : isNext
              ? AppColors.secondaryGlass.withOpacity(0.1)
              : null,
          border: isNext
              ? Border.all(
            color: AppColors.secondaryGlass,
            width: 2,
          )
              : null,
          child: Row(
            children: [
              // Day circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Colors.green
                      : isNext
                      ? AppColors.secondaryGlass
                      : AppColors.borderGlass,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                  )
                      : isLocked
                      ? const Icon(
                    Icons.lock_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  )
                      : Text(
                    '${session.day}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Session info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          session.formattedDuration,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (isNext) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryGlass,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'NEXT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(
                isLocked
                    ? Icons.lock_rounded
                    : Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSessionDetail(
      BuildContext context,
      MeditationSession session,
      MeditationProvider provider,
      ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.75;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: maxHeight,
        margin: const EdgeInsets.all(16),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondaryGlass,
                    ),
                    child: Center(
                      child: Text(
                        '${session.day}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Day ${session.day}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          session.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // SCROLLABLE CONTENT with ConstrainedBox pattern
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instructions',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        session.instruction,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_rounded,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            session.formattedDuration,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Action buttons
              Row(
                children: [
                  if (session.recommendedSoundId != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final soundProvider = context.read<SoundProvider>();
                          final sound = soundProvider.getSoundById(
                            session.recommendedSoundId!,
                          );
                          if (sound != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PlayerScreen(
                                  playlist: [sound],
                                  initialIndex: 0,
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.music_note_rounded),
                        label: const Text('Play Sound'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                            color: AppColors.borderGlass,
                          ),
                        ),
                      ),
                    ),
                  if (session.recommendedSoundId != null)
                    const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await provider.completeSession(program.id, session.day);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Day ${session.day} completed! 🎉'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryGlass,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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