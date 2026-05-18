import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==================== API CONFIG ====================
const String API_BASE = 'https://api.easysarvice.com/api';

// ==================== PROVIDERS ====================
final leaderboardTabProvider = StateProvider<String>((ref) => 'income');
final leaderboardPeriodProvider = StateProvider<String>((ref) => 'all');
final leaderboardLimitProvider = StateProvider<int>((ref) => 50);

// Helper: Get JWT token from SharedPreferences (same as VendorApplyPage)
Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwt_token');
}

final leaderboardDataProvider = FutureProvider.family<List<dynamic>, String>((ref, tab) async {
  final period = ref.watch(leaderboardPeriodProvider);
  final limit = ref.watch(leaderboardLimitProvider);
  final token = await _getToken();

  if (token == null || token.isEmpty) {
    throw Exception('Please login first. Token not found.');
  }

  String url = '$API_BASE/leaderboard/$tab?limit=$limit';
  if (tab == 'income' || tab == 'matrix') {
    url += '&period=$period';
  }

  final response = await http.get(
    Uri.parse(url),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data'] ?? [];
  }
  throw Exception('Failed to load leaderboard');
});

final leaderboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final token = await _getToken();

  if (token == null || token.isEmpty) {
    throw Exception('Please login first. Token not found.');
  }

  final response = await http.get(
    Uri.parse('$API_BASE/leaderboard/stats'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data'] ?? {};
  }
  throw Exception('Failed to load stats');
});

// ==================== PAGE ====================
class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeTab = ref.watch(leaderboardTabProvider);
    final period = ref.watch(leaderboardPeriodProvider);
    final limit = ref.watch(leaderboardLimitProvider);
    final leaderboardAsync = ref.watch(leaderboardDataProvider(activeTab));
    final statsAsync = ref.watch(leaderboardStatsProvider);

    // Dark/Light colors (same pattern as VendorApplyPage)
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final hintColor = isDark ? Colors.grey.shade500 : Colors.grey.shade400;
    final borderColor = isDark ? const Color(0xFF333333) : Colors.grey.shade200;

    final tabs = [
      {'key': 'income', 'label': 'Top Earners', 'icon': LucideIcons.trophy},
      {'key': 'referrals', 'label': 'Top Referrers', 'icon': LucideIcons.users},
      {'key': 'matrix', 'label': 'Matrix Stars', 'icon': LucideIcons.award},
      {'key': 'balance', 'label': 'Rich List', 'icon': LucideIcons.dollarSign},
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Leaderboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Stats Cards
              statsAsync.when(
                data: (stats) => _buildStatsRow(stats, isDark),
                loading: () => SizedBox(
                  height: 80,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
              // Tab Bar
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
                              ),
                            ),
                          ],
                        ),
                        selected: isActive,
                        onSelected: (_) => ref.read(leaderboardTabProvider.notifier).state = tab['key'] as String,
                        selectedColor: const Color(0xFF0F172A),
                        labelStyle: TextStyle(
                          color: isActive ? Colors.white : secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                        backgroundColor: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: borderColor),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(16),
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
                    ),
                  ),
                if (activeTab == 'income' || activeTab == 'matrix') const SizedBox(width: 12),
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
                  ),
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: leaderboardAsync.when(
              data: (data) => _buildList(data, activeTab, isDark, cardColor, textColor, borderColor),
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.alertCircle, size: 48, color: isDark ? Colors.red.shade300 : Colors.red[300]),
                    const SizedBox(height: 12),
                    Text(
                      'Error: $err',
                      style: TextStyle(color: isDark ? Colors.red.shade300 : Colors.red[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(leaderboardDataProvider(activeTab)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF333333) : const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Helper Widgets ====================

  Widget _buildStatsRow(Map<String, dynamic> stats, bool isDark) {
    final items = [
      {'label': 'Users', 'value': stats['total_users']?.toString() ?? '0', 'color': const Color(0xFF0EA5E9)},
      {'label': 'Active', 'value': stats['active_users']?.toString() ?? '0', 'color': const Color(0xFF22C55E)},
      {'label': 'Verified', 'value': stats['verified_users']?.toString() ?? '0', 'color': const Color(0xFF6366F1)},
      {'label': 'Business', 'value': stats['total_businesses']?.toString() ?? '0', 'color': const Color(0xFFF97316)},
    ];

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: items.map((item) => Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (item['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item['value'] as String,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: item['color'] as Color,
                  ),
                ),
                Text(
                  item['label'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade400 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        )).toList(),
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
          icon: Icon(LucideIcons.chevronDown, size: 18, color: textColor),
          dropdownColor: cardColor,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }

  Widget _buildList(
    List<dynamic> data,
    String activeTab,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color borderColor,
  ) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.inbox, size: 48, color: isDark ? Colors.grey.shade600 : Colors.grey),
            const SizedBox(height: 12),
            Text(
              'No data found for this period',
              style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return _buildLeaderboardCard(item, index, activeTab, isDark, cardColor, textColor, borderColor);
      },
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
      const Color(0xFFFFD700), // Gold
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFCD7F32), // Bronze
    ];

    final isTop3 = index < 3;
    final rankColor = isTop3
        ? rankColors[index]
        : (isDark ? Colors.grey.shade600 : Colors.grey[300]);

    String title = item['full_name'] ?? 'Unknown';
    String subtitle = item['mobile'] ?? item['email'] ?? '';
    String amount = '';
    String badge = '';
    Color badgeColor = Colors.grey;

    switch (activeTab) {
      case 'income':
        amount = '?${(item['total_income'] ?? 0).toString()}';
        badge = 'Income';
        badgeColor = const Color(0xFF0EA5E9);
        break;
      case 'referrals':
        amount = '${(item['referral_count'] ?? 0).toString()} refs';
        badge = 'Commission: ?${(item['referral_commission'] ?? 0).toString()}';
        badgeColor = const Color(0xFF22C55E);
        break;
      case 'matrix':
        amount = '?${(item['matrix_income'] ?? 0).toString()}';
        badge = '${(item['matrix_payouts'] ?? 0).toString()} payouts';
        badgeColor = const Color(0xFFA855F7);
        break;
      case 'balance':
        amount = '?${(item['total_balance'] ?? 0).toString()}';
        badge = 'Balance: ?${(item['balance'] ?? 0).toString()}';
        badgeColor = const Color(0xFFF97316);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTop3 ? rankColor.withOpacity(0.5) : borderColor,
          width: isTop3 ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: rankColor.withOpacity(0.15),
            shape: BoxShape.circle,
            border: isTop3 ? Border.all(color: rankColor, width: 2) : null,
          ),
          child: Center(
            child: isTop3
                ? Icon(
                    index == 0 ? LucideIcons.crown : LucideIcons.medal,
                    color: rankColor,
                    size: 22,
                  )
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey.shade400 : Colors.grey[500],
                    ),
                  ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: textColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade400 : Colors.grey[500],
          ),
        ),
        trailing: Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isTop3 ? rankColor : textColor,
          ),
        ),
      ),
    );
  }
}
