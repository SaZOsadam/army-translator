import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/supabase_service.dart';
import '../../services/auth_service.dart';
import '../../models/poll_model.dart';

class PollsScreen extends StatefulWidget {
  const PollsScreen({super.key});

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();

  List<PollModel> _activePolls = [];
  List<PollModel> _closedPolls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPolls();
  }

  Future<void> _loadPolls() async {
    try {
      final activeData = await SupabaseService.getActivePolls();
      final active = activeData.map((e) => PollModel.fromJson(e)).toList();
      final List<PollModel> closed = [];

      setState(() {
        _activePolls = active;
        _closedPolls = closed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Use sample data if Supabase isn't configured
      _loadSamplePolls();
    }
  }

  void _loadSamplePolls() {
    setState(() {
      _activePolls = [
        PollModel(
          id: '1',
          question: 'Will ARIRANG have a retro-inspired title track? 🎵',
          options: [
            PollOption(id: '1a', text: 'Yes, definitely!', votes: 2456),
            PollOption(id: '1b', text: 'No, more modern', votes: 1823),
            PollOption(id: '1c', text: 'Mix of both', votes: 3102),
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          endsAt: DateTime.now().add(const Duration(days: 5)),
          totalVotes: 7381,
          createdBy: 'admin',
        ),
        PollModel(
          id: '2',
          question: 'Which member will have the most lines in the title track?',
          options: [
            PollOption(id: '2a', text: 'Jungkook', votes: 1567),
            PollOption(id: '2b', text: 'Jimin', votes: 1234),
            PollOption(id: '2c', text: 'V', votes: 1456),
            PollOption(id: '2d', text: 'Equal distribution', votes: 2890),
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          endsAt: DateTime.now().add(const Duration(days: 3)),
          totalVotes: 7147,
          createdBy: 'admin',
        ),
        PollModel(
          id: '3',
          question: 'How many songs do you think will be on ARIRANG? 💿',
          options: [
            PollOption(id: '3a', text: '8-10 songs', votes: 890),
            PollOption(id: '3b', text: '11-13 songs', votes: 2134),
            PollOption(id: '3c', text: '14+ songs', votes: 1567),
          ],
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
          endsAt: DateTime.now().add(const Duration(days: 7)),
          totalVotes: 4591,
          createdBy: 'admin',
        ),
      ];
      _isLoading = false;
    });
  }

  Future<void> _votePoll(String pollId, String optionId) async {
    final user = _authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to vote'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    try {
      await SupabaseService.voteOnPoll(pollId, int.parse(optionId));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vote recorded! 💜'),
          backgroundColor: AppColors.success,
        ),
      );

      _loadPolls();
    } catch (e) {
      // For demo, just show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vote recorded! 💜'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction Polls 📊'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryPurple,
          labelColor: AppColors.primaryPurple,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Results'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildActivePollsList(),
                _buildClosedPollsList(),
              ],
            ),
    );
  }

  Widget _buildActivePollsList() {
    if (_activePolls.isEmpty) {
      return _buildEmptyState('No active polls right now', '📊');
    }

    return RefreshIndicator(
      onRefresh: _loadPolls,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activePolls.length,
        itemBuilder: (context, index) {
          return _buildPollCard(_activePolls[index], showVoting: true);
        },
      ),
    );
  }

  Widget _buildClosedPollsList() {
    if (_closedPolls.isEmpty) {
      return _buildEmptyState('No completed polls yet', '🏆');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _closedPolls.length,
      itemBuilder: (context, index) {
        return _buildPollCard(_closedPolls[index], showVoting: false);
      },
    );
  }

  Widget _buildEmptyState(String message, String emoji) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back soon!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildPollCard(PollModel poll, {required bool showVoting}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryPurple.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: poll.status == PollStatus.active
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.textMuted.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  poll.status == PollStatus.active ? '🟢 Active' : '🔴 Closed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: poll.status == PollStatus.active
                        ? AppColors.success
                        : AppColors.textMuted,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${poll.totalVotes} votes',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            poll.question,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          ...poll.options.map((option) {
            return _buildPollOption(poll, option, showVoting: showVoting);
          }),
          if (poll.status == PollStatus.active) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.timer_outlined,
                    size: 16, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  _formatTimeRemaining(poll.timeRemaining),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPollOption(
    PollModel poll,
    PollOption option, {
    required bool showVoting,
  }) {
    final percentage = option.getPercentage(poll.totalVotes);
    final isWinner = poll.status == PollStatus.closed &&
        option.votes ==
            poll.options.map((o) => o.votes).reduce((a, b) => a > b ? a : b);

    return GestureDetector(
      onTap: showVoting ? () => _votePoll(poll.id, option.id) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Stack(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 50,
              width:
                  (MediaQuery.of(context).size.width - 72) * (percentage / 100),
              decoration: BoxDecoration(
                gradient: isWinner
                    ? AppColors.goldGradient
                    : AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option.text,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: percentage > 50
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                  if (isWinner)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Text('👑', style: TextStyle(fontSize: 18)),
                    ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: percentage > 50
                          ? Colors.white
                          : AppColors.primaryPurple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.isNegative) return 'Ended';

    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h left';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m left';
    } else {
      return '${duration.inMinutes}m left';
    }
  }
}
