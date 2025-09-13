import 'package:flutter/material.dart';

import '../../game/models/case.dart';

class ClueCard extends StatefulWidget {
  final Clue clue;
  final Function(int) onAnswerSelected;
  final bool? lastAttemptCorrect;
  final List<String> usedHints;
  final VoidCallback onHintRequested;

  const ClueCard({
    super.key,
    required this.clue,
    required this.onAnswerSelected,
    this.lastAttemptCorrect,
    this.usedHints = const [],
    required this.onHintRequested,
  });

  @override
  State<ClueCard> createState() => _ClueCardState();
}

class _ClueCardState extends State<ClueCard> {
  int? selectedAnswer;
  bool hasAttempted = false;

  @override
  void didUpdateWidget(ClueCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastAttemptCorrect != null && !hasAttempted) {
      setState(() {
        hasAttempted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clue header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getClueTypeColor(widget.clue.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getClueTypeName(widget.clue.type),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getClueTypeColor(widget.clue.type),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.clue.difficultyPoints} pts',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Clue title
            Text(
              widget.clue.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Clue description
            Text(
              widget.clue.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Question
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                widget.clue.question,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Answer options
            ...widget.clue.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = selectedAnswer == index;
              final isCorrect = widget.clue.correctAnswerIndex == index;
              
              Color? backgroundColor;
              Color? borderColor;
              Color? textColor;
              
              if (hasAttempted) {
                if (isCorrect) {
                  backgroundColor = Colors.green.shade100;
                  borderColor = Colors.green.shade300;
                  textColor = Colors.green.shade800;
                } else if (isSelected && !isCorrect) {
                  backgroundColor = Colors.red.shade100;
                  borderColor = Colors.red.shade300;
                  textColor = Colors.red.shade800;
                }
              } else if (isSelected) {
                backgroundColor = Colors.blue.shade100;
                borderColor = Colors.blue.shade300;
                textColor = Colors.blue.shade800;
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: hasAttempted ? null : () {
                    setState(() {
                      selectedAnswer = index;
                    });
                    widget.onAnswerSelected(index);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: backgroundColor ?? Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: borderColor ?? Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          String.fromCharCode(65 + index), // A, B, C, D
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor ?? Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              color: textColor ?? Colors.black87,
                            ),
                          ),
                        ),
                        if (hasAttempted && isCorrect)
                          const Icon(Icons.check_circle, color: Colors.green),
                        if (hasAttempted && isSelected && !isCorrect)
                          const Icon(Icons.cancel, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            
            // Show result and explanation after attempt
            if (hasAttempted) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.lastAttemptCorrect == true 
                      ? Colors.green.shade50 
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.lastAttemptCorrect == true 
                        ? Colors.green.shade200 
                        : Colors.orange.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.lastAttemptCorrect == true 
                              ? Icons.check_circle 
                              : Icons.info_outline,
                          color: widget.lastAttemptCorrect == true 
                              ? Colors.green 
                              : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.lastAttemptCorrect == true 
                              ? 'Correct!' 
                              : 'Explanation',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: widget.lastAttemptCorrect == true 
                                ? Colors.green.shade800 
                                : Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.clue.explanation,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
            
            // Hints section
            if (widget.clue.hints.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hints available: ${widget.clue.hints.length - widget.usedHints.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  if (!hasAttempted && widget.usedHints.length < widget.clue.hints.length)
                    TextButton.icon(
                      onPressed: widget.onHintRequested,
                      icon: const Icon(Icons.lightbulb_outline, size: 16),
                      label: const Text('Get Hint'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                ],
              ),
              
              // Show used hints
              if (widget.usedHints.isNotEmpty)
                ...widget.usedHints.map((hintKey) {
                  final hintText = widget.clue.hints[hintKey];
                  if (hintText == null) return const SizedBox.shrink();
                  
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.yellow.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb,
                            size: 16,
                            color: Colors.yellow.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              hintText,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.yellow.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Color _getClueTypeColor(ClueType type) {
    switch (type) {
      case ClueType.location:
        return Colors.blue;
      case ClueType.cultural:
        return Colors.purple;
      case ClueType.historical:
        return Colors.brown;
      case ClueType.visual:
        return Colors.green;
      case ClueType.interview:
        return Colors.orange;
      case ClueType.evidence:
        return Colors.red;
    }
  }

  String _getClueTypeName(ClueType type) {
    switch (type) {
      case ClueType.location:
        return 'LOCATION';
      case ClueType.cultural:
        return 'CULTURAL';
      case ClueType.historical:
        return 'HISTORICAL';
      case ClueType.visual:
        return 'VISUAL';
      case ClueType.interview:
        return 'INTERVIEW';
      case ClueType.evidence:
        return 'EVIDENCE';
    }
  }
}