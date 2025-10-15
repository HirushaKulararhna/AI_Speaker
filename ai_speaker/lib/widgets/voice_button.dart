import 'package:flutter/material.dart';

class VoiceButton extends StatefulWidget {
  final bool isListening;
  final bool isProcessing;
  final bool isSpeaking;
  final VoidCallback onTap;

  const VoiceButton({
    Key? key,
    required this.isListening,
    required this.isProcessing,
    required this.isSpeaking,
    required this.onTap,
  }) : super(key: key);

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isListening || widget.isProcessing || widget.isSpeaking;
    final canTap = !widget.isProcessing && !widget.isSpeaking;

    return GestureDetector(
      onTap: canTap ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isListening ? _scaleAnimation.value : 1.0,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: widget.isListening
                      ? [Colors.red, Colors.redAccent]
                      : [Colors.blue, Colors.blueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isListening ? Colors.red : Colors.blue)
                        .withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: widget.isListening ? 5 : 2,
                  ),
                ],
              ),
              child: Icon(
                widget.isListening
                    ? Icons.mic
                    : widget.isProcessing
                        ? Icons.hourglass_empty
                        : widget.isSpeaking
                            ? Icons.volume_up
                            : Icons.mic_none,
                color: Colors.white,
                size: 36,
              ),
            ),
          );
        },
      ),
    );
  }
}