import 'package:flutter/material.dart';
import 'package:zoneer_mobile/features/inquiry/models/inquiry_model.dart';

class InquiryDetail extends StatelessWidget {
  final InquiryModel inquiry;

  const InquiryDetail({super.key, required this.inquiry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inquiry Detail"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetail("Full Name", inquiry.fullname),
            const SizedBox(height: 16),

            if (inquiry.email != null)
              _buildDetail("Email", inquiry.email!),

            const SizedBox(height: 16),
            _buildDetail("Phone", inquiry.phoneNumber),
            const SizedBox(height: 16),
            _buildDetail("Occupation", inquiry.occupation ?? ""),
            const SizedBox(height: 16),

            const Text(
              "Message",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(inquiry.message),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
