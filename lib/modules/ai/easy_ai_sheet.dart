import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ── Message Model ─────────────────────────────────────────────
class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  _ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

// ── Easy AI Sheet ─────────────────────────────────────────────
class EasyAiSheet extends StatefulWidget {
  const EasyAiSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EasyAiSheet(),
    );
  }

  @override
  State<EasyAiSheet> createState() => _EasyAiSheetState();
}

class _EasyAiSheetState extends State<EasyAiSheet> {
  static const Color skyBlue    = Color(0xFF29B6F6);
  static const Color darkBlue   = Color(0xFF0288D1);
  static const String _apiUrl   = 'https://api.easysarvice.com/ai/chat';

  final TextEditingController _inputCtrl    = TextEditingController();
  final ScrollController       _scrollCtrl  = ScrollController();
  final List<_ChatMessage>     _messages    = [];

  // API-তে পাঠানোর জন্য history (role/content format)
  final List<Map<String, String>> _history  = [];

  String _userName  = '';
  bool   _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    // Welcome message
    _messages.add(_ChatMessage(
      text: 'হ্যালো! আমি Riya 👋\nEasyService-এ স্বাগতম! কীভাবে সাহায্য করতে পারি বলুন 😊',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? '';
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _isLoading) return;

    _inputCtrl.clear();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message'   : text,
          'user_name' : _userName,
          'history'   : _history,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final body  = jsonDecode(response.body);
        final reply = (body['reply'] ?? '').toString().trim();

        // History update
        _history.add({'role': 'user',      'content': text});
        _history.add({'role': 'assistant', 'content': reply});

        // History বড় হলে পুরনো কাটো (last 20 messages রাখো)
        if (_history.length > 20) {
          _history.removeRange(0, _history.length - 20);
        }

        setState(() {
          _messages.add(_ChatMessage(text: reply, isUser: false));
        });
      } else {
        _addErrorMessage();
      }
    } catch (_) {
      _addErrorMessage();
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _addErrorMessage() {
    setState(() {
      _messages.add(_ChatMessage(
        text: 'আরে ভাই, এখন একটু সমস্যা হচ্ছে 😅 একটু পরে আবার try করুন!',
        isUser: false,
      ));
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double sheetHeight = MediaQuery.of(context).size.height * 0.88;
    final double bottomPad   = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildMessageList(context)),
          _buildInputBar(context, bottomPad),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [skyBlue, darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          // Drag handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  child: Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 20.sp),
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Easy AI — Riya',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 7.w,
                          height: 7.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF69F0AE),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Online',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded,
                      color: Colors.white, size: 22.sp),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  // ── Message List ─────────────────────────────────────────────
  Widget _buildMessageList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      controller: _scrollCtrl,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return _buildTypingIndicator(isDark);
        }
        return _buildMessageBubble(_messages[index], isDark);
      },
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg, bool isDark) {
    final isUser = msg.isUser;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Riya avatar
          if (!isUser) ...[
            CircleAvatar(
              radius: 14.r,
              backgroundColor: skyBlue.withOpacity(0.15),
              child: Icon(Icons.auto_awesome_rounded,
                  color: skyBlue, size: 14.sp),
            ),
            SizedBox(width: 6.w),
          ],

          // Bubble
          Flexible(
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isUser
                    ? skyBlue
                    : (isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFF0F4F8)),
                borderRadius: BorderRadius.only(
                  topLeft:     Radius.circular(16.r),
                  topRight:    Radius.circular(16.r),
                  bottomLeft:  Radius.circular(isUser ? 16.r : 4.r),
                  bottomRight: Radius.circular(isUser ? 4.r  : 16.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: GoogleFonts.poppins(
                  color: isUser
                      ? Colors.white
                      : (isDark ? Colors.white : const Color(0xFF1A1A2E)),
                  fontSize: 13.sp,
                  height: 1.5,
                ),
              ),
            ),
          ),

          // User avatar placeholder
          if (isUser) SizedBox(width: 6.w),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14.r,
            backgroundColor: skyBlue.withOpacity(0.15),
            child: Icon(Icons.auto_awesome_rounded,
                color: skyBlue, size: 14.sp),
          ),
          SizedBox(width: 6.w),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFF0F4F8),
              borderRadius: BorderRadius.only(
                topLeft:     Radius.circular(16.r),
                topRight:    Radius.circular(16.r),
                bottomLeft:  Radius.circular(4.r),
                bottomRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return _TypingDot(delay: Duration(milliseconds: i * 200));
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Input Bar ────────────────────────────────────────────────
  Widget _buildInputBar(BuildContext context, double bottomPad) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h + bottomPad),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: TextField(
                controller: _inputCtrl,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
                decoration: InputDecoration(
                  hintText: 'Riya-কে কিছু জিজ্ঞেস করুন...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: Colors.grey.shade400,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 10.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Send button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [skyBlue, darkBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: _isLoading
                  ? Padding(
                      padding: EdgeInsets.all(12.r),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.send_rounded,
                      color: Colors.white, size: 18.sp),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Typing Dot Animation ──────────────────────────────────────
class _TypingDot extends StatefulWidget {
  final Duration delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween<double>(begin: 0, end: -5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
