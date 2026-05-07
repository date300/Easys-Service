import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../wallet_page.dart'; // WalletApiService, Transaction

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});
  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  static const Color _accent = Color(0xFF29B6F6);
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _error;
  String _token = '';
  int _offset = 0;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitial();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoading &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token') ?? '';
    if (_token.isEmpty) {
      setState(() { _error = 'Token missing'; _isLoading = false; });
      return;
    }
    await _fetchTransactions(reset: true);
  }

  Future<void> _fetchTransactions({bool reset = false}) async {
    if (reset) {
      _offset = 0;
      _hasMore = true;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final newList = await WalletApiService.fetchTransactions(
        _token,
        limit: 20,
        offset: _offset,
      );
      if (mounted) {
        setState(() {
          if (reset) _transactions = newList;
          else _transactions.addAll(newList);
          _offset += newList.length;
          _hasMore = newList.length == 20;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    await _fetchTransactions();
  }

  Future<void> _refresh() async {
    await _fetchTransactions(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      body: _isLoading && _transactions.isEmpty
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : RefreshIndicator(
              onRefresh: _refresh,
              color: _accent,
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                itemCount: _transactions.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _transactions.length) {
                    return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()));
                  }
                  final t = _transactions[index];
                  return Card(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    margin: EdgeInsets.only(bottom: 10.h),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                      side: BorderSide(color: _accent.withOpacity(0.1)),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                      leading: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(color: _accent.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(CupertinoIcons.doc_text_fill, color: _accent, size: 20.sp),
                      ),
                      title: Text(t.description, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13.sp)),
                      subtitle: Text(_formatDate(t.createdAt), style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey)),
                      trailing: Text(
                        '\$${t.amount.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15.sp, color: _accent),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}
