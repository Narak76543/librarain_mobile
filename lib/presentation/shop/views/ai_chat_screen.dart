import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_color.dart';
import '../../../core/widgets/app_text.dart';
import '../../profile/viewmodels/profile_viewmodel.dart';
import '../viewmodels/ai_chat_viewmodel.dart';
import '../viewmodels/shop_viewmodel.dart';

import 'shop_screen.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<ProfileViewModel>().profile;
      final name = profile?.displayName.split(' ').first ?? 'there';
      context.read<AiChatViewModel>().init(name);
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _submit() {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    _controller.clear();
    final viewModel = context.read<AiChatViewModel>();
    viewModel.submitQuery(query).then((_) => _scrollToBottom());
    _scrollToBottom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFE5E5).withValues(alpha: 0.5),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE5F0FF).withValues(alpha: 0.5),
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(color: Colors.transparent),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: Consumer<AiChatViewModel>(
                      builder: (context, viewModel, child) {
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          itemCount: viewModel.messages.length,
                          itemBuilder: (context, index) {
                            final msg = viewModel.messages[index];
                            return _buildMessageBubble(msg);
                          },
                        );
                      },
                    ),
                  ),
                  _buildInputBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
          const AppText.titleSmall(
            'New Chat',
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic message) {
    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(60, 8, 20, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary400.withValues(alpha: 0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: AppText.bodyMedium(
                  message.text,
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Consumer<ProfileViewModel>(
                builder: (context, profileState, child) {
                  final avatarUrl = profileState.profile?.resolvedAvatarUrl;
                  if (avatarUrl != null) {
                    return ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: avatarUrl,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.white,
                          child: AppText.bodySmall(
                            profileState.profile?.initials ?? 'Me',
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }
                  return CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.white,
                    child: AppText.bodySmall(
                      profileState.profile?.initials ?? 'Me',
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    final textParts = message.text.split('**');
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 60, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.white,
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.75),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.9),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: message.isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (textParts.length > 1) ...[
                          AppText.bodyMedium(
                            textParts[0],
                            color: AppColors.textPrimary.withValues(alpha: 0.8),
                            fontSize: 16,
                          ),
                          const SizedBox(height: 4),
                          AppText.titleLarge(
                            textParts[1],
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                        ] else ...[
                          AppText.bodyMedium(
                            message.text,
                            color: AppColors.textPrimary.withValues(alpha: 0.9),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ],
                        if (message.books != null &&
                            message.books!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 180,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: message.books!.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final book = message.books![index];
                                return Container(
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withValues(
                                      alpha: 0.6,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.white),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                        child: CachedNetworkImage(
                                          imageUrl: book.coverUrl,
                                          height: 110,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.book, size: 40),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              book.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              '\$${double.tryParse(book.price)?.toStringAsFixed(2) ?? book.price}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (message.filters != null) {
                                  context.read<ShopViewModel>().applyAiFilters(
                                    message.filters!,
                                  );
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ShopScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.rocket_launch_rounded,
                                color: AppColors.white,
                                size: 18,
                              ),
                              label: const Text(
                                'Go to Shop',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.buttonColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    final viewModel = context.watch<AiChatViewModel>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      hintStyle: TextStyle(
                        color: AppColors.textPrimary.withValues(alpha: 0.4),
                      ),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) =>
                        viewModel.isProcessing ? null : _submit(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: viewModel.isProcessing ? null : _submit,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: viewModel.isProcessing
                          ? null
                          : AppGradients.primary,
                      color: viewModel.isProcessing
                          ? AppColors.textDisabled
                          : null,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
