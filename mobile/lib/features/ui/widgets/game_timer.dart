import 'package:flutter/material.dart';

class GameTimer extends StatelessWidget {
  final int elapsedMinutes;
  final int totalMinutes;
  final bool isActive;

  const GameTimer({
    super.key,
    required this.elapsedMinutes,
    required this.totalMinutes,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final remainingMinutes = totalMinutes - elapsedMinutes;
    final progress = elapsedMinutes / totalMinutes;
    
    Color timerColor;
    if (remainingMinutes <= 15) {
      timerColor = Colors.red;
    } else if (remainingMinutes <= 30) {
      timerColor = Colors.orange;
    } else {
      timerColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: timerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: timerColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.timer : Icons.timer_off,
            size: 16,
            color: timerColor,
          ),
          const SizedBox(width: 6),
          Text(
            _formatTime(remainingMinutes),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: timerColor,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            height: 6,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(timerColor),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int minutes) {
    if (minutes < 0) return '0m';
    
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else {
      return '${remainingMinutes}m';
    }
  }
}