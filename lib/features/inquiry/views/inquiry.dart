import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/features/inquiry/views/review_inquiry.dart';
import 'package:zoneer_mobile/features/property/viewmodels/properties_viewmodel.dart';
import 'package:zoneer_mobile/features/property/widgets/amenity_item.dart';

class Inquiry extends ConsumerWidget {
  const Inquiry({super.key, required this.propertyId});
  final String propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyAsync = ref.watch(propertyViewModelProvider(propertyId));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rental Inquiry',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: propertyAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, _) => Center(child: Text('Error: ${err.toString()}'),), 
        data: (property) => SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Property Summary', 
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12,),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        property.thumbnail,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 12,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'House in ${property.address}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AmenityItem(
                          label: 'Monthly rent', 
                          value: '\$${property.price.toString()}', 
                          icon: Icons.monetization_on_outlined
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AmenityItem(
                          label: 'Bedroom', 
                          value: property.bedroom.toString(), 
                          icon: Icons.bed
                        ),
                        AmenityItem(
                          label: 'Bathroom', 
                          value: property.bathroom.toString(), 
                          icon: Icons.bathroom
                        ),
                        AmenityItem(
                          label: 'Area', 
                          value: property.squareArea.toString(), 
                          icon: Icons.square_foot
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Your Information Form Section
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your informations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Full Name and Email Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Full Name',
                            hint: 'Chhunhour',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            label: 'Email Address',
                            hint: 'chhunhour@gmail.com',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    
                    // Phone and Occupation Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Phone Number',
                            hint: '+855 12292870',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            label: 'Occupation',
                            hint: 'Student',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    
                    // Move-in Date
                    _buildTextField(
                      label: 'Preferred Move-in Date',
                      hint: '06/07/2005',
                    ),
                    SizedBox(height: 12),
                    
                    // Message
                    _buildTextField(
                      label: 'Message',
                      hint: 'Messages',
                      maxLines: 4,
                    ),
                    SizedBox(height: 16),
                    
                    // Agreement Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: false,
                          onChanged: (value) {
                            // TODO: Handle checkbox state
                          },
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'I agree to share my contact informations with the landlord. I understand that this platform connects tenants with landlord.',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Handle form submission
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => ReviewInquiry(propertyId: propertyId))
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Submit Inquiry',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ]
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ), 
      ),
    );
  }
  
  Widget _buildTextField({
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}