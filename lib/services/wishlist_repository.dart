import '../models/wishlist_entry_model.dart';

abstract class WishlistRepository {
  Future<List<WishlistEntry>> getWishlist(String userId);
  Future<WishlistEntry> addToWishlist(WishlistEntry entry);
  Future<void> removeFromWishlist(int id, String userId);
  Future<WishlistEntry?> isWishlisted(String userId, String cityName, double latitude, double longitude);
}