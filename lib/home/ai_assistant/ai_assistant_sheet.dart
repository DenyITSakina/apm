import 'package:apm/func/navigation_helpers.dart';
import 'package:apm/home/ai_assistant/ai_assistant_service.dart';
import 'package:apm/home/check_in_bpjs/cekin_bpjs_page.dart';
import 'package:apm/home/check_in_umum/cekin_umum_page.dart';
import 'package:apm/theme/app_tokens.dart';
import 'package:apm/theme/app_typography.dart';
import 'package:apm/blog/antrian_apm_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Panel asisten AI mengambang (bukan bottom sheet) agar tidak menutupi versi.
class AiAssistantPanel extends StatefulWidget {
  const AiAssistantPanel({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<AiAssistantPanel> createState() => _AiAssistantPanelState();
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.fromUser});
  final String text;
  final bool fromUser;
}

class _AiAssistantPanelState extends State<AiAssistantPanel>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          'Halo! Saya asisten APM. Saya hanya membantu panduan Cek-in BPJS atau Cek-in Umum '
          '(tanpa meminta/menyimpan data pribadi). Mau check-in yang mana?',
      fromUser: false,
    ),
  ];
  final List<Map<String, String>> _history = [];
  bool _sending = false;

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    if (_sending) return;
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(text: text, fromUser: true));
      _sending = true;
    });
    _scrollToEnd();

    final result = await AiAssistantService.sendMessage(
      text,
      history: _history,
    );
    _history.add({'role': 'user', 'text': text});
    _history.add({'role': 'model', 'text': result.reply});

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(text: result.reply, fromUser: false));
      _sending = false;
    });
    _scrollToEnd();

    if (result.action == 'bpjs' || result.action == 'umum') {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      _navigateTo(result.action!);
    }
  }

  void _navigateTo(String action) {
    final isBpjs = action == 'bpjs';
    HapticFeedback.mediumImpact();
    widget.onClose();
    pushPage(
      context: context,
      page: BlocProvider(
        create: (_) => AntrianApmBloc(),
        child: isBpjs
            ? const CekinBpjs(selectType: 'bpjs')
            : const CekinUmumPage(selectType: 'umum'),
      ),
    );
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900;
    final panelW = isWide ? 400.0 : (size.width * 0.86).clamp(300.0, 400.0);
    final panelH = (size.height * 0.62).clamp(380.0, 560.0);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: panelW,
        height: panelH,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildQuickActions(),
            const Divider(height: 1),
            Expanded(child: _buildMessages()),
            const Divider(height: 1),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      decoration: const BoxDecoration(gradient: AppGradients.brand),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final glow = 0.18 + (_pulse.value * 0.12);
              return Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: glow),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asisten Check-in AI',
                  style: TextStyle(
                    fontFamily: AppText.family,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Panduan BPJS & Umum • Aman, tanpa data pribadi',
                  style: TextStyle(
                    fontFamily: AppText.family,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            tooltip: 'Tutup',
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceMuted,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          _QuickChip(
            icon: Icons.health_and_safety_rounded,
            label: 'Cek-in BPJS',
            color: AppColors.bpjs,
            onTap: () => _send('Saya mau check-in BPJS'),
          ),
          _QuickChip(
            icon: Icons.people_alt_rounded,
            label: 'Cek-in Umum',
            color: AppColors.umum,
            onTap: () => _send('Saya mau check-in Umum'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      itemCount: _messages.length + (_sending ? 1 : 0),
      itemBuilder: (context, i) {
        if (_sending && i == _messages.length) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Mengetik...'),
                ],
              ),
            ),
          );
        }
        final m = _messages[i];
        final isUser = m.fromUser;
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            constraints: BoxConstraints(
              maxWidth: (MediaQuery.of(context).size.width * 0.7).clamp(
                180.0,
                320.0,
              ),
            ),
            decoration: BoxDecoration(
              gradient: isUser ? AppGradients.brand : null,
              color: isUser ? null : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              border: isUser ? null : Border.all(color: AppColors.border),
              boxShadow: [
                if (isUser)
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: Text(
              m.text,
              style: TextStyle(
                fontFamily: AppText.family,
                fontSize: 13.5,
                height: 1.4,
                color: isUser ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              style: const TextStyle(fontFamily: AppText.family, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Tanya bantuan check-in...',
                hintStyle: TextStyle(
                  fontFamily: AppText.family,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
                isDense: true,
                filled: true,
                fillColor: AppColors.surfaceMuted,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _sending ? null : () => _send(),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppText.family,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
