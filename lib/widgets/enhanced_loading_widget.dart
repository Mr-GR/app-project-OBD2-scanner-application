import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../flutter_flow/flutter_flow_theme.dart';

class EnhancedLoadingWidget extends StatelessWidget {
  final String message;
  final double? progress;
  final bool showShimmer;
  final Widget? child;
  final LoadingType type;

  const EnhancedLoadingWidget({
    super.key,
    this.message = 'Loading...',
    this.progress,
    this.showShimmer = true,
    this.child,
    this.type = LoadingType.spinner,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLoadingIndicator(context),
        if (message.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            message,
            style: FlutterFlowTheme.of(context).bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
        if (child != null) ...[
          const SizedBox(height: 16),
          child!,
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    switch (type) {
      case LoadingType.spinner:
        return const CircularProgressIndicator()
            .animate()
            .fadeIn(duration: 300.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
      
      case LoadingType.progress:
        return Column(
          children: [
            if (progress != null) ...[
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress! * 100).toInt()}%',
                style: const TextStyle(fontSize: 12),
              ),
            ] else ...[
              const LinearProgressIndicator(),
            ],
          ],
        ).animate().fadeIn(duration: 300.ms);
      
      case LoadingType.skeleton:
        return _buildSkeletonLoader();
      
      case LoadingType.shimmer:
        return _buildShimmerLoader();
    }
  }

  Widget _buildSkeletonLoader() {
    return Column(
      children: [
        _buildSkeletonCard(),
        const SizedBox(height: 12),
        _buildSkeletonCard(height: 60),
        const SizedBox(height: 12),
        _buildSkeletonCard(height: 40),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildSkeletonCard({double height = 80}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1500.ms, color: Colors.grey[300]!);
  }

  Widget _buildShimmerLoader() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[300]!,
            Colors.grey[100]!,
            Colors.grey[300]!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(100),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 2000.ms, color: Colors.white);
  }
}

enum LoadingType {
  spinner,
  progress,
  skeleton,
  shimmer,
}

class ShimmerLoadingWidget extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoadingWidget({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1500.ms, color: Colors.grey[300]!);
  }
}

class PullToRefreshWidget extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String? refreshMessage;

  const PullToRefreshWidget({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshMessage,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
} 