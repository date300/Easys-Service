import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

// আপনার আগের কালার থিম
const Color kSkyBlue = Color(0xFF29B6F6);
const Color kWhite = Colors.white;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // হালকা অফ-হোয়াইট ব্যাকগ্রাউন্ড
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 25.h),
                  _buildGrid(services),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Our Services',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            Text(
              'Everything you need in one place',
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        Text(
          'See All',
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: kSkyBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ).animate().fadeIn().slideX();
  }

  Widget _buildGrid(List<Service> services) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // এক লাইনে ৪টি আইটেম (বেশি স্লিম দেখাবে)
        mainAxisSpacing: 20.h,
        crossAxisSpacing: 15.w,
        childAspectRatio: 0.75,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return _ServiceCard(service: services[index])
            .animate()
            .fade(delay: (index * 50).ms)
            .scale(begin: const Offset(0.9, 0.9));
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final bool isLocked = service.route == null;

    return GestureDetector(
      onTap: () => /* আপনার আগের ট্যাপ লজিক */ {},
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // আইকন কন্টেইনার (সাদা এবং গোল আকৃতির)
              Container(
                height: 55.w,
                width: 55.w,
                decoration: BoxDecoration(
                  color: kWhite,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    // সার্ভিস মডেলের আইকন এখানে আসবে (Cupertino হলে ভালো)
                    service.icon, 
                    color: isLocked ? Colors.grey.shade300 : kSkyBlue,
                    size: 24.sp,
                  ),
                ),
              ),
              // যদি সার্ভিসটি লক করা থাকে
              if (isLocked)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.lock_fill,
                      size: 10.sp,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          // টেক্সট (খুবই ক্লিন Poppins ফন্ট)
          Text(
            service.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: isLocked ? FontWeight.w400 : FontWeight.w500,
              color: isLocked ? Colors.grey : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
