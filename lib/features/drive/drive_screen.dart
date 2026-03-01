import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DriveScreen extends StatelessWidget {
  const DriveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_filled_rounded, size: 80.sp, color: Colors.grey[300]),
          Text("Drive Offers", style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.bold)),
          Text("Coming Soon!", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey)),
        ],
      ),
    );
  }
}
