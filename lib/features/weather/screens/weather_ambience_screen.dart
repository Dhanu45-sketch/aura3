import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/weather_provider.dart';
import '../../sounds/providers/sound_provider.dart';
import '../../player/screens/player_screen.dart';

class WeatherAmbienceScreen extends StatefulWidget {
  const WeatherAmbienceScreen({super.key});

  @override
  State<WeatherAmbienceScreen> createState() => _WeatherAmbienceScreenState();
}

class _WeatherAmbienceScreenState extends State<WeatherAmbienceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchWeatherForCurrentLocation();
    });
  }

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
              AppColors.waterGlass.withAlpha(51),
              AppColors.windGlass.withAlpha(51),
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<WeatherProvider>(
            builder: (context, weatherProvider, _) {
              return CustomScrollView(
                slivers: [
                  _buildAppBar(context),

                  if (weatherProvider.isLoading)
                    SliverFillRemaining(
                      child: _buildLoadingState(),
                    ),

                  if (weatherProvider.errorMessage != null && !weatherProvider.isLoading)
                    SliverFillRemaining(
                      child: _buildErrorState(weatherProvider),
                    ),

                  if (!weatherProvider.isLoading && weatherProvider.errorMessage == null)
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildWeatherCard(weatherProvider),
                          const SizedBox(height: 24),
                          _buildRecommendationsSection(context, weatherProvider),
                          const SizedBox(height: 100),
                        ]),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      title: const Row(
        children: [
          Text('🌤️'),
          SizedBox(width: 8),
          Text('Weather Ambience'),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () {
            context.read<WeatherProvider>().fetchWeatherForCurrentLocation();
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGlass),
          ),
          const SizedBox(height: 16),
          Text(
            'Detecting your location...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Fetching weather data...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildErrorState(WeatherProvider weatherProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off_rounded,
              size: 64,
              color: Color(0xFFEF5350), // Colors.red.shade400
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to get location or weather',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              weatherProvider.errorMessage ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                weatherProvider.fetchWeatherForCurrentLocation();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(WeatherProvider weatherProvider) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: AppColors.primaryGlass,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  weatherProvider.cityName ?? 'Unknown',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            weatherProvider.locationString,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Weather Icon & Temp
          Text(
            weatherProvider.weatherIcon,
            style: const TextStyle(fontSize: 80),
          ).animate().scale(duration: 600.ms),
          const SizedBox(height: 16),

          Text(
            weatherProvider.temperature,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _capitalize(weatherProvider.weatherDescription),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),

          // Weather Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherDetail(
                Icons.water_drop_rounded,
                'Humidity',
                '${weatherProvider.humidity}%',
              ),
              _buildWeatherDetail(
                Icons.air_rounded,
                'Wind',
                '${weatherProvider.windSpeed.toStringAsFixed(1)} m/s',
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryGlass, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection(
      BuildContext context,
      WeatherProvider weatherProvider,
      ) {
    final soundProvider = context.watch<SoundProvider>();
    final recommendedElement = weatherProvider.recommendedElement;

    if (recommendedElement == null) return const SizedBox.shrink();

    final recommendedSounds = soundProvider.getSoundsByElement(recommendedElement);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.getElementColor(recommendedElement).withAlpha(77),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getElementIcon(recommendedElement),
                  color: AppColors.getElementSolidColor(recommendedElement),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended for ${weatherProvider.weatherCondition}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${recommendedElement.toUpperCase()} element sounds match your weather',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms),

        const SizedBox(height: 16),

        ...recommendedSounds.asMap().entries.map((entry) {
          final index = entry.key;
          final sound = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PlayerScreen(
                      playlist: recommendedSounds,
                      initialIndex: index,
                      playlistId: 'weather_$recommendedElement',
                    ),
                  ),
                );
              },
              child: GlassContainer(
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
                            AppColors.getElementSolidColor(sound.element),
                            AppColors.getElementSolidColor(sound.element).withAlpha(153),
                          ],
                        ),
                      ),
                      child: Icon(
                        _getElementIcon(sound.element),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sound.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sound.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.play_circle_rounded,
                      color: AppColors.getElementSolidColor(sound.element),
                      size: 32,
                    ),
                  ],
                ),
              ),
            ).animate(delay: (100 * index + 600).ms).fadeIn().slideX(begin: 0.2, end: 0),
          );
        }),
      ],
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  IconData _getElementIcon(String element) {
    switch (element.toLowerCase()) {
      case 'earth':
        return Icons.forest_rounded;
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'water':
        return Icons.water_drop_rounded;
      case 'wind':
        return Icons.air_rounded;
      default:
        return Icons.music_note_rounded;
    }
  }
}
