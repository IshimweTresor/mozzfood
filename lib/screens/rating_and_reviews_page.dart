import 'package:flutter/material.dart';
import '../utils/colors.dart';

class RatingAndReviewsPage extends StatefulWidget {
  const RatingAndReviewsPage({super.key});

  @override
  State<RatingAndReviewsPage> createState() => _RatingAndReviewsPageState();
}

class _RatingAndReviewsPageState extends State<RatingAndReviewsPage> {
  List<ReviewItem> _reviews = [
    ReviewItem(
      name: 'BAHATI NYANDWI',
      date: '2025-04-23 21:26:02',
      rating: 5,
      comment:
          'the app is very nice, fast and well equipped with IT tools. thank you for your service ( Pega Já the best )',
      initials: 'BN',
      backgroundColor: Colors.orange,
    ),
    ReviewItem(
      name: 'TUYISHIME PROVIDENCE',
      date: '2025-04-23 13:36:29',
      rating: 5,
      comment: 'Great service ever',
      initials: 'TP',
      backgroundColor: Colors.orange,
    ),
    ReviewItem(
      name: 'IRADUKUNDA NADINE',
      date: '2025-04-23 13:16:59',
      rating: 4,
      comment: 'Highly recommended!',
      initials: 'IN',
      backgroundColor: Colors.pink,
    ),
    ReviewItem(
      name: 'BLENDA AKIMANA',
      date: '2025-04-23 13:11:12',
      rating: 5,
      comment: 'You delivered excellent results',
      initials: 'BA',
      backgroundColor: Colors.lightGreen,
    ),
    ReviewItem(
      name: 'MUHAMMAD IBRAHIM',
      date: '2025-04-22 20:09:03',
      rating: 4,
      comment: 'The service was exceptional and exceeded my expectations',
      initials: 'MI',
      backgroundColor: Colors.blue,
    ),
    ReviewItem(
      name: 'Anonymous',
      date: '2025-04-22 12:12:15',
      rating: 5,
      comment: 'very helpful in resolving my issue',
      initials: 'A',
      backgroundColor: Colors.purple,
    ),
    ReviewItem(
      name: 'DOMINIQUE MICHEL TCHOUMI',
      date: '2025-04-22 10:01:55',
      rating: 4,
      comment: 'Highly recommend this company',
      initials: 'DT',
      backgroundColor: Colors.deepOrange,
    ),
    ReviewItem(
      name: 'BISINE AMZA',
      date: '2025-04-21 23:54:46',
      rating: 3,
      comment: 'I was impressed by their commitment to going the extra',
      initials: 'BA',
      backgroundColor: Colors.purple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pega Já Rating and Reviews',
          style: TextStyle(
            color: AppColors.onBackground,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _reviews.length,
        itemBuilder: (context, index) {
          final review = _reviews[index];
          return _buildReviewCard(review);
        },
      ),
    );
  }

  Widget _buildReviewCard(ReviewItem review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // User Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: review.backgroundColor,
                child: Text(
                  review.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onBackground,
                      ),
                    ),
                    Text(
                      review.date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating Stars
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: AppColors.primary,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Review Comment
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewItem {
  final String name;
  final String date;
  final int rating;
  final String comment;
  final String initials;
  final Color backgroundColor;

  ReviewItem({
    required this.name,
    required this.date,
    required this.rating,
    required this.comment,
    required this.initials,
    required this.backgroundColor,
  });
}
