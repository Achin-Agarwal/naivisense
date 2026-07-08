import 'package:flutter/material.dart';
import 'app_button.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final textScale = mediaQuery.textScaler.scale(1.0);
    final padding = (screenWidth * 0.06).clamp(16.0, 24.0);
    final iconSize = (screenWidth * 0.12 * textScale).clamp(40.0, 48.0);
    final spacing = (screenWidth * 0.04).clamp(12.0, 16.0);
    final maxContentWidth = (screenWidth * 0.9).clamp(280.0, 520.0);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth.clamp(0.0, maxContentWidth)
                : maxContentWidth;

            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: iconSize, color: Colors.red),
                  SizedBox(height: spacing),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (onRetry != null) ...[
                    SizedBox(height: spacing),
                    AppButton(label: 'Retry', onPressed: onRetry),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class EmptyWidget extends StatelessWidget {
  final String message;
  final IconData? icon;

  const EmptyWidget({super.key, required this.message, this.icon});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final textScale = mediaQuery.textScaler.scale(1.0);
    final padding = (screenWidth * 0.06).clamp(16.0, 24.0);
    final iconSize = (screenWidth * 0.12 * textScale).clamp(40.0, 48.0);
    final spacing = (screenWidth * 0.04).clamp(12.0, 16.0);
    final maxContentWidth = (screenWidth * 0.9).clamp(280.0, 520.0);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth.clamp(0.0, maxContentWidth)
                : maxContentWidth;

            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon ?? Icons.inbox_outlined,
                    size: iconSize,
                    color: Colors.grey,
                  ),
                  SizedBox(height: spacing),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
