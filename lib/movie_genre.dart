import 'package:http/http.dart' as http;
import 'dart:convert';

class MovieGenres {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  
  static List<String> getGenresList() {
    return [
      'All', 
      'Action', 
      'Adventure',
      'Animation', 
      'Comedy', 
      'Crime',
      'Documentary',
      'Drama', 
      'Family',
      'Fantasy',
      'History',
      'Horror', 
      'Music',
      'Mystery',
      'Romance', 
      'Science Fiction', 
      'TV Movie',
      'Thriller',
      'War',
      'Western'
    ];
  }

  // Fetch genres from API and return genre ID by name
  static Future<int> getGenreIdByName(String apiKey, String genreName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/genre/movie/list?api_key=$apiKey'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final genres = data['genres'] as List;
        
        final genre = genres.firstWhere(
          (g) => g['name'] == genreName,
          orElse: () => {'id': 0},
        );
        
        return genre['id'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error getting genre ID: $e');
      return 0;
    }
  }

  // Fetch all genres from API (optional - for dynamic loading)
  static Future<Map<String, int>> getAllGenres(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/genre/movie/list?api_key=$apiKey'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final genres = data['genres'] as List;
        
        Map<String, int> genreMap = {};
        for (var genre in genres) {
          genreMap[genre['name']] = genre['id'];
        }
        
        return genreMap;
      }
      return {};
    } catch (e) {
      print('Error loading genres: $e');
      return {};
    }
  }
}