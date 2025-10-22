import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum FlashcardMode {
  study,
  exam,
  review,
  dashboard,
}

class FlashcardWidget extends StatefulWidget {
  final Widget frontContent;
  final Widget backContent;
  final bool enableDoubleTap;
  final FlashcardMode mode;
  final VoidCallback? onFlip;
  final bool startFlipped;

  const FlashcardWidget({
    Key? key,
    required this.frontContent,
    required this.backContent,
    this.enableDoubleTap = true,
    required this.mode,
    this.onFlip,
    this.startFlipped = false,
  }) : super(key: key);

  @override
  _FlashcardWidgetState createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    
    // Start flipped if requested
    if (widget.startFlipped) {
      _isFlipped = true;
    }
  }

  @override
  void didUpdateWidget(FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle external flip state changes
    if (widget.startFlipped != oldWidget.startFlipped) {
      setState(() {
        _isFlipped = widget.startFlipped;
      });
    }
  }

  void _handleDoubleTap() {
    if (!widget.enableDoubleTap) return;

    // Only allow flipping in study mode
    if (widget.mode != FlashcardMode.study) return;

    // Provide haptic feedback only in study mode
    HapticFeedback.lightImpact();

    setState(() {
      _isFlipped = !_isFlipped;
    });

    // Notify parent about flip
    widget.onFlip?.call();
  }

  void _handleTapDown(TapDownDetails details) {
    // Only handle taps in study mode
    if (widget.mode == FlashcardMode.study) {
      _handleDoubleTap();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For exam mode, disable all gestures and show only front content
    if (widget.mode == FlashcardMode.exam) {
      return _buildStaticContent(showFront: true);
    }
    
    // For study mode, allow gestures but show content based on flip state
    return GestureDetector(
      onTapDown: widget.mode == FlashcardMode.study ? _handleTapDown : null,
      behavior: HitTestBehavior.opaque,
      child: _buildStaticContent(showFront: !_isFlipped),
    );
  }

  Widget _buildStaticContent({required bool showFront}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: showFront ? _buildFrontContent() : _buildBackContent(),
      ),
    );
  }

  Widget _buildFrontContent() {
    return Container(
      key: const ValueKey('front'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          widget.frontContent,
          // Double-tap hint overlay (only in study mode)
          if (widget.mode == FlashcardMode.study && !_isFlipped)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Double-tap to flip',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackContent() {
    return Container(
      key: const ValueKey('back'),
      decoration: BoxDecoration(
        color: _getBackColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          widget.backContent,
          // Flip back hint (only in study mode)
          if (widget.mode == FlashcardMode.study && _isFlipped)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Double-tap to flip back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getBackColor() {
    switch (widget.mode) {
      case FlashcardMode.study:
        return Colors.blue.shade50;
      case FlashcardMode.exam:
        return Colors.orange.shade50;
      case FlashcardMode.review:
        return Colors.green.shade50;
      case FlashcardMode.dashboard:
        return Colors.grey.shade50;
    }
  }

  Color _getBorderColor() {
    switch (widget.mode) {
      case FlashcardMode.study:
        return Colors.blue.shade300;
      case FlashcardMode.exam:
        return Colors.orange.shade300;
      case FlashcardMode.review:
        return Colors.green.shade300;
      case FlashcardMode.dashboard:
        return Colors.grey.shade300;
    }
  }

  // Public method to programmatically flip the card
  void flip() {
    // Only allow flipping in study mode
    if (widget.mode == FlashcardMode.study) {
      setState(() {
        _isFlipped = !_isFlipped;
      });
      widget.onFlip?.call();
    }
  }

  // Public method to check current flip state
  bool get isFlipped => _isFlipped;
}