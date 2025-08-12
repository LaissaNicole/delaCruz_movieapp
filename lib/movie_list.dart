import 'package:http/http.dart' as http;
import 'dart:convert';

class MovieList {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  
  // Fetch popular movies
  static Future<List<dynamic>> getPopularMovies(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movie/popular?api_key=$apiKey'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error loading popular movies: $e');
      return [];
    }
  }

  // Fetch top-rated movies
  static Future<List<dynamic>> getTopRatedMovies(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movie/top_rated?api_key=$apiKey'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error loading top-rated movies: $e');
      return [];
    }
  }

  // Fetch upcoming movies
  static Future<List<dynamic>> getUpcomingMovies(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movie/upcoming?api_key=$apiKey'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error loading upcoming movies: $e');
      return [];
    }
  }

  // Load all movies at once (Popular, Top-rated, Upcoming)
  static Future<Map<String, List<dynamic>>> getAllMovies(String apiKey) async {
    try {
      final results = await Future.wait([
        getPopularMovies(apiKey),
        getTopRatedMovies(apiKey),
        getUpcomingMovies(apiKey),
      ]);

      return {
        'popular': results[0],
        'topRated': results[1],
        'upcoming': results[2],
      };
    } catch (e) {
      print('Error loading all movies: $e');
      return {
        'popular': [],
        'topRated': [],
        'upcoming': [],
      };
    }
  }

  // Filter movies by genre
  static Future<List<dynamic>> getMoviesByGenre(String apiKey, int genreId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/discover/movie?api_key=$apiKey&with_genres=$genreId'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error filtering movies by genre: $e');
      return [];
    }
  }
}