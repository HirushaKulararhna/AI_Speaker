import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/speech_service.dart';
import '../services/ai_service.dart';
import '../widgets/voice_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechService _speechService = SpeechService();
  final AIService _aiService = AIService();
  final FlutterTts _flutterTts = FlutterTts();

  String _userText = '';
  String _aiResponse = '';
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isSpeaking = false;
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    await _speechService.initialize();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      setState(() => _isSpeaking = true);
    });

    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() => _isSpeaking = false);
    });
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
      _userText = '';
    });

    await _speechService.startListening(
      onResult: (text) {
        setState(() => _userText = text);
      },
      onComplete: () {
        if (_userText.isNotEmpty) {
          _processUserInput();
        }
      },
    );

    // Auto stop after 5 seconds of continuous listening
    await Future.delayed(const Duration(seconds: 5));
    if (_isListening) {
      await _stopListening();
    }
  }

  Future<void> _stopListening() async {
    await _speechService.stopListening();
    setState(() => _isListening = false);
    
    if (_userText.isNotEmpty) {
      await _processUserInput();
    }
  }

  Future<void> _processUserInput() async {
    if (_userText.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: _userText, isUser: true));
      _isProcessing = true;
    });

    // Get AI response
    final response = await _aiService.getResponse(_userText);

    setState(() {
      _aiResponse = response;
      _messages.add(ChatMessage(text: response, isUser: false));
      _isProcessing = false;
    });

    // Speak the response
    await _speak(response);
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _userText = '';
      _aiResponse = '';
    });
  }

  @override
  void dispose() {
    _speechService.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'AI Speaker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearChat,
            tooltip: 'Clear conversation',
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages Area
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : _buildMessagesList(),
          ),

          // Status Indicator
          _buildStatusBar(),

          // Voice Button
          _buildVoiceControl(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mic_none_rounded,
              size: 80,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Tap the microphone',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Start speaking to practice English',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? Colors.blue[600]
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    String statusText = '';
    Color statusColor = Colors.grey;

    if (_isListening) {
      statusText = '🎤 Listening...';
      statusColor = Colors.red;
    } else if (_isProcessing) {
      statusText = '⏳ Processing...';
      statusColor = Colors.orange;
    } else if (_isSpeaking) {
      statusText = '🔊 Speaking...';
      statusColor = Colors.green;
    }

    if (statusText.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_userText.isNotEmpty && _isListening) ...[
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                _userText,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVoiceControl() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: VoiceButton(
          isListening: _isListening,
          isProcessing: _isProcessing,
          isSpeaking: _isSpeaking,
          onTap: _isListening ? _stopListening : _startListening,
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}