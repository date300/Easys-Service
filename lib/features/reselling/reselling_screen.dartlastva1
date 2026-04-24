import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─── Data Models ────────────────────────────────────────────
class ProductModel {
  final String id;
  final String title;
  final String image;
  final double wholesalePrice;
  final double maxResalePrice;
  final String category;
  final double rating;
  final int totalSold;
  bool isReselling;
  double myMargin;

  ProductModel({
    required this.id,
    required this.title,
    required this.image,
    required this.wholesalePrice,
    required this.maxResalePrice,
    required this.category,
    required this.rating,
    required this.totalSold,
    this.isReselling = false,
    this.myMargin = 0,
  });

  double get myPrice => wholesalePrice + myMargin;
  double get maxMargin => maxResalePrice - wholesalePrice;
}

// ─── Dummy Data ──────────────────────────────────────────────
final List<ProductModel> _dummyProducts = [
  ProductModel(
    id: '1',
    title: 'প্রিমিয়াম কটন শাড়ি',
    image: 'https://via.placeholder.com/300x300/FF6B6B/FFFFFF?text=শাড়ি',
    wholesalePrice: 850,
    maxResalePrice: 1400,
    category: 'পোশাক',
    rating: 4.8,
    totalSold: 234,
  ),
  ProductModel(
    id: '2',
    title: 'হাতব্যাগ লেদার কালেকশন',
    image: 'https://via.placeholder.com/300x300/4ECDC4/FFFFFF?text=ব্যাগ',
    wholesalePrice: 650,
    maxResalePrice: 1100,
    category: 'ব্যাগ',
    rating: 4.5,
    totalSold: 189,
  ),
  ProductModel(
    id: '3',
    title: 'অর্গানিক স্কিনকেয়ার সেট',
    image: 'https://via.placeholder.com/300x300/A8E6CF/FFFFFF?text=স্কিন',
    wholesalePrice: 1200,
    maxResalePrice: 1900,
    category: 'বিউটি',
    rating: 4.9,
    totalSold: 312,
  ),
  ProductModel(
    id: '4',
    title: 'ব্লুটুথ হেডফোন Pro',
    image: 'https://via.placeholder.com/300x300/6C5CE7/FFFFFF?text=হেডফোন',
    wholesalePrice: 1500,
    maxResalePrice: 2500,
    category: 'ইলেকট্রনিক্স',
    rating: 4.7,
    totalSold: 156,
  ),
  ProductModel(
    id: '5',
    title: 'কিচেন স্টার্টার কিট',
    image: 'https://via.placeholder.com/300x300/FD79A8/FFFFFF?text=কিচেন',
    wholesalePrice: 780,
    maxResalePrice: 1300,
    category: 'গৃহস্থালি',
    rating: 4.6,
    totalSold: 98,
  ),
  ProductModel(
    id: '6',
    title: 'পুরুষ পারফিউম সেট',
    image: 'https://via.placeholder.com/300x300/FDCB6E/FFFFFF?text=পারফিউম',
    wholesalePrice: 900,
    maxResalePrice: 1600,
    category: 'বিউটি',
    rating: 4.4,
    totalSold: 267,
  ),
];

const List<String> _categories = [
  'সব', 'পোশাক', 'ব্যাগ', 'বিউটি', 'ইলেকট্রনিক্স', 'গৃহস্থালি',
];

// ─── Main Screen ─────────────────────────────────────────────
class ResellingScreen extends StatefulWidget {
  const ResellingScreen({super.key});

  @override
  State<ResellingScreen> createState() => _ResellingScreenState();
}

class _ResellingScreenState extends State<ResellingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'সব';
  String _searchQuery = '';

  // Wallet stats (dummy)
  final double _walletBalance = 4750;
  final double _todayEarning = 320;
  final int _totalOrders = 18;

  List<ProductModel> get _filteredProducts {
    return _dummyProducts.where((p) {
      final matchCat =
          _selectedCategory == 'সব' || p.category == _selectedCategory;
      final matchSearch =
          p.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

  List<ProductModel> get _myResells =>
      _dummyProducts.where((p) => p.isReselling).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Margin Bottom Sheet ──────────────────────────────────────
  void _showMarginSheet(BuildContext context, ProductModel product) {
    double margin = product.myMargin > 0 ? product.myMargin : 50;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final myPrice = product.wholesalePrice + margin;
            final profit = margin;
            final maxMargin = product.maxMargin;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w,
                  MediaQuery.of(context).viewInsets.bottom + 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Product title
                  Text(
                    product.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'মার্জিন নির্ধারণ করুন',
                    style: GoogleFonts.poppins(
                        fontSize: 12.sp, color: Colors.grey[500]),
                  ),
                  SizedBox(height: 20.h),

                  // Price info row
                  Row(
                    children: [
                      _PriceInfoBox(
                        label: 'পাইকারি মূল্য',
                        amount: product.wholesalePrice,
                        color: Colors.blue.shade50,
                        textColor: Colors.blue.shade700,
                      ),
                      SizedBox(width: 8.w),
                      _PriceInfoBox(
                        label: 'আপনার মূল্য',
                        amount: myPrice,
                        color: Colors.green.shade50,
                        textColor: Colors.green.shade700,
                        highlight: true,
                      ),
                      SizedBox(width: 8.w),
                      _PriceInfoBox(
                        label: 'সর্বোচ্চ মূল্য',
                        amount: product.maxResalePrice,
                        color: Colors.orange.shade50,
                        textColor: Colors.orange.shade700,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Profit badge
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C566).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                          color: const Color(0xFF00C566).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.trending_up_rounded,
                            color: const Color(0xFF00C566), size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'আপনার লাভ: ৳${profit.toStringAsFixed(0)} টাকা প্রতি অর্ডারে',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00C566),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('মার্জিন',
                          style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500)),
                      Text('৳${margin.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6C5CE7))),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF6C5CE7),
                      thumbColor: const Color(0xFF6C5CE7),
                      inactiveTrackColor: Colors.grey[200],
                      overlayColor:
                          const Color(0xFF6C5CE7).withOpacity(0.2),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      min: 10,
                      max: maxMargin,
                      value: margin.clamp(10, maxMargin),
                      divisions: ((maxMargin - 10) / 10).round(),
                      onChanged: (val) =>
                          setSheetState(() => margin = val),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('৳10',
                          style: GoogleFonts.poppins(
                              fontSize: 11.sp, color: Colors.grey)),
                      Text('৳${maxMargin.toStringAsFixed(0)} (সর্বোচ্চ)',
                          style: GoogleFonts.poppins(
                              fontSize: 11.sp, color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, size: 16.sp),
                          label: Text('বাতিল',
                              style: GoogleFonts.poppins(fontSize: 13.sp)),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              product.isReselling = true;
                              product.myMargin = margin;
                            });
                            Navigator.pop(context);
                            _showShareLink(context, product);
                          },
                          icon: Icon(Icons.share_rounded, size: 16.sp),
                          label: Text('সেভ ও শেয়ার করুন',
                              style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C5CE7),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Share Link Dialog ────────────────────────────────────────
  void _showShareLink(BuildContext context, ProductModel product) {
    final fakeLink =
        'https://resellerapp.com/p/${product.id}?ref=MY_REF_CODE&price=${product.myPrice.toInt()}';

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C566).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded,
                    color: const Color(0xFF00C566), size: 36.sp),
              ),
              SizedBox(height: 12.h),
              Text('লিংক তৈরি হয়েছে!',
                  style: GoogleFonts.poppins(
                      fontSize: 16.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 4.h),
              Text(
                'আপনার রিসেলিং লিংক প্রস্তুত। এখন শেয়ার করুন।',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 12.sp, color: Colors.grey[500]),
              ),
              SizedBox(height: 16.h),

              // Link box
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        fakeLink,
                        style: GoogleFonts.poppins(
                            fontSize: 10.sp, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: fakeLink));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('লিংক কপি হয়েছে!',
                                style: GoogleFonts.poppins(fontSize: 12.sp)),
                            backgroundColor: const Color(0xFF00C566),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Icon(Icons.copy_rounded,
                          size: 18.sp, color: const Color(0xFF6C5CE7)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Share platforms
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ShareIcon(
                      icon: Icons.facebook_rounded,
                      label: 'Facebook',
                      color: const Color(0xFF1877F2)),
                  SizedBox(width: 16.w),
                  _ShareIcon(
                      icon: Icons.chat_rounded,
                      label: 'WhatsApp',
                      color: const Color(0xFF25D366)),
                  SizedBox(width: 16.w),
                  _ShareIcon(
                      icon: Icons.link_rounded,
                      label: 'Copy',
                      color: const Color(0xFF6C5CE7)),
                ],
              ),
              SizedBox(height: 16.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                  child: Text('ঠিক আছে',
                      style: GoogleFonts.poppins(
                          fontSize: 14.sp, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildEarningsSummary()),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildCategoryFilter()),
          SliverToBoxAdapter(child: _buildTabBar()),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProductsTab(),
            _buildMyResellsTab(),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('রিসেলিং মার্কেট',
                  style: GoogleFonts.poppins(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3436))),
              Text('পণ্য বেছে নিন, শেয়ার করুন, আয় করুন',
                  style: GoogleFonts.poppins(
                      fontSize: 12.sp, color: Colors.grey[500])),
            ],
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.notifications_none_rounded,
                    size: 26.sp, color: const Color(0xFF2D3436)),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Earnings Summary ─────────────────────────────────────────
  Widget _buildEarningsSummary() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFF8E7CF3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: 'ওয়ালেট ব্যালেন্স',
              value: '৳${_walletBalance.toStringAsFixed(0)}',
              icon: Icons.account_balance_wallet_rounded,
            ),
          ),
          Container(width: 1, height: 40.h, color: Colors.white24),
          Expanded(
            child: _StatItem(
              label: 'আজকের আয়',
              value: '৳${_todayEarning.toStringAsFixed(0)}',
              icon: Icons.trending_up_rounded,
            ),
          ),
          Container(width: 1, height: 40.h, color: Colors.white24),
          Expanded(
            child: _StatItem(
              label: 'মোট অর্ডার',
              value: '$_totalOrders টি',
              icon: Icons.shopping_bag_rounded,
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ───────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: GoogleFonts.poppins(fontSize: 13.sp),
        decoration: InputDecoration(
          hintText: 'পণ্য খুঁজুন...',
          hintStyle: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey),
          prefixIcon:
              Icon(Icons.search_rounded, color: Colors.grey, size: 20.sp),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: Icon(Icons.close_rounded,
                      color: Colors.grey, size: 18.sp),
                )
              : Icon(Icons.tune_rounded,
                  color: const Color(0xFF6C5CE7), size: 20.sp),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }

  // ── Category Filter ──────────────────────────────────────────
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final selected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF6C5CE7)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF6C5CE7)
                      : Colors.grey.shade200,
                ),
              ),
              child: Text(
                cat,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Tab Bar ──────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TabBar(
        controller: _tabController,
        labelStyle: GoogleFonts.poppins(
            fontSize: 13.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w400),
        labelColor: const Color(0xFF6C5CE7),
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          color: const Color(0xFF6C5CE7).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'সব পণ্য (${_filteredProducts.length})'),
          Tab(text: 'আমার রিসেল (${_myResells.length})'),
        ],
      ),
    );
  }

  // ── Products Tab ─────────────────────────────────────────────
  Widget _buildProductsTab() {
    final products = _filteredProducts;
    if (products.isEmpty) return _buildEmptyState();

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.68,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => _ProductCard(
        product: products[i],
        onSetMargin: () => _showMarginSheet(context, products[i]),
      ),
    );
  }

  // ── My Resells Tab ───────────────────────────────────────────
  Widget _buildMyResellsTab() {
    if (_myResells.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64.sp, color: Colors.grey[300]),
            SizedBox(height: 12.h),
            Text('এখনো কোনো পণ্য রিসেল করছেন না',
                style: GoogleFonts.poppins(
                    fontSize: 14.sp, color: Colors.grey[400])),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () => _tabController.animateTo(0),
              child: Text('পণ্য বেছে নিন',
                  style: GoogleFonts.poppins(
                      color: const Color(0xFF6C5CE7),
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      itemCount: _myResells.length,
      itemBuilder: (_, i) => _ActiveResellCard(
        product: _myResells[i],
        onShare: () => _showShareLink(context, _myResells[i]),
        onEdit: () => _showMarginSheet(context, _myResells[i]),
        onStop: () => setState(() => _myResells[i].isReselling = false),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 12.h),
          Text('কোনো পণ্য পাওয়া যায়নি',
              style: GoogleFonts.poppins(
                  fontSize: 14.sp, color: Colors.grey[400])),
        ],
      ),
    );
  }
}

// ─── Product Card Widget ──────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onSetMargin;

  const _ProductCard({required this.product, required this.onSetMargin});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16.r)),
                child: Container(
                  height: 130.h,
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: Icon(Icons.image_not_supported_outlined,
                      color: Colors.grey[300], size: 40.sp),
                ),
              ),
              if (product.isReselling)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C566),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text('রিসেলিং',
                        style: GoogleFonts.poppins(
                            fontSize: 9.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded,
                          color: Colors.amber, size: 11.sp),
                      SizedBox(width: 2.w),
                      Text(product.rating.toString(),
                          style: GoogleFonts.poppins(fontSize: 9.sp)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: GoogleFonts.poppins(
                      fontSize: 12.sp, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),

                // Price row
                Row(
                  children: [
                    Icon(Icons.storefront_rounded,
                        size: 11.sp, color: Colors.grey),
                    SizedBox(width: 3.w),
                    Text('৳${product.wholesalePrice.toInt()}',
                        style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.grey[500])),
                    const Spacer(),
                    Text(
                      '+৳${product.maxMargin.toInt()} লাভ',
                      style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: const Color(0xFF00C566),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text('${product.totalSold} বার বিক্রি',
                    style: GoogleFonts.poppins(
                        fontSize: 10.sp, color: Colors.grey[400])),
                SizedBox(height: 8.h),

                // Button
                GestureDetector(
                  onTap: onSetMargin,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: product.isReselling
                          ? const Color(0xFF00C566)
                          : const Color(0xFF6C5CE7),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          product.isReselling
                              ? Icons.share_rounded
                              : Icons.add_shopping_cart_rounded,
                          color: Colors.white,
                          size: 13.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          product.isReselling ? 'শেয়ার করুন' : 'রিসেল করুন',
                          style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Active Resell Card ───────────────────────────────────────
class _ActiveResellCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onShare;
  final VoidCallback onEdit;
  final VoidCallback onStop;

  const _ActiveResellCard({
    required this.product,
    required this.onShare,
    required this.onEdit,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.image_not_supported_outlined,
                color: Colors.grey[300], size: 28.sp),
          ),
          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: GoogleFonts.poppins(
                      fontSize: 13.sp, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text('আমার মূল্য: ',
                        style: GoogleFonts.poppins(
                            fontSize: 11.sp, color: Colors.grey[500])),
                    Text('৳${product.myPrice.toInt()}',
                        style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6C5CE7))),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C566).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'লাভ ৳${product.myMargin.toInt()}',
                        style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: const Color(0xFF00C566),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _MiniButton(
                        icon: Icons.share_rounded,
                        label: 'শেয়ার',
                        color: const Color(0xFF6C5CE7),
                        onTap: onShare),
                    SizedBox(width: 6.w),
                    _MiniButton(
                        icon: Icons.edit_rounded,
                        label: 'এডিট',
                        color: Colors.orange,
                        onTap: onEdit),
                    SizedBox(width: 6.w),
                    _MiniButton(
                        icon: Icons.stop_circle_outlined,
                        label: 'বন্ধ',
                        color: Colors.red,
                        onTap: onStop),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Small Helpers ────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18.sp),
        SizedBox(height: 4.h),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text(label,
            style: GoogleFonts.poppins(fontSize: 9.sp, color: Colors.white60),
            textAlign: TextAlign.center),
      ],
    );
  }
}

class _PriceInfoBox extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final Color textColor;
  final bool highlight;

  const _PriceInfoBox({
    required this.label,
    required this.amount,
    required this.color,
    required this.textColor,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.r),
          border: highlight
              ? Border.all(color: textColor.withOpacity(0.4))
              : null,
        ),
        child: Column(
          children: [
            Text('৳${amount.toInt()}',
                style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 9.sp, color: textColor.withOpacity(0.7)),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ShareIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ShareIcon(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration:
              BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22.sp),
        ),
        SizedBox(height: 4.h),
        Text(label,
            style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.grey[600])),
      ],
    );
  }
}

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MiniButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 11.sp, color: color),
            SizedBox(width: 3.w),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: color,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
