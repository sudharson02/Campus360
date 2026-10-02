import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/token_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_badge.dart';

class TokensScreen extends StatefulWidget {
  const TokensScreen({super.key});

  @override
  State<TokensScreen> createState() => _TokensScreenState();
}

class _TokensScreenState extends State<TokensScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TokenProvider>(context, listen: false).fetchTokens();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final tokenProvider = Provider.of<TokenProvider>(context);
    final notifProvider = Provider.of<NotificationProvider>(context);

    final isAdmin = auth.isAdmin;
    final student = auth.currentStudent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Campus Token Queues'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'OFFICE (OFF)'),
            Tab(text: 'CANTEEN (CAN)'),
            Tab(text: 'LIBRARY (LIB)'),
          ],
        ),
      ),
      body: tokenProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildQueueView(context, 'OFF', tokenProvider, notifProvider, isAdmin, student),
                _buildQueueView(context, 'CAN', tokenProvider, notifProvider, isAdmin, student),
                _buildQueueView(context, 'LIB', tokenProvider, notifProvider, isAdmin, student),
              ],
            ),
    );
  }

  Widget _buildQueueView(
    BuildContext context,
    String queueType,
    TokenProvider tokenProvider,
    NotificationProvider notifProvider,
    bool isAdmin,
    dynamic student,
  ) {
    final servingToken = tokenProvider.getCurrentServing(queueType);
    final waitingTokens = tokenProvider.getWaitingTokens(queueType);
    final myToken = student != null ? tokenProvider.getMyActiveToken(queueType, student.registerNumber) : null;
    final tokensAhead = student != null ? tokenProvider.getTokensAheadCount(queueType, student.registerNumber) : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Currently Serving Counter Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              children: [
                Text(
                  'NOW SERVING AT ${queueType == 'OFF' ? 'ADMIN OFFICE' : queueType == 'CAN' ? 'CANTEEN' : 'LIBRARY'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  servingToken != null ? '$queueType-${servingToken.tokenNumber}' : 'NO ACTIVE TOKEN',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                if (servingToken != null) ...[
                  const SizedBox(height: 4),
                  Text('Holder: ${servingToken.studentName} (${servingToken.registerNumber})', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Student Active Ticket Banner
          if (!isAdmin && student != null) ...[
            if (myToken != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: myToken.status == 'Serving' ? AppColors.successBg : AppColors.warningBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: myToken.status == 'Serving' ? AppColors.success : AppColors.warning),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: myToken.status == 'Serving' ? AppColors.success : AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$queueType-${myToken.tokenNumber}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            myToken.status == 'Serving' ? 'YOUR TOKEN IS CALLED!' : 'MY TOKEN: $queueType-${myToken.tokenNumber}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            myToken.status == 'Serving'
                                ? 'Please proceed immediately to the counter.'
                                : '$tokensAhead token(s) ahead of you in line.',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              CustomButton(
                text: 'Book Token for $queueType Counter',
                icon: LucideIcons.ticket,
                onPressed: () async {
                  final ok = await tokenProvider.applyToken(
                    queueType: queueType,
                    studentName: student.name,
                    registerNumber: student.registerNumber,
                    notificationProvider: notifProvider,
                  );
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('You already have an active token in this queue!')),
                    );
                  }
                },
              ),
            ],
            const SizedBox(height: 20),
          ],

          // Admin / Staff Actions
          if (isAdmin) ...[
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Call Next Token',
                    icon: LucideIcons.megaphone,
                    onPressed: () {
                      tokenProvider.callNextToken(
                        queueType: queueType,
                        notificationProvider: notifProvider,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Waiting Tokens List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Queue Line (Strict FIFO Order)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text('${waitingTokens.length} Waiting', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 10),

          if (waitingTokens.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('Queue is currently empty.', style: TextStyle(color: AppColors.textMuted))),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: waitingTokens.length,
              itemBuilder: (context, idx) {
                final ticket = waitingTokens[idx];
                final isMe = student != null && ticket.registerNumber == student.registerNumber;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isMe ? AppColors.primaryLight : AppColors.surface,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        '${idx + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                      ),
                    ),
                    title: Text(
                      'Ticket $queueType-${ticket.tokenNumber}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      '${ticket.studentName} (${ticket.registerNumber})',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    trailing: StatusBadge(status: ticket.status),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
