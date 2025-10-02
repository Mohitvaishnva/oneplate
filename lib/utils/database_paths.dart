class DatabasePaths {
  // User paths
  static const String users = 'users';
  static const String hotels = 'hotels';
  static const String ngos = 'ngos';
  static const String individuals = 'individuals';
  
  // Donation paths
  static const String donations = 'donations';
  static const String donationRequests = 'donation_requests';
  static const String donationAcceptances = 'donation_acceptances';
  static const String pickupConfirmations = 'pickup_confirmations';
  
  // Communication paths
  static const String notifications = 'notifications';
  static const String ratingsReviews = 'ratings_reviews';
  
  // Analytics paths
  static const String analytics = 'analytics';
  static const String dailyStats = 'analytics/daily_stats';
  static const String userStats = 'analytics/user_stats';
  
  // Emergency and categories
  static const String emergencyRequests = 'emergency_requests';
  static const String foodCategories = 'food_categories';
  static const String appSettings = 'app_settings';
  
  // Helper methods
  static String userPath(String uid) => '$users/$uid';
  static String hotelPath(String uid) => '$hotels/$uid';
  static String ngoPath(String uid) => '$ngos/$uid';
  static String individualPath(String uid) => '$individuals/$uid';
  
  static String donationPath(String donationId) => '$donations/$donationId';
  static String donationRequestPath(String requestId) => '$donationRequests/$requestId';
  static String donationAcceptancePath(String acceptanceId) => '$donationAcceptances/$acceptanceId';
  static String pickupConfirmationPath(String pickupId) => '$pickupConfirmations/$pickupId';
  
  static String userNotificationsPath(String uid) => '$notifications/$uid';
  static String userStatsPath(String uid) => '$userStats/$uid';
  
  static String emergencyRequestPath(String emergencyId) => '$emergencyRequests/$emergencyId';
  static String ratingReviewPath(String reviewId) => '$ratingsReviews/$reviewId';
}