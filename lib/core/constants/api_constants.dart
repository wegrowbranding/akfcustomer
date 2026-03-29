class ApiConstants {
  static const String baseUrl =
      'https://wegrowbranding.com/akflowers/public/api/v1/customer-app/';
  static String storageUrl(int id) =>
      'https://wegrowbranding.com/akflowers/public/api/v1/media/$id/view';

  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/home/dashboard';
  static const String products = '/products';
  static const String cart = '/cart';
  static const String cartUpdate = '/cart/update';
  static const String addresses = '/addresses';
  static const String addAddress = '/addresses/add';
  static const String applyCoupon = '/checkout/apply-coupon';
  static const String placeOrder = '/checkout/place-order';
  static const String orders = '/orders';
  static String cancelOrder(int id) => '/orders/$id/cancel';
  static const String wishlist = '/wishlist';
  static const String updateWishlist = '/wishlist/update';
  static const String checkProductInWishlist = '/check-product-in-wishlist';
  static const String recentlyViewed = '/recently-viewed';
  static const String markAsViewed = '/recently-viewed/add';
  static const String profile = '/profile';
  static const String updateProfilePhoto = '/update-profile-photo';
  static const String deleteProfilePhoto = '/remove-profile-photo';
  static const String reviews = '/reviews';
  static const String productReviews = '/products'; // will append /{id}/reviews
  static const String supportMeta = '/support-meta';
  static const String checkEmailExists = '/check-customer-email-exists';
  static const String changePassword = '/change-password';

  static const String addDevice = '/devices/add';
  static const String deviceLastActive = '/devices/update-last-active';
  static const String logoutDevice = '/devices/logout';
}
