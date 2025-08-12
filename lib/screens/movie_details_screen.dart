import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MovieDetailScreen extends StatefulWidget {
  final dynamic movie;
  final String apiKey;

  MovieDetailScreen({required this.movie, required this.apiKey});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  dynamic movieDetails;
  bool isLoading = true;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadMovieDetails();
  }

  Future<void> loadMovieDetails() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.themoviedb.org/3/movie/${widget.movie['id']}?api_key=${widget.apiKey}&append_to_response=videos'),
      );
      
      if (response.statusCode == 200) {
        setState(() {
          movieDetails = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading movie details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF001122),
              Color(0xFF000000),
              Color(0xFF001144),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Color(0xFFFFA500)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        widget.movie['title'] ?? 'Movie Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFA500),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Color(0xFFFFA500),
                      ),
                      onPressed: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFavorite ? 'Added to favorites' : 'Removed from favorites',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Color(0xFFFFA500),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFA500),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 400,
                              child: Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 300,
                                    child: widget.movie['backdrop_path'] != null
                                        ? Image.network(
                                            '$imageBaseUrl${widget.movie['backdrop_path']}',
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[800],
                                                child: Icon(Icons.movie, size: 100, color: Color(0xFFFFA500)),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: Colors.grey[800],
                                            child: Icon(Icons.movie, size: 100, color: Color(0xFFFFA500)),
                                          ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 16,
                                    right: 16,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 180,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0xFFFFA500).withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: widget.movie['poster_path'] != null
                                                ? Image.network(
                                                    '$imageBaseUrl${widget.movie['poster_path']}',
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        color: Colors.grey[800],
                                                        child: Icon(Icons.movie, size: 50, color: Color(0xFFFFA500)),
                                                      );
                                                    },
                                                  )
                                                : Container(
                                                    color: Colors.grey[800],
                                                    child: Icon(Icons.movie, size: 50, color: Color(0xFFFFA500)),
                                                  ),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.movie['title'] ?? 'Unknown Title',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFFFA500),
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black,
                                                      blurRadius: 4,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(Icons.star, color: Color(0xFFFFA500), size: 20),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '${widget.movie['vote_average']?.toStringAsFixed(1) ?? 'N/A'}',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Color(0xFFFFA500),
                                                      shadows: [
                                                        Shadow(
                                                          color: Colors.black,
                                                          blurRadius: 4,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Overview',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFA500),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    widget.movie['overview'] ?? 'No overview available.',
                                    style: TextStyle(
                                      fontSize: 14, 
                                      height: 1.5,
                                      color: Color(0xFFFFA500).withOpacity(0.9),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Release Date',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFFA500),
                                              ),
                                            ),
                                            Text(
                                              widget.movie['release_date'] ?? 'Unknown',
                                              style: TextStyle(
                                                color: Color(0xFFFFA500).withOpacity(0.8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Runtime',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFFA500),
                                              ),
                                            ),
                                            Text(
                                              movieDetails != null && movieDetails['runtime'] != null
                                                  ? '${movieDetails['runtime']} min'
                                                  : 'Unknown',
                                              style: TextStyle(
                                                color: Color(0xFFFFA500).withOpacity(0.8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  if (movieDetails != null && movieDetails['genres'] != null) ...[
                                    SizedBox(height: 16),
                                    Text(
                                      'Genres',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFFA500),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: movieDetails['genres'].map<Widget>((genre) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFFFA500).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Color(0xFFFFA500).withOpacity(0.5),
                                            ),
                                          ),
                                          child: Text(
                                            genre['name'],
                                            style: TextStyle(
                                              color: Color(0xFFFFA500),
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                  
                                  if (movieDetails != null && 
                                      movieDetails['videos'] != null && 
                                      movieDetails['videos']['results'].isNotEmpty) ...[
                                    SizedBox(height: 16),
                                    Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFFFF8C00),
                                              Color(0xFFFFA500),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: ElevatedButton.icon(
                                          icon: Icon(Icons.play_arrow, color: Colors.black),
                                          label: Text(
                                            'Watch Trailer',
                                            style: TextStyle(color: Colors.black),
                                          ),
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Trailer playback would be implemented here'),
                                                backgroundColor: Color(0xFFFFA500),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}