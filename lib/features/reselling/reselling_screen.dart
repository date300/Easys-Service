import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ==================== THEME PROVIDERS ====================

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// ==================== COLOR TOKENS (Adaptive) ====================

class AppColors {
  // Light
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color primaryLightSoft = Color(0xFF818CF8);
  static const Color secondaryLight = Color(0xFF0EA5E9);
  static const Color successLight = Color(0xFF10B981);
  static const Color warningLight = Color(0xFFF59E0B);
  static const Color dangerLight = Color(0xFFEF4444);

  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color shadowLight = Color(0x1A000000);

  // Dark
  static const Color primaryDark = Color(0xFF818CF8);
  static const Color primaryDarkSoft = Color(0xFFA5B4FC);
  static const Color secondaryDark = Color(0xFF38BDF8);
  static const Color successDark = Color(0xFF34D399);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color dangerDark = Color(0xFFF87171);

  static const Color bgDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);
  static const Color borderDark = Color(0xFF334155);
  static const Color shadowDark = Color(0x40000000);

  static Color primary(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? primaryDark : primaryLight;
  static Color primarySoft(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? primaryDarkSoft : primaryLightSoft;
  static Color success(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? successDark : successLight;
  static Color warning(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? warningDark : warningLight;
  static Color danger(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? dangerDark : dangerLight;
  static Color bg(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? bgDark : bgLight;
  static Color surface(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? surfaceDark : surfaceLight;
  static Color card(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? cardDark : cardLight;
  static Color textPrimary(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? textPrimaryDark : textPrimaryLight;
  static Color textSecondary(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? textSecondaryDark : textSecondaryLight;
  static Color textMuted(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? textMutedDark : textMutedLight;
  static Color border(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? borderDark : borderLight;
  static Color shadow(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? shadowDark : shadowLight;
}

// ==================== DATA MODELS ====================

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

// ==================== DUMMY DATA ====================

final List<ProductModel> _dummyProducts = [
  ProductModel(
    id: '1',
    title: 'স্মার্ট ওয়াচ প্রো',
    image: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400',
    wholesalePrice: 850,
    maxResalePrice: 1400,
    category: 'ইলেকট্রনিক্স',
    rating: 4.8,
    totalSold: 234,
  ),
  ProductModel(
    id: '2',
    title: 'ওয়্যারলেস ইয়ারবাড',
    image: 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=400',
    wholesalePrice: 650,
    maxResalePrice: 1100,
    category: 'গ্যাজেট',
    rating: 4.5,
    totalSold: 189,
  ),
  ProductModel(
    id: '3',
    title: 'ব্লুটুথ স্পিকার',
    image: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
    wholesalePrice: 1200,
    maxResalePrice: 1900,
    category: 'অডিও',
    rating: 4.9,
    totalSold: 312,
  ),
  ProductModel(
    id: '4',
    title: 'পাওয়ার ব্যাংক ২০০০০mAh',
    image: 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400',
    wholesalePrice: 1500,
    maxResalePrice: 2500,
    category: 'অ্যাক্সেসরিজ',
    rating: 4.7,
    totalSold: 156,
  ),
  ProductModel(
    id: '5',
    title: 'ফাস্ট চার্জার কেবল',
    image: 'https://images.unsplash.com/photo-1625153669422-6b3c9a3b7c9f?w=400',
    wholesalePrice: 780,
    maxResalePrice: 1300,
    category: 'ক্যাবল',
    rating: 4.6,
    totalSold: 98,
  ),
  ProductModel(
    id: '6',
    title: 'পোর্টেবল ল্যাম্প',
    image: 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400',
    wholesalePrice: 900,
    maxResalePrice: 1600,
    category: 'অডিও',
    rating: 4.4,
    totalSold: 267,
  ),
];

const List<String> _categories = [
  'সব', 'ইলেকট্রনিক্স', 'গ্যাজেট', 'অডিও', 'অ্যাক্সেসরিজ', 'ক্যাবল',
];

// ==================== MAIN SCREEN ====================

class ResellingScreen extends ConsumerStatefulWidget {
  const ResellingScreen({super.key});

  @override
  ConsumerState<ResellingScreen> createState() => _ResellingScreenState();
}

class _ResellingScreenState extends ConsumerState<ResellingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'সব';
  String _searchQuery = '';
  bool _isSearchFocused = false;

  final double _walletBalance = 4750;
  final double _todayEarning = 320;
  final int _totalOrders = 18;

  List<ProductModel> get _filteredProducts {
    return _dummyProducts.where((p) {
      final matchCat = _selectedCategory == 'সব' || p.category == _selectedCategory;
      final matchSearch = p.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

  List<ProductModel> get _myResells =>
      _dummyProducts.where((p) => p.isReselling).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ==================== MARGIN BOTTOM SHEET ====================
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
                color: AppColors.card(context),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow(context),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                24.w, 16.h, 24.w,
                MediaQuery.of(context).viewInsets.bottom + 28.h,
              ),
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
                        color: AppColors.border(context),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Product Info
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.network(
                          product.image,
                          width: 56.w,
                          height: 56.w,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 56.w,
                            height: 56.w,
                            color: AppColors.border(context),
                            child: Icon(Icons.image_not_supported, color: AppColors.textMuted(context)),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'পাইকারি মূল্য: ৳\${product.wholesalePrice.toInt()}',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Price Cards
                  Row(
                    children: [
                      _PriceInfoBox(
                        label: 'পাইকারি',
                        amount: product.wholesalePrice,
                        bgColor: AppColors.primary(context).withOpacity(0.1),
                        textColor: AppColors.primary(context),
                      ),
                      SizedBox(width: 10.w),
                      _PriceInfoBox(
                        label: 'আমার দাম',
                        amount: myPrice,
                        bgColor: AppColors.success(context).withOpacity(0.1),
                        textColor: AppColors.success(context),
                        highlight: true,
                      ),
                      SizedBox(width: 10.w),
                      _PriceInfoBox(
                        label: 'সর্বোচ্চ',
                        amount: product.maxResalePrice,
                        bgColor: AppColors.warning(context).withOpacity(0.1),
                        textColor: AppColors.warning(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Profit Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.success(context).withOpacity(0.15),
                          AppColors.success(context).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.success(context).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: AppColors.success(context).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.trending_up_rounded,
                            color: AppColors.success(context),
                            size: 16.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'লাভ: ৳\${profit.toStringAsFixed(0)} প্রতি পিসে',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'মার্জিন সেট করুন',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary(context).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '৳\${margin.toStringAsFixed(0)}',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary(context),
                      thumbColor: AppColors.primary(context),
                      inactiveTrackColor: AppColors.border(context),
                      overlayColor: AppColors.primary(context).withOpacity(0.15),
                      trackHeight: 6,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.r),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 24.r),
                    ),
                    child: Slider(
                      min: 10,
                      max: maxMargin,
                      value: margin.clamp(10, maxMargin),
                      divisions: ((maxMargin - 10) / 10).round(),
                      onChanged: (val) => setSheetState(() => margin = val),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '৳10',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 11.sp,
                          color: AppColors.textMuted(context),
                        ),
                      ),
                      Text(
                        '৳\${maxMargin.toStringAsFixed(0)} (সর্বোচ্চ)',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 11.sp,
                          color: AppColors.textMuted(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close_rounded, size: 16.sp),
                          label: Text(
                            'বাতিল',
                            style: GoogleFonts.hindSiliguri(fontSize: 13.sp),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary(context),
                            side: BorderSide(color: AppColors.border(context)),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
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
                          label: Text(
                            'লিংক শেয়ার করুন',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary(context),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
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

  // ==================== SHARE LINK DIALOG ====================
  void _showShareLink(BuildContext context, ProductModel product) {
    final fakeLink =
        'https://resellerapp.com/p/\${product.id}?ref=MY_REF_CODE&price=\${product.myPrice.toInt()}';

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow(context),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Animation
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success(context).withOpacity(0.2),
                      AppColors.success(context).withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success(context),
                  size: 40.sp,
                ),
              ).animate().scale(delay: 100.ms, duration: 400.ms, curve: Curves.elasticOut),
              SizedBox(height: 16.h),
              Text(
                'রিসেল শুরু!',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ).animate().fadeIn(delay: 200.ms),
              SizedBox(height: 4.h),
              Text(
                'আপনার পণ্যের লিংক তৈরি হয়েছে। এখন শেয়ার করুন!',
                textAlign: TextAlign.center,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary(context),
                ),
              ).animate().fadeIn(delay: 300.ms),
              SizedBox(height: 20.h),

              // Link Box
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.bg(context),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        fakeLink,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: AppColors.textMuted(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: fakeLink));
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'লিংক কপি হয়েছে!',
                              style: GoogleFonts.hindSiliguri(fontSize: 12.sp),
                            ),
                            backgroundColor: AppColors.success(context),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary(context).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 18.sp,
                          color: AppColors.primary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),
              SizedBox(height: 20.h),

              // Share Platforms
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ShareIcon(
                    icon: Icons.facebook_rounded,
                    label: 'Facebook',
                    color: const Color(0xFF1877F2),
                  ),
                  SizedBox(width: 20.w),
                  _ShareIcon(
                    icon: Icons.chat_bubble_rounded,
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                  ),
                  SizedBox(width: 20.w),
                  _ShareIcon(
                    icon: Icons.telegram_rounded,
                    label: 'Telegram',
                    color: const Color(0xFF0088CC),
                  ),
                  SizedBox(width: 20.w),
                  _ShareIcon(
                    icon: Icons.link_rounded,
                    label: 'Copy',
                    color: AppColors.primary(context),
                  ),
                ],
              ).animate().fadeIn(delay: 500.ms),
              SizedBox(height: 20.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'ঠিক আছে',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
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
      floatingActionButton: _myResells.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _tabController.animateTo(1),
              backgroundColor: AppColors.primary(context),
              icon: Icon(Icons.analytics_rounded, size: 20.sp),
              label: Text(
                'আমার রিসেল',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'রিসেলিং হাব',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Text(
                'পণ্য বাছুন, মার্জিন সেট করুন, লিংক শেয়ার করুন',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    size: 24.sp,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -10, curve: Curves.easeOut);
  }

  // ==================== EARNINGS SUMMARY ====================
  Widget _buildEarningsSummary() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary(context),
            AppColors.primarySoft(context),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary(context).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: 'ওয়ালেট ব্যালেন্স',
              value: '৳\${_walletBalance.toStringAsFixed(0)}',
              icon: Icons.account_balance_wallet_rounded,
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: Colors.white.withOpacity(0.2),
          ),
          Expanded(
            child: _StatItem(
              label: 'আজকের আয়',
              value: '৳\${_todayEarning.toStringAsFixed(0)}',
              icon: Icons.trending_up_rounded,
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: Colors.white.withOpacity(0.2),
          ),
          Expanded(
            child: _StatItem(
              label: 'মোট অর্ডার',
              value: '\$_totalOrders টি',
              icon: Icons.shopping_bag_rounded,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 500.ms).scale(
      begin: const Offset(0.95, 0.95),
      curve: Curves.easeOut,
    );
  }

  // ==================== SEARCH BAR ====================
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: GestureDetector(
        onTap: () => setState(() => _isSearchFocused = true),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: _isSearchFocused
                  ? AppColors.primary(context).withOpacity(0.5)
                  : AppColors.border(context),
              width: _isSearchFocused ? 1.5 : 1,
            ),
            boxShadow: _isSearchFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary(context).withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            onTap: () => setState(() => _isSearchFocused = true),
            onSubmitted: (_) => setState(() => _isSearchFocused = false),
            style: GoogleFonts.hindSiliguri(fontSize: 13.sp),
            decoration: InputDecoration(
              hintText: 'পণ্য খুঁজুন...',
              hintStyle: GoogleFonts.hindSiliguri(
                fontSize: 13.sp,
                color: AppColors.textMuted(context),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.textMuted(context),
                size: 20.sp,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.textMuted(context),
                        size: 18.sp,
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: AppColors.primary(context),
                        size: 18.sp,
                      ),
                    ),
              filled: false,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  // ==================== CATEGORY FILTER ====================
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 52.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final selected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: selected
                    ? LinearGradient(
                        colors: [
                          AppColors.primary(context),
                          AppColors.primarySoft(context),
                        ],
                      )
                    : null,
                color: selected ? null : AppColors.card(context),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : AppColors.border(context),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.primary(context).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                cat,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textSecondary(context),
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  // ==================== TAB BAR ====================
  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 4.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: TabBar(
        controller: _tabController,
        labelStyle: GoogleFonts.hindSiliguri(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.hindSiliguri(
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary(context),
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary(context),
              AppColors.primarySoft(context),
            ],
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary(context).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'সব পণ্য (\${_filteredProducts.length})'),
          Tab(text: 'আমার রিসেল (\${_myResells.length})'),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms);
  }

  // ==================== PRODUCTS TAB ====================
  Widget _buildProductsTab() {
    final products = _filteredProducts;
    if (products.isEmpty) return _buildEmptyState();

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.65,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => _ProductCard(
        product: products[i],
        onSetMargin: () => _showMarginSheet(context, products[i]),
      ).animate().fadeIn(delay: (i * 50).ms).slideY(
        begin: 20,
        curve: Curves.easeOut,
      ),
    );
  }

  // ==================== MY RESELLS TAB ====================
  Widget _buildMyResellsTab() {
    if (_myResells.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.primary(context).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 48.sp,
                color: AppColors.primary(context),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            SizedBox(height: 16.h),
            Text(
              'আপনি এখনো কোনো পণ্য রিসেল করেননি',
              style: GoogleFonts.hindSiliguri(
                fontSize: 14.sp,
                color: AppColors.textSecondary(context),
              ),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () => _tabController.animateTo(0),
              child: Text(
                'পণ্য দেখুন',
                style: GoogleFonts.hindSiliguri(
                  color: AppColors.primary(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      itemCount: _myResells.length,
      itemBuilder: (_, i) => _ActiveResellCard(
        product: _myResells[i],
        onShare: () => _showShareLink(context, _myResells[i]),
        onEdit: () => _showMarginSheet(context, _myResells[i]),
        onStop: () => setState(() => _myResells[i].isReselling = false),
      ).animate().fadeIn(delay: (i * 80).ms).slideX(
        begin: 20,
        curve: Curves.easeOut,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64.sp,
            color: AppColors.textMuted(context),
          ),
          SizedBox(height: 12.h),
          Text(
            'কোনো পণ্য পাওয়া যায়নি',
            style: GoogleFonts.hindSiliguri(
              fontSize: 14.sp,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== PRODUCT CARD ====================
class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onSetMargin;

  const _ProductCard({required this.product, required this.onSetMargin});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSetMargin,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.border(context)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                  child: Container(
                    height: 140.h,
                    width: double.infinity,
                    color: AppColors.bg(context),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary(context),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.bg(context),
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.textMuted(context),
                          size: 40.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                if (product.isReselling)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.success(context),
                            AppColors.success(context).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success(context).withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 10.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'অ্যাক্টিভ',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 9.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppColors.card(context).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 12.sp,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          product.rating.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),

                  // Price row
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary(context).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          '৳\${product.wholesalePrice.toInt()}',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary(context),
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '+৳\${product.maxMargin.toInt()} লাভ',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 10.sp,
                          color: AppColors.success(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '\${product.totalSold} বার বিক্রি',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 10.sp,
                      color: AppColors.textMuted(context),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Button
                  GestureDetector(
                    onTap: onSetMargin,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: product.isReselling
                              ? [
                                  AppColors.success(context),
                                  AppColors.success(context).withOpacity(0.8),
                                ]
                              : [
                                  AppColors.primary(context),
                                  AppColors.primarySoft(context),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: (product.isReselling
                                    ? AppColors.success(context)
                                    : AppColors.primary(context))
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            product.isReselling
                                ? Icons.share_rounded
                                : Icons.add_shopping_cart_rounded,
                            color: Colors.white,
                            size: 14.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            product.isReselling ? 'শেয়ার করুন' : 'রিসেল করুন',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
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
      ),
    );
  }
}

// ==================== ACTIVE RESELL CARD ====================
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
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              width: 72.w,
              height: 72.w,
              color: AppColors.bg(context),
              child: Image.network(
                product.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.textMuted(context),
                  size: 28.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 14.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      'আমার দাম: ',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    Text(
                      '৳\${product.myPrice.toInt()}',
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success(context).withOpacity(0.15),
                        AppColors.success(context).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.success(context).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'লাভ ৳\${product.myMargin.toInt()}',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 10.sp,
                      color: AppColors.success(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    _MiniButton(
                      icon: Icons.share_rounded,
                      label: 'শেয়ার',
                      color: AppColors.primary(context),
                      onTap: onShare,
                    ),
                    SizedBox(width: 6.w),
                    _MiniButton(
                      icon: Icons.edit_rounded,
                      label: 'এডিট',
                      color: AppColors.warning(context),
                      onTap: onEdit,
                    ),
                    SizedBox(width: 6.w),
                    _MiniButton(
                      icon: Icons.stop_circle_outlined,
                      label: 'বন্ধ',
                      color: AppColors.danger(context),
                      onTap: onStop,
                    ),
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

// ==================== HELPER WIDGETS ====================

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white.withOpacity(0.9), size: 18.sp),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 9.sp,
            color: Colors.white.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PriceInfoBox extends StatelessWidget {
  final String label;
  final double amount;
  final Color bgColor;
  final Color textColor;
  final bool highlight;

  const _PriceInfoBox({
    required this.label,
    required this.amount,
    required this.bgColor,
    required this.textColor,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.r),
          border: highlight
              ? Border.all(color: textColor.withOpacity(0.4), width: 1.5)
              : null,
        ),
        child: Column(
          children: [
            Text(
              '৳\${amount.toInt()}',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.hindSiliguri(
                fontSize: 9.sp,
                color: textColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
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

  const _ShareIcon({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => HapticFeedback.lightImpact(),
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 10.sp,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }
}

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MiniButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12.sp, color: color),
            SizedBox(width: 4.w),
            Text(
              label,
              style: GoogleFonts.hindSiliguri(
                fontSize: 10.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
