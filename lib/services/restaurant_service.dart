import '../models/restaurant_info.dart';
import 'api_client.dart';

class RestaurantService {
  static Future<RestaurantInfo> fetchRestaurantInfo() async {
    final response = await ApiClient.get('/restaurant');

    return RestaurantInfo.fromJson(response['data']);
  }
}
