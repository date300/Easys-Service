import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'widgets/app_bottom_nav_bar.dart';
import 'widgets/app_nav_rail.dart';
import 'widgets/app_top_bar.dart';
import 'widgets/app_drawer.dart';

final isDetailViewProvider = StateProvider<bool>((ref) => false);
final detailViewTitleProvider = StateProvider<String>((ref) => '');

class MainWrapper extends ConsumerWidget {
  final Widget child;
  final bool isDetailView; // ✅ নতুন
  const MainWrapper({super.key, required this.child, this.isDetailView = false});

  static bool _isDesktop(BuildContext ctx) => MediaQuery.of(ctx).size.width >= 1100;
  static bool _isTablet(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 600 && MediaQuery.of(ctx).size.width < 1100;
  static bool _isMobile(BuildContext ctx) => MediaQuery.of(ctx).size.width < 600;

  int _indexFromLocation(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/reselling')) return 1;
    if (location.startsWith('/microjobs')) return 2;
    if (location.startsWith('/campaigns')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onNavTap(BuildContext context, WidgetRef ref, int index) {
    ref.read(isDetailViewProvider.notifier).state = false;
    ref.read(detailViewTitleProvider.notifier).state = '';

    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.go('/reselling'); break;
      case 2: context.go('/microjobs'); break;
      case 3: context.go('/campaigns'); break;
      case 4: context.go('/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);
    final isDesktop = _isDesktop(context);
    final isTablet = _isTablet(context);
    final isMobile = _isMobile(context);

    final isEditProfile = location.contains('edit_profile');
    final isDetail = isDetailView || isEditProfile;
    final detailTitle = isDetailView ? 'Payment' : ref.watch(detailViewTitleProvider);

    final animatedChild = child.animate(key: ValueKey(location)).fadeIn(duration: 400.ms).moveY(begin: 10, end: 0);

    Widget bodyContainer() {
      if (isDetail) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: animatedChild,
        );
      }
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isMobile ? 32.r : 24),
            topRight: Radius.circular(isMobile ? 32.r : 24),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isMobile ? 32.r : 24),
            topRight: Radius.circular(isMobile ? 32.r : 24),
          ),
          child: animatedChild,
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF29B6F6),
      drawer: isDetail ? null : AppDrawer(isLoggedIn: true, isDesktop: isDesktop, isTablet: isTablet),
      body: SafeArea(
        top: !isEditProfile,
        child: Row(
          children: [
            if ((isDesktop || isTablet) && !isDetail)
              AppNavRail(currentIndex: currentIndex, isDesktop: isDesktop, onTap: (i) => _onNavTap(context, ref, i)),
            Expanded(
              child: Column(
                children: [
                  if (!isEditProfile)
                    AppTopBar(
                      isDetailView: isDetail,
                      detailTitle: detailTitle,
                      isMobile: isMobile,
                      isLoggedIn: true,
                    ),
                  Expanded(child: bodyContainer()),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (isMobile && !isDetail)
          ? AppBottomNavBar(currentIndex: currentIndex, onTap: (i) => _onNavTap(context, ref, i))
          : null,
    );
  }
}
