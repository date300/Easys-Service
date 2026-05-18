import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
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

// Helper: Get JWT token from SharedPreferences
Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwt_token');
}

// Helper: Format currency
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

// Helper: Format number
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

  if (token == null || token.isEmpty) {
    throw Exception('UNAUTHORIZED');
  }

  String url = '\$API_BASE/leaderboard/\$tab?limit=\$limit';
  if (tab == 'income' || tab == 'matrix') {
    url += '&period=\$period';
  }
  if (tab == 'balance') {
    url += '&type=\$balanceType';
  }

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer \$token',
      'Content-Type': 'application/json',
    },
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

  if (token == null || token.isEmpty) {
    throw Exception('UNAUTHORIZED');
  }

  final response = await http.get(
    Uri.parse('\$API_BASE/leaderboard/stats'),
    headers: {
      'Authorization': 'Bearer \$token',
      'Content-Type': 'application/json',
    },
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
  if (token == null || token.isEmpty) {
    throw Exception('UNAUTHORIZED');
  }

  final response = await http.get(
    Uri.parse('\$API_BASE/leaderboard/user/\$userId'),
    headers: {
      'Authorization': 'Bearer \$token',
      'Content-Type': 'application/json',
    },
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
    ref.invalidate(leaderboardDataProvider(ref.read(leaderboardTabProvider)));
    ref.invalidate(leaderboardStatsProvider);
  }

  void _showUserDetail(BuildContext context, int userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserDetailBottomSheet(userId: userId),
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
    final statsAsync = ref.watch(leaderboardStatsProvider);

    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
        isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final borderColor =
        isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200;

    final tabs = [
      {'key': 'income', 'label': 'Top Earners', 'icon': LucideIcons.trophy},
      {'key': 'referrals', 'label': 'Referrers', 'icon': LucideIcons.users},
      {'key': 'matrix', 'label': 'Matrix', 'icon': LucideIcons.layoutGrid},
      {'key': 'balance', 'label': 'Balance', 'icon': LucideIcons.wallet},
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
            // Stats Section
            SliverToBoxAdapter(
              child: statsAsync.when(
                data: (stats) => _buildStatsSection(stats, isDark, cardColor),
                loading: () => _buildStatsShimmer(isDark),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
                      hintText: 'Search by name or mobile...',
                      hintStyle: TextStyle(color: secondaryTextColor),
                      prefixIcon:
                          Icon(LucideIcons.search, color: secondaryTextColor),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(LucideIcons.x,
                                  color: secondaryTextColor, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(leaderboardSearchProvider.notifier)
                                    .state = '';
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tabs.length,
                  itemBuilder: (context, index) {
                    final tab = tabs[index];
                    final isActive = activeTab == tab['key'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                tab['icon'] as IconData,
                                size: 16,
                                color: isActive
                                    ? Colors.white
                                    : secondaryTextColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                tab['label'] as String,
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : secondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          selected: isActive,
                          onSelected: (_) {
                            ref.read(leaderboardTabProvider.notifier).state =
                                tab['key'] as String;
                            _animationController.reset();
                            _animationController.forward();
                          },
                          selectedColor: const Color(0xFF0F172A),
                          backgroundColor:
                              isDark ? const Color(0xFF252525) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isActive
                                  ? const Color(0xFF0F172A)
                                  : borderColor,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
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
                            DropdownMenuItem(
                                value: 'all', child: Text('All Time')),
                            DropdownMenuItem(
                                value: 'today', child: Text('Today')),
                            DropdownMenuItem(
                                value: 'week', child: Text('This Week')),
                            DropdownMenuItem(
                                value: 'month', child: Text('This Month')),
                          ],
                          onChanged: (v) => ref
                              .read(leaderboardPeriodProvider.notifier)
                              .state = v!,
                          isDark: isDark,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          icon: LucideIcons.calendar,
                        ),
                      ),
                    if (activeTab == 'balance')
                      Expanded(
                        child: _buildDropdown(
                          value: balanceType,
                          items: const [
                            DropdownMenuItem(
                                value: 'total', child: Text('Total Balance')),
                            DropdownMenuItem(
                                value: 'voucher',
                                child: Text('Voucher Balance')),
                            DropdownMenuItem(
                                value: 'combined',
                                child: Text('Combined')),
                          ],
                          onChanged: (v) => ref
                              .read(leaderboardBalanceTypeProvider.notifier)
                              .state = v!,
                          isDark: isDark,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          icon: LucideIcons.filter,
                        ),
                      ),
                    if (activeTab == 'income' ||
                        activeTab == 'matrix' ||
                        activeTab == 'balance')
                      const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(
                        value: limit.toString(),
                        items: const [
                          DropdownMenuItem(
                              value: '10', child: Text('Top 10')),
                          DropdownMenuItem(
                              value: '25', child: Text('Top 25')),
                          DropdownMenuItem(
                              value: '50', child: Text('Top 50')),
                          DropdownMenuItem(
                              value: '100', child: Text('Top 100')),
                        ],
                        onChanged: (v) => ref
                            .read(leaderboardLimitProvider.notifier)
                            .state = int.parse(v!),
                        isDark: isDark,
                        cardColor: cardColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        icon: LucideIcons.listFilter,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // List Content
            leaderboardAsync.when(
              data: (data) {
                final filteredData = searchQuery.isEmpty
                    ? data
                    : data.where((item) {
                        final name =
                            (item['full_name'] ?? '').toString().toLowerCase();
                        final mobile =
                            (item['mobile'] ?? '').toString().toLowerCase();
                        final email =
                            (item['email'] ?? '').toString().toLowerCase();
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
                          final delay = index * 0.05;
                          final value = (_animationController.value - delay)
                              .clamp(0.0, 1.0);
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          );
                        },
                        child: _buildLeaderboardCard(
                          item,
                          index,
                          activeTab,
                          isDark,
                          cardColor,
                          textColor,
                          borderColor,
                          () => _showUserDetail(
                              context, item['id'] as int),
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

  // ==================== Stats Section ====================
  Widget _buildStatsSection(
      Map<String, dynamic> stats, bool isDark, Color cardColor) {
    final items = [
      {
        'label': 'Total Users',
        'value': formatNumber(stats['total_users']),
        'icon': LucideIcons.users,
        'color': const Color(0xFF0EA5E9),
        'bgColor': const Color(0xFF0EA5E9).withOpacity(0.1),
      },
      {
        'label': 'Total Balance',
        'value': formatCurrency(stats['total_balance']),
        'icon': LucideIcons.wallet,
        'color': const Color(0xFF22C55E),
        'bgColor': const Color(0xFF22C55E).withOpacity(0.1),
      },
      {
        'label': 'Referral Payouts',
        'value': formatCurrency(stats['total_referral_payouts']),
        'icon': LucideIcons.arrowLeftRight,
        'color': const Color(0xFF6366F1),
        'bgColor': const Color(0xFF6366F1).withOpacity(0.1),
      },
      {
        'label': 'Matrix Payouts',
        'value': formatCurrency(stats['total_matrix_payouts']),
        'icon': LucideIcons.layoutGrid,
        'color': const Color(0xFFF97316),
        'bgColor': const Color(0xFFF97316).withOpacity(0.1),
      },
    ];

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: items
            .map((item) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? (item['bgColor'] as Color).withOpacity(0.15)
                          : item['bgColor'] as Color,
                      borderRadius: BorderRadius.circular(16),
                      border: isDark
                          ? Border.all(
                              color: (item['color'] as Color).withOpacity(0.3))
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              size: 14,
                              color: item['color'] as Color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['value'] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: item['color'] as Color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildStatsShimmer(bool isDark) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: List.generate(
          4,
          (index) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Shimmer.fromColors(
                baseColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[300]!,
                highlightColor:
                    isDark ? const Color(0xFF2A2A2A) : Colors.grey[100]!,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== Dropdown ====================
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
          icon: Icon(LucideIcons.chevronDown, size: 16, color: textColor),
          dropdownColor: cardColor,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ==================== Leaderboard Card ====================
  Widget _buildLeaderboardCard(
    dynamic item,
    int index,
    String activeTab,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color borderColor,
    VoidCallback onTap,
  ) {
    final rankColors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFCD7F32), // Bronze
    ];

    final isTop3 = index < 3;
    final Color rankColor = isTop3
        ? rankColors[index]
        : (isDark ? Colors.grey.shade600 : Colors.grey.shade400);

    String title = item['full_name'] ?? 'Unknown';
    String subtitle = item['mobile'] ?? item['email'] ?? '';
    String amount = '';
    String badge = '';
    Color badgeColor = Colors.grey;
    IconData badgeIcon = LucideIcons.circleDollarSign;

    switch (activeTab) {
      case 'income':
        amount = formatCurrency(item['total_income']);
        badge = 'Income';
        badgeColor = const Color(0xFF0EA5E9);
        badgeIcon = LucideIcons.trendingUp;
        break;
      case 'referrals':
        amount = '\${item['referral_count'] ?? 0} refs';
        badge = formatCurrency(item['referral_commission']);
        badgeColor = const Color(0xFF22C55E);
        badgeIcon = LucideIcons.users;
        break;
      case 'matrix':
        amount = formatCurrency(item['matrix_income']);
        badge = '\${item['matrix_payouts'] ?? 0} payouts';
        badgeColor = const Color(0xFFA855F7);
        badgeIcon = LucideIcons.layoutGrid;
        break;
      case 'balance':
        amount = formatCurrency(item['total_balance']);
        badge = formatCurrency(item['balance']);
        badgeColor = const Color(0xFFF97316);
        badgeIcon = LucideIcons.wallet;
        break;
    }

    final profilePic = item['profile_picture'] as String?;

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
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Rank Badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: rankColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: isTop3
                        ? Border.all(color: rankColor, width: 2)
                        : null,
                    boxShadow: isTop3
                        ? [
                            BoxShadow(
                              color: rankColor.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isTop3
                        ? Icon(
                            index == 0 ? LucideIcons.crown : LucideIcons.medal,
                            color: rankColor,
                            size: 22,
                          )
                        : Text(
                            '\${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey[500],
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
                            errorBuilder: (_, __, ___) => _buildFallbackAvatar(
                                title, isDark, rankColor),
                            loadingBuilder: (_, child, progress) =>
                                progress == null
                                    ? child
                                    : _buildFallbackAvatar(
                                        title, isDark, rankColor),
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
                          Icon(
                            LucideIcons.smartphone,
                            size: 12,
                            color: _secondaryTextColor(isDark),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: _secondaryTextColor(isDark),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
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
                Text(
                  amount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isTop3 ? rankColor : textColor,
                  ),
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: fallbackColor,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard(bool isDark, Color cardColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      height: 90,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
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
          isSearch ? LucideIcons.searchX : LucideIcons.inbox,
          size: 56,
          color: isDark ? Colors.grey.shade700 : Colors.grey[400],
        ),
        const SizedBox(height: 16),
        Text(
          isSearch ? 'No results found' : 'No data available',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade400 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isSearch
              ? 'Try adjusting your search query'
              : 'Check back later for updates',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade600 : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error, bool isDark) {
    String message = 'Something went wrong';
    IconData icon = LucideIcons.alertCircle;

    if (error.contains('UNAUTHORIZED')) {
      message = 'Session expired. Please login again.';
      icon = LucideIcons.lock;
    } else if (error.contains('FORBIDDEN')) {
      message = 'Admin access required';
      icon = LucideIcons.shieldAlert;
    } else if (error.contains('NOT_FOUND')) {
      message = 'User not found';
      icon = LucideIcons.userX;
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 56,
            color: isDark ? Colors.red.shade300 : Colors.red[300],
          ),
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
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? const Color(0xFF333333) : const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== User Detail Bottom Sheet ====================
class UserDetailBottomSheet extends ConsumerWidget {
  final int userId;

  const UserDetailBottomSheet({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDetailAsync = ref.watch(userDetailProvider(userId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return userDetailAsync.when(
            data: (data) {
              final user = data['user'] as Map<String, dynamic>? ?? {};
              final incomeBreakdown =
                  data['income_breakdown'] as List<dynamic>? ?? [];
              final referralCount = data['referral_count'] ?? 0;
              final recentHistory =
                  data['recent_history'] as List<dynamic>? ?? [];

              return Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade700 : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: user['is_active'] == true
                                  ? const Color(0xFF22C55E)
                                  : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: user['profile_picture'] != null
                                ? Image.network(
                                    user['profile_picture'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildAvatarFallback(
                                            user['full_name'] ?? '?', textColor),
                                  )
                                : _buildAvatarFallback(
                                    user['full_name'] ?? '?', textColor),
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _buildStatusBadge(
                                    'Active',
                                    user['is_active'] == true,
                                    const Color(0xFF22C55E),
                                  ),
                                  const SizedBox(width: 6),
                                  _buildStatusBadge(
                                    'Verified',
                                    user['id_verified'] == true,
                                    const Color(0xFF6366F1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(LucideIcons.x, color: secondaryText),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Divider(color: isDark ? Colors.grey.shade800 : Colors.grey[200]),
                  const SizedBox(height: 8),

                  // Scrollable Content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        // Contact Info
                        _buildSectionTitle('Contact Information', isDark),
                        const SizedBox(height: 8),
                        _buildInfoTile(
                          icon: LucideIcons.smartphone,
                          label: 'Mobile',
                          value: user['mobile'] ?? 'N/A',
                          isDark: isDark,
                          onCopy: () => _copyToClipboard(context, user['mobile']),
                        ),
                        _buildInfoTile(
                          icon: LucideIcons.mail,
                          label: 'Email',
                          value: user['email'] ?? 'N/A',
                          isDark: isDark,
                          onCopy: () => _copyToClipboard(context, user['email']),
                        ),
                        _buildInfoTile(
                          icon: LucideIcons.link,
                          label: 'Referral Code',
                          value: user['referral_code'] ?? 'N/A',
                          isDark: isDark,
                          onCopy: () =>
                              _copyToClipboard(context, user['referral_code']),
                        ),
                        _buildInfoTile(
                          icon: LucideIcons.calendar,
                          label: 'Member Since',
                          value: user['created_at'] != null
                              ? DateFormat('MMM dd, yyyy').format(
                                  DateTime.parse(user['created_at']))
                              : 'N/A',
                          isDark: isDark,
                        ),

                        const SizedBox(height: 20),

                        // Balance Cards
                        _buildSectionTitle('Wallet Overview', isDark),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildBalanceCard(
                                'Balance',
                                formatCurrency(user['balance']),
                                const Color(0xFF0EA5E9),
                                isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildBalanceCard(
                                'Voucher',
                                formatCurrency(user['voucher_balance']),
                                const Color(0xFF22C55E),
                                isDark,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Income Breakdown
                        if (incomeBreakdown.isNotEmpty) ...[
                          _buildSectionTitle('Income Breakdown', isDark),
                          const SizedBox(height: 12),
                          ...incomeBreakdown.map((income) {
                            final type = income['type'] ?? 'unknown';
                            final color = type == 'referral'
                                ? const Color(0xFF22C55E)
                                : type == 'matrix'
                                    ? const Color(0xFFA855F7)
                                    : const Color(0xFF0EA5E9);
                            return _buildIncomeRow(
                              type.toString().toUpperCase(),
                              formatCurrency(income['total']),
                              '\${income['count']} txs',
                              color,
                              isDark,
                            );
                          }),
                          const SizedBox(height: 20),
                        ],

                        // Referral Count
                        _buildSectionTitle('Referral Stats', isDark),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF252525)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22C55E).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  LucideIcons.users,
                                  color: Color(0xFF22C55E),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Referrals',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: secondaryText,
                                      ),
                                    ),
                                    Text(
                                      '\$referralCount',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Recent History
                        if (recentHistory.isNotEmpty) ...[
                          _buildSectionTitle('Recent Transactions', isDark),
                          const SizedBox(height: 12),
                          ...recentHistory.map((tx) {
                            final isPositive = (tx['amount'] ?? 0) > 0;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF252525)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF333333)
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isPositive
                                          ? const Color(0xFF22C55E).withOpacity(0.1)
                                          : const Color(0xFFEF4444)
                                              .withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isPositive
                                          ? LucideIcons.arrowDownLeft
                                          : LucideIcons.arrowUpRight,
                                      size: 16,
                                      color: isPositive
                                          ? const Color(0xFF22C55E)
                                          : const Color(0xFFEF4444),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              ? DateFormat('MMM dd, hh:mm a')
                                                  .format(DateTime.parse(
                                                      tx['created_at']))
                                              : '',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    formatCurrency(tx['amount']),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isPositive
                                          ? const Color(0xFF22C55E)
                                          : const Color(0xFFEF4444),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => _buildDetailShimmer(isDark),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.alertCircle,
                        size: 48,
                        color: isDark ? Colors.red.shade300 : Colors.red[300]),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load user details',
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarFallback(String name, Color textColor) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, bool isActive, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
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

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    VoidCallback? onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isDark ? Colors.grey.shade500 : Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade500 : Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              icon: Icon(LucideIcons.copy, size: 16, color: isDark ? Colors.grey.shade500 : Colors.grey[600]),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
      String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeRow(
      String type, String amount, String count, Color color, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              type,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          Text(
            count,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade500 : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[300]!,
      highlightColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 150,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String? text) {
    if (text == null || text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

