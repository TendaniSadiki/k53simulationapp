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

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  bool _isFlipped = false;
  DateTime? _lastTapTime;
  Offset? _lastTapPosition;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Start flipped if requested
    if (widget.startFlipped) {
      _isFlipped = true;
      _flipController.value = 1.0;
    }

    _flipController.addStatusListener((status) {
      _isAnimating = status == AnimationStatus.forward || 
                     status == AnimationStatus.reverse;
    });
  }

  @override
  void didUpdateWidget(FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle external flip state changes
    if (widget.startFlipped != oldWidget.startFlipped) {
      if (widget.startFlipped && !_isFlipped) {
        _flipController.forward();
        _isFlipped = true;
      } else if (!widget.startFlipped && _isFlipped) {
        _flipController.reverse();
        _isFlipped = false;
      }
    }
  }

  void _handleDoubleTap() {
    if (!widget.enableDoubleTap || _isAnimating) return;

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    // Flip animation
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    _isFlipped = !_isFlipped;

    // Notify parent about flip
    widget.onFlip?.call();
  }

  void _handleTapDown(TapDownDetails details) {
    final now = DateTime.now();
    final currentPosition = details.globalPosition;

    // Check if this is a double tap
    if (_lastTapTime != null && 
        now.difference(_lastTapTime!) < const Duration(milliseconds: 500) &&
        _lastTapPosition != null &&
        _getDistance(_lastTapPosition!, currentPosition) < 20) {
      
      _handleDoubleTap();
      _lastTapTime = null;
      _lastTapPosition = null;
    } else {
      _lastTapTime = now;
      _lastTapPosition = currentPosition;
    }
  }

  double _getDistance(Offset a, Offset b) {
    final dx = a.dx - b.dx;
    final dy = a.dy - b.dy;
    return (dx * dx + dy * dy);
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _flipController,
        builder: (context, child) {
          final angle = _flipController.value * 3.14159; // π radians for 180° flip
          
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(angle),
            alignment: Alignment.center,
            child: _buildContent(),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    // Determine which content to show based on flip state
    final showFront = _flipController.value < 0.5;
    
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: showFront 
              ? _buildFrontContent()
              : _buildBackContent(),
        ),
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
    _handleDoubleTap();
  }

  // Public method to check current flip state
  bool get isFlipped => _isFlipped;
}