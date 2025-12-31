
// lib/features/meditation/screens/meditation_screen.dart
import 'package:flutter/material.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/theme/app_colors.dart';

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
          child: CustomScrollView(
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
                    _buildTimerCard(context),
                    const SizedBox(height: 24),
                    Text(
                      'Guided Sessions',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      5,
                          (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildSessionCard(context, index),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerCard(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      gradient: LinearGradient(
        colors: [
          AppColors.secondaryGlass.withOpacity(0.3),
          AppColors.tertiaryGlass.withOpacity(0.3),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Quick Timer',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Text(
            '10:00',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimerButton(context, '5m'),
              const SizedBox(width: 12),
              _buildTimerButton(context, '10m'),
              const SizedBox(width: 12),
              _buildTimerButton(context, '15m'),
              const SizedBox(width: 12),
              _buildTimerButton(context, '30m'),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryGlass,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerButton(BuildContext context, String time) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(time, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _buildSessionCard(BuildContext context, int index) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  AppColors.secondaryGlass,
                  AppColors.tertiaryGlass,
                ],
              ),
            ),
            child: const Icon(
              Icons.self_improvement_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meditation Session ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${(index + 1) * 5} minutes',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow_rounded),
            color: AppColors.secondaryGlass,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}