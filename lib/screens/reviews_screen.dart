import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReviewsScreen extends StatefulWidget {
  final String routeName;
  final String busNumber;

  const ReviewsScreen({
    super.key,
    required this.routeName,
    required this.busNumber,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0;
  bool _isSubmitting = false;

  final List<Review> _reviews = [
    Review(
      userName: 'Sophie Martin',
      rating: 5,
      date: '2 days ago',
      comment:
          'Very comfortable bus with excellent service. The driver was professional and the journey was smooth.',
      userImage: 'https://randomuser.me/api/portraits/women/44.jpg',
    ),
    Review(
      userName: 'Thomas Dubois',
      rating: 4,
      date: '1 week ago',
      comment:
          'Good experience overall. The bus was clean and departed on time. Would recommend.',
      userImage: 'https://randomuser.me/api/portraits/men/32.jpg',
    ),
    Review(
      userName: 'Emma Bernard',
      rating: 3,
      date: '2 weeks ago',
      comment:
          'Average experience. The bus was a bit delayed but the staff was helpful.',
      userImage: 'https://randomuser.me/api/portraits/women/67.jpg',
    ),
    Review(
      userName: 'Lucas Petit',
      rating: 5,
      date: '3 weeks ago',
      comment:
          'Excellent service! The bus was very comfortable and had good WiFi. Will definitely travel again.',
      userImage: 'https://randomuser.me/api/portraits/men/52.jpg',
    ),
    Review(
      userName: 'Camille Roux',
      rating: 4,
      date: '1 month ago',
      comment:
          'Good journey. The seats were comfortable and there was enough legroom.',
      userImage: 'https://randomuser.me/api/portraits/women/90.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews - ${widget.routeName}'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ALL REVIEWS'),
            Tab(text: 'WRITE A REVIEW'),
          ],
          indicatorColor: Colors.white,
          indicatorWeight: 3,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReviewsList(),
          _buildWriteReview(),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    // Calculate average rating
    double averageRating = _reviews.isEmpty
        ? 0
        : _reviews.map((r) => r.rating).reduce((a, b) => a + b) /
            _reviews.length;

    return Column(
      children: [
        _buildRatingSummary(averageRating),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _reviews.length,
            itemBuilder: (context, index) {
              return _buildReviewItem(_reviews[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSummary(double averageRating) {
    // Count ratings by star
    List<int> ratingCounts = List.filled(5, 0);
    for (var review in _reviews) {
      ratingCounts[review.rating.toInt() - 1]++;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        color: index < averageRating.floor()
                            ? Colors.amber
                            : index < averageRating
                                ? Colors.amber
                                : Colors.grey[300],
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Based on ${_reviews.length} reviews',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            '${5 - index}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: Column(
                  children: List.generate(
                    5,
                    (index) {
                      double percentage = _reviews.isEmpty
                          ? 0
                          : ratingCounts[4 - index] / _reviews.length;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percentage,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.primaryColor,
                                  ),
                                  minHeight: 8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(percentage * 100).toInt()}%',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Review review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(review.userImage),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (index) => Icon(
                              index < review.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            review.date,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thanks for your feedback!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.thumb_up, size: 16),
                  label: const Text('Helpful'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWriteReview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rate your experience on ${widget.routeName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Write your review',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reviewController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Share your experience with other travelers...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSubmitting ||
                            _rating == 0 ||
                            _reviewController.text.isEmpty
                        ? null
                        : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('SUBMIT REVIEW'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Review Guidelines',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGuideline(
                    icon: Icons.check_circle,
                    text: 'Be specific and honest about your experience',
                  ),
                  _buildGuideline(
                    icon: Icons.check_circle,
                    text: 'Keep it family-friendly and respectful',
                  ),
                  _buildGuideline(
                    icon: Icons.check_circle,
                    text: 'Avoid including personal information',
                  ),
                  _buildGuideline(
                    icon: Icons.check_circle,
                    text: 'Your review will be visible to all users',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideline({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppTheme.accentColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitReview() {
    if (_rating == 0 || _reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a rating and review'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _reviews.insert(
            0,
            Review(
              userName: 'You',
              rating: _rating,
              date: 'Just now',
              comment: _reviewController.text,
              userImage: 'https://randomuser.me/api/portraits/lego/1.jpg',
            ),
          );
          _rating = 0;
          _reviewController.clear();
          _tabController.animateTo(0);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your review!'),
          ),
        );
      }
    });
  }
}

class Review {
  final String userName;
  final double rating;
  final String date;
  final String comment;
  final String userImage;

  Review({
    required this.userName,
    required this.rating,
    required this.date,
    required this.comment,
    required this.userImage,
  });
}
