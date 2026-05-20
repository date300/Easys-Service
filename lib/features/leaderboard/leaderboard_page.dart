import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../main.dart';

// ==================== API CONFIG ====================
const String API_BASE = 'https://api.easysarvice.com/api';

// ==================== PROVIDERS ====================
final leaderboardTabProvider = StateProvider<String>((ref) => 'income');
final leaderboardPeriodProvider = StateProvider<String>((ref) => 'all');
final leaderboardLimitProvider = StateProvider<int>((ref) => 50);
final leaderboardBalanceTypeProvider = StateProvider<String>((ref) => 'total');
final leaderboardSearchProvider = StateProvider<String>((ref) => '');

Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwt_token');
}

String formatCurrency(dynamic amount) {
  if (amount == null) return '৳0';
  final value = amount is num ? amount : num.tryParse(amount.toString()) ?? 0;
  final formatter = NumberFormat.currency(
    locale: 'bn_BD',
    symbol: '৳',
    decimalDigits: 0,
  );
  return formatter.format(value);
}

String formatNumber(dynamic number) {
  if (number == null) return '0';
  final value = number is num ? number : num.tryParse(number.toString()) ?? 0;
  return NumberFormat.compact(locale: 'en').format(value);
}

final leaderboardDataProvider =
    FutureProvider.family<List<dynamic>, String>((ref, tab) async {
  final period = ref.watch(leaderboardPeriodProvider);
  final limit = ref.watch(leaderboardLimitProvider);
  final balanceType = ref.watch(leaderboardBalanceTypeProvider);
  final token = await _getToken();

  if (token == null || token.isEmpty) throw Exception('UNAUTHORIZED');

  String url = '$API_BASE/leaderboard/$tab?limit=$limit';
  if (tab == 'income' || tab == 'matrix') url += '&period=$period';
  if (tab == 'balance') url += '&type=$balanceType';

  final response = await http.get(
    Uri.parse(url),
    headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data'] ?? [];
  } else if (response.statusCode == 401) {
    throw Exception('UNAUTHORIZED');
  } else if (response.statusCode == 403) {
    throw Exception('FORBIDDEN');
  } else {
    throw Exception('SERVER_ERROR');
  }
});

final leaderboardStatsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final token = await _getToken();
  if (token == null || token.isEmpty) throw Exception('UNAUTHORIZED');

  final response = await http.get(
    Uri.parse('$API_BASE/leaderboard/stats'),
    headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data'] ?? {};
  } else if (response.statusCode == 401) {
    throw Exception('UNAUTHORIZED');
  } else {
    throw Exception('SERVER_ERROR');
  }
});

final userDetailProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, userId) async {
  final token = await _getToken();
  if (token == null || token.isEmpty) throw Exception('UNAUTHORIZED');

  final response = await http.get(
    Uri.parse('$API_BASE/leaderboard/user/$userId'),
    headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data'] ?? {};
  } else if (response.statusCode == 404) {
    throw Exception('NOT_FOUND');
  } else {
    throw Exception('SERVER_ERROR');
  }
});

// ==================== PAGE ====================
class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({super.key});

  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();

    Future.microtask(() {
      ref.read(isDetailViewProvider.notifier).state = true;
      ref.read(detailViewTitleProvider.notifier).state = 'Leaderboard';
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    for (final tab in ['income', 'referrals', 'matrix', 'balance']) {
      ref.invalidate(leaderboardDataProvider(tab));
    }
    ref.invalidate(leaderboardStatsProvider);
  }

  // ==================== USER DETAIL BOTTOM SHEET ====================
  void _showUserDetail(BuildContext context, int userId, String userName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: _UserDetailBottomSheet(userId: userId, userName: userName),
      ),
    );
  }

  Color _secondaryTextColor(bool isDark) =>
      isDark ? Colors.grey.shade400 : Colors.grey.shade600;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeTab = ref.watch(leaderboardTabProvider);
    final period = ref.watch(leaderboardPeriodProvider);
    final limit = ref.watch(leaderboardLimitProvider);
    final balanceType = ref.watch(leaderboardBalanceTypeProvider);
    final searchQuery = ref.watch(leaderboardSearchProvider);
    final leaderboardAsync = ref.watch(leaderboardDataProvider(activeTab));

    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final borderColor = isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200;

    final tabs = [
      {'key': 'income', 'label': 'Top Earners', 'icon': Icons.emoji_events},
      {'key': 'referrals', 'label': 'Referrers', 'icon': Icons.people},
      {'key': 'matrix', 'label': 'Matrix', 'icon': Icons.grid_view},
      {'key': 'balance', 'label': 'Balance', 'icon': Icons.account_balance_wallet},
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        backgroundColor: cardColor,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => ref
                        .read(leaderboardSearchProvider.notifier)
                        .state = value.toLowerCase(),
                    decoration: InputDecoration(
                      hintText: 'Search by name, mobile or email...',
                      hintStyle: TextStyle(color: secondaryTextColor),
                      prefixIcon: Icon(Icons.search, color: secondaryTextColor),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close, color: secondaryTextColor, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(leaderboardSearchProvider.notifier).state = '';
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    style: TextStyle(color: textColor),
                  ),
                ),
              ),
            ),

            // Tab Bar
            SliverToBoxAdapter(
              child: Container(
                height: 64,
                margin: const EdgeInsets.only(top: 12),
                color: cardColor,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tabs.length,
                  itemBuilder: (context, index) {
                    final tab = tabs[index];
                    final isActive = activeTab == tab['key'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              tab['icon'] as IconData,
                              size: 16,
                              color: isActive ? Colors.white : secondaryTextColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tab['label'] as String,
                              style: TextStyle(
                                color: isActive ? Colors.white : secondaryTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        selected: isActive,
                        onSelected: (_) {
                          ref.read(leaderboardTabProvider.notifier).state = tab['key'] as String;
                          _animationController.reset();
                          _animationController.forward();
                        },
                        selectedColor: const Color(0xFF0F172A),
                        backgroundColor: isDark ? const Color(0xFF252525) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isActive ? const Color(0xFF0F172A) : borderColor,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Filters
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    if (activeTab == 'income' || activeTab == 'matrix')
                      Expanded(
                        child: _buildDropdown(
                          value: period,
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All Time')),
                            DropdownMenuItem(value: 'today', child: Text('Today')),
                            DropdownMenuItem(value: 'week', child: Text('This Week')),
                            DropdownMenuItem(value: 'month', child: Text('This Month')),
                          ],
                          onChanged: (v) => ref.read(leaderboardPeriodProvider.notifier).state = v!,
                          isDark: isDark,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          icon: Icons.calendar_today,
                        ),
                      ),
                    if (activeTab == 'balance')
                      Expanded(
                        child: _buildDropdown(
                          value: balanceType,
                          items: const [
                            DropdownMenuItem(value: 'total', child: Text('Total Balance')),
                            DropdownMenuItem(value: 'voucher', child: Text('Voucher Balance')),
                            DropdownMenuItem(value: 'combined', child: Text('Combined')),
                          ],
                          onChanged: (v) => ref.read(leaderboardBalanceTypeProvider.notifier).state = v!,
                          isDark: isDark,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          icon: Icons.filter_list,
                        ),
                      ),
                    if (activeTab == 'income' || activeTab == 'matrix' || activeTab == 'balance')
                      const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(
                        value: limit.toString(),
                        items: const [
                          DropdownMenuItem(value: '10', child: Text('Top 10')),
                          DropdownMenuItem(value: '25', child: Text('Top 25')),
                          DropdownMenuItem(value: '50', child: Text('Top 50')),
                          DropdownMenuItem(value: '100', child: Text('Top 100')),
                        ],
                        onChanged: (v) => ref.read(leaderboardLimitProvider.notifier).state = int.parse(v!),
                        isDark: isDark,
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        icon: Icons.format_list_numbered,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // List
            leaderboardAsync.when(
              data: (data) {
                final filteredData = searchQuery.isEmpty
                    ? data
                    : data.where((item) {
                        final name = (item['full_name'] ?? '').toString().toLowerCase();
                        final mobile = (item['mobile'] ?? '').toString().toLowerCase();
                        final email = (item['email'] ?? '').toString().toLowerCase();
                        return name.contains(searchQuery) ||
                            mobile.contains(searchQuery) ||
                            email.contains(searchQuery);
                      }).toList();

                if (filteredData.isEmpty) {
                  return SliverFillRemaining(
                    child: _buildEmptyState(isDark, searchQuery.isNotEmpty),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filteredData[index];
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          final delay = (index * 0.05).clamp(0.0, 0.95);
                          final value = (_animationController.value - delay).clamp(0.0, 1.0);
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: _buildLeaderboardCard(
                          item, index, activeTab, isDark, cardColor, textColor, borderColor,
                        ),
                      );
                    },
                    childCount: filteredData.length,
                  ),
                );
              },
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildShimmerCard(isDark, cardColor),
                  childCount: 6,
                ),
              ),
              error: (err, _) => SliverFillRemaining(
                child: _buildErrorState(err.toString(), isDark),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 16, color: textColor),
          dropdownColor: cardColor,
          style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildLeaderboardCard(
    dynamic item,
    int index,
    String activeTab,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color borderColor,
  ) {
    final rankColors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];

    final isTop3 = index < 3;
    final Color rankColor = isTop3
        ? rankColors[index]
        : (isDark ? Colors.grey.shade600 : Colors.grey.shade400);

    final String title = item['full_name'] ?? 'Unknown';
    final String subtitle = item['mobile'] ?? item['email'] ?? '';
    String amount = '';
    String badge = '';
    Color badgeColor = Colors.grey;
    IconData badgeIcon = Icons.paid;

    switch (activeTab) {
      case 'income':
        amount = formatCurrency(item['total_income']);
        badge = 'Income';
        badgeColor = const Color(0xFF0EA5E9);
        badgeIcon = Icons.trending_up;
        break;
      case 'referrals':
        amount = '${item['referral_count'] ?? 0} refs';
        badge = formatCurrency(item['referral_commission']);
        badgeColor = const Color(0xFF22C55E);
        badgeIcon = Icons.people;
        break;
      case 'matrix':
        amount = formatCurrency(item['matrix_income']);
        badge = '${item['matrix_payouts'] ?? 0} payouts';
        badgeColor = const Color(0xFFA855F7);
        badgeIcon = Icons.grid_view;
        break;
      case 'balance':
        amount = formatCurrency(item['total_balance']);
        badge = formatCurrency(item['balance']);
        badgeColor = const Color(0xFFF97316);
        badgeIcon = Icons.account_balance_wallet;
        break;
    }

    final profilePic = item['profile_picture'] as String?;
    final int? userId = item['id'] is int
        ? item['id'] as int
        : int.tryParse(item['id']?.toString() ?? '');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTop3 ? rankColor.withOpacity(0.4) : borderColor,
          width: isTop3 ? 1.5 : 1,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: userId != null ? () => _showUserDetail(context, userId, title) : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Rank
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: rankColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: isTop3 ? Border.all(color: rankColor, width: 2) : null,
                    boxShadow: isTop3
                        ? [BoxShadow(color: rankColor.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)]
                        : null,
                  ),
                  child: Center(
                    child: isTop3
                        ? Icon(
                            index == 0 ? Icons.emoji_events : Icons.military_tech,
                            color: rankColor,
                            size: 22,
                          )
                        : Text(
                            (index + 1).toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.grey.shade400 : Colors.grey[500],
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),

                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isTop3 ? rankColor.withOpacity(0.5) : borderColor,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: profilePic != null && profilePic.isNotEmpty
                        ? Image.network(
                            profilePic,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildFallbackAvatar(title, isDark, rankColor),
                            loadingBuilder: (_, child, progress) =>
                                progress == null ? child : _buildFallbackAvatar(title, isDark, rankColor),
                          )
                        : _buildFallbackAvatar(title, isDark, rankColor),
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item['is_active'] == true)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone_android, size: 12, color: _secondaryTextColor(isDark)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              subtitle,
                              style: TextStyle(fontSize: 12, color: _secondaryTextColor(isDark)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(badgeIcon, size: 11, color: badgeColor),
                            const SizedBox(width: 4),
                            Text(
                              badge,
                              style: TextStyle(
                                color: badgeColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amount,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isTop3 ? rankColor : textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(Icons.arrow_forward_ios, size: 12, color: _secondaryTextColor(isDark)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(String name, bool isDark, Color fallbackColor) {
    return Container(
      color: fallbackColor.withOpacity(0.1),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(fontWeight: FontWeight.bold, color: fallbackColor, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildShimmerCard(bool isDark, Color cardColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      height: 90,
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Shimmer.fromColors(
        baseColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[300]!,
        highlightColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, bool isSearch) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isSearch ? Icons.search_off : Icons.inbox,
          size: 56,
          color: isDark ? Colors.grey.shade700 : Colors.grey[400],
        ),
        const SizedBox(height: 16),
        Text(
          isSearch ? 'No matching users found' : 'No data available',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade400 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error, bool isDark) {
    String message = 'Something went wrong';
    IconData icon = Icons.error_outline;
    if (error.contains('UNAUTHORIZED')) {
      message = 'Please login to view the leaderboard';
      icon = Icons.lock;
    } else if (error.contains('FORBIDDEN')) {
      message = 'Access denied';
      icon = Icons.gpp_bad;
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: isDark ? Colors.red.shade300 : Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade300 : Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF333333) : const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== USER DETAIL BOTTOM SHEET ====================
class _UserDetailBottomSheet extends ConsumerWidget {
  final int userId;
  final String userName;

  const _UserDetailBottomSheet({required this.userId, required this.userName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDetailAsync = ref.watch(userDetailProvider(userId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sheetColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final bgColor = isDark ? const Color(0xFF111111) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final borderColor = isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: sheetColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle + Header
          Container(
            decoration: BoxDecoration(
              color: sheetColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 8, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          userName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh, color: secondaryText, size: 20),
                        onPressed: () => ref.invalidate(userDetailProvider(userId)),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: secondaryText),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: borderColor),
              ],
            ),
          ),

          // Content
          Expanded(
            child: userDetailAsync.when(
              data: (data) {
                final user = data['user'] as Map<String, dynamic>? ?? {};
                final incomeBreakdown = data['income_breakdown'] as List<dynamic>? ?? [];
                final referralCount = data['referral_count'] ?? 0;
                final recentHistory = data['recent_history'] as List<dynamic>? ?? [];

                final profilePic = user['profile_picture'] as String?;
                final isActive = user['is_active'] == true;
                final isVerified = user['id_verified'] == true;
                final isMatrixBlocked = user['is_matrix_blocked'] == true;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Profile Header ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isActive ? const Color(0xFF22C55E) : Colors.grey,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isActive ? const Color(0xFF22C55E) : Colors.grey)
                                        .withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: profilePic != null && profilePic.isNotEmpty
                                    ? Image.network(
                                        profilePic,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _avatarFallback(user['full_name'] ?? '?'),
                                      )
                                    : _avatarFallback(user['full_name'] ?? '?'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['full_name'] ?? 'Unknown',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Status badges
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      _statusBadge('Active', isActive, const Color(0xFF22C55E)),
                                      _statusBadge('Verified', isVerified, const Color(0xFF6366F1)),
                                      if (isMatrixBlocked)
                                        _statusBadge('Matrix Blocked', true, const Color(0xFFEF4444)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'ID: ${user['id'] ?? 'N/A'}',
                                    style: TextStyle(fontSize: 12, color: secondaryText),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Wallet Cards ──
                      Row(
                        children: [
                          Expanded(
                            child: _balanceCard(
                              'Balance',
                              formatCurrency(user['balance']),
                              const Color(0xFF0EA5E9),
                              isDark,
                              Icons.account_balance_wallet,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _balanceCard(
                              'Voucher',
                              formatCurrency(user['voucher_balance']),
                              const Color(0xFF22C55E),
                              isDark,
                              Icons.card_giftcard,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ── Contact Info ──
                      _sectionCard(
                        title: 'Contact Information',
                        icon: Icons.contact_phone,
                        isDark: isDark,
                        bgColor: bgColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        child: Column(
                          children: [
                            _infoRow(Icons.phone_android, 'Mobile', user['mobile'] ?? 'N/A',
                                textColor, secondaryText, isDark, context,
                                copyValue: user['mobile']),
                            _divider(borderColor),
                            _infoRow(Icons.email_outlined, 'Email', user['email'] ?? 'N/A',
                                textColor, secondaryText, isDark, context,
                                copyValue: user['email']),
                            _divider(borderColor),
                            _infoRow(Icons.link, 'Referral Code', user['referral_code'] ?? 'N/A',
                                textColor, secondaryText, isDark, context,
                                copyValue: user['referral_code']),
                            if (user['referred_by'] != null) ...[
                              _divider(borderColor),
                              _infoRow(Icons.person_add, 'Referred By', user['referred_by'],
                                  textColor, secondaryText, isDark, context),
                            ],
                            _divider(borderColor),
                            _infoRow(
                              Icons.calendar_today,
                              'Member Since',
                              user['created_at'] != null
                                  ? DateFormat('dd MMM yyyy, hh:mm a')
                                      .format(DateTime.parse(user['created_at']))
                                  : 'N/A',
                              textColor,
                              secondaryText,
                              isDark,
                              context,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Referral + Matrix Stats ──
                      Row(
                        children: [
                          Expanded(
                            child: _statMiniCard(
                              label: 'Total Referrals',
                              value: referralCount.toString(),
                              icon: Icons.people,
                              color: const Color(0xFF22C55E),
                              isDark: isDark,
                              bgColor: bgColor,
                              borderColor: borderColor,
                              textColor: textColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _statMiniCard(
                              label: 'Matrix Payouts',
                              value: (user['matrix_payout_count'] ?? 0).toString(),
                              icon: Icons.grid_view,
                              color: const Color(0xFFA855F7),
                              isDark: isDark,
                              bgColor: bgColor,
                              borderColor: borderColor,
                              textColor: textColor,
                            ),
                          ),
                        ],
                      ),

                      // ── Income Breakdown ──
                      if (incomeBreakdown.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _sectionCard(
                          title: 'Income Breakdown',
                          icon: Icons.bar_chart,
                          isDark: isDark,
                          bgColor: bgColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          child: Column(
                            children: incomeBreakdown.asMap().entries.map((entry) {
                              final i = entry.key;
                              final income = entry.value;
                              final type = income['type'] ?? 'unknown';
                              final color = type == 'referral'
                                  ? const Color(0xFF22C55E)
                                  : type == 'matrix'
                                      ? const Color(0xFFA855F7)
                                      : const Color(0xFF0EA5E9);
                              return Column(
                                children: [
                                  if (i > 0) _divider(borderColor),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            type.toString().toUpperCase(),
                                            style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
                                          ),
                                        ),
                                        Text(
                                          '${income['count']} txs',
                                          style: TextStyle(fontSize: 12, color: secondaryText),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          formatCurrency(income['total']),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],

                      // ── Recent Transactions ──
                      if (recentHistory.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _sectionCard(
                          title: 'Recent Transactions',
                          icon: Icons.receipt_long,
                          isDark: isDark,
                          bgColor: bgColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          child: Column(
                            children: recentHistory.asMap().entries.map((entry) {
                              final i = entry.key;
                              final tx = entry.value;
                              final isPositive = (tx['amount'] ?? 0) > 0;
                              final color = isPositive
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFEF4444);
                              return Column(
                                children: [
                                  if (i > 0) _divider(borderColor),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                                            size: 14,
                                            color: color,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tx['description'] ?? 'Transaction',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                  color: textColor,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                tx['created_at'] != null
                                                    ? DateFormat('dd MMM yyyy, hh:mm a')
                                                        .format(DateTime.parse(tx['created_at']))
                                                    : '',
                                                style: TextStyle(fontSize: 11, color: secondaryText),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          formatCurrency(tx['amount']),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },

              loading: () => _shimmerDetail(isDark),

              error: (err, _) {
                String message = 'Failed to load user details';
                if (err.toString().contains('NOT_FOUND')) message = 'User not found';
                if (err.toString().contains('UNAUTHORIZED')) message = 'Please login again';
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 56, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(message,
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark ? Colors.grey.shade300 : Colors.grey[700],
                            ),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => ref.invalidate(userDetailProvider(userId)),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──

  Widget _avatarFallback(String name) {
    return Container(
      color: const Color(0xFF0EA5E9).withOpacity(0.15),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF0EA5E9),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String label, bool isActive, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (isActive ? color : Colors.grey).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: isActive ? color : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isActive ? color : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceCard(String label, String value, Color color, bool isDark, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _statMiniCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: color)),
              Text(
                value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required bool isDark,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(icon, size: 16, color: const Color(0xFF0EA5E9)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    Color textColor,
    Color secondaryText,
    bool isDark,
    BuildContext context, {
    String? copyValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: secondaryText),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: secondaryText)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
                ),
              ],
            ),
          ),
          if (copyValue != null)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: copyValue));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Copied!'),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              },
              child: Icon(Icons.copy_outlined, size: 16, color: secondaryText),
            ),
        ],
      ),
    );
  }

  Widget _divider(Color borderColor) {
    return Divider(height: 12, color: borderColor);
  }

  Widget _shimmerDetail(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[300]!,
        highlightColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100]!,
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(3, (i) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 80,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            )),
          ],
        ),
      ),
    );
  }
}

