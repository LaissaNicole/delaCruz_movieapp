import 'package:delacruz_movieapp/movie_genre.dart';
import 'package:delacruz_movieapp/movie_list.dart';
import 'package:flutter/material.dart';
import 'movie_details_screen.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String apiKey = '35bfeb5a372fe13c178f4a84ef804450';
  final String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  
  List<dynamic> popularMovies = [];
  List<dynamic> topRatedMovies = [];
  List<dynamic> upcomingMovies = [];
  List<String> genres = [];
  
  bool isLoading = true;
  String selectedGenre = 'All';
  bool isGridView = false;

  @override
  void initState() {
    super.initState();
    loadMovies();
    loadGenres();
  }

  // Load all movies using MovieList
  Future<void> loadMovies() async {
    setState(() {
      isLoading = true;
    });
    
    final movieData = await MovieList.getAllMovies(apiKey);
    
    setState(() {
      popularMovies = movieData['popular'] ?? [];
      topRatedMovies = movieData['topRated'] ?? [];
      upcomingMovies = movieData['upcoming'] ?? [];
      isLoading = false;
    });
  }

  // Load genres using MovieGenres
  Future<void> loadGenres() async {
    final genresList = MovieGenres.getGenresList();
    setState(() {
      genres = genresList;
    });
  }

  // Filter movies by genre using both services
  Future<void> filterByGenre(String genre) async {
    if (genre == 'All') {
      loadMovies();
      return;
    }
    
    setState(() {
      isLoading = true;
      selectedGenre = genre;
    });
    
    final genreId = await MovieGenres.getGenreIdByName(apiKey, genre);
    if (genreId > 0) {
      final filteredMovies = await MovieList.getMoviesByGenre(apiKey, genreId);
      setState(() {
        popularMovies = filteredMovies;
        topRatedMovies = [];
        upcomingMovies = [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildMovieCard(dynamic movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: movie, apiKey: apiKey),
          ),
        );
      },
      child: Container(
        width: isGridView ? null : 150,
        margin: isGridView 
            ? EdgeInsets.all(8) 
            : EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFA500).withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFA500).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: movie['poster_path'] != null
                      ? Image.network(
                          '$imageBaseUrl${movie['poster_path']}',
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
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                movie['title'] ?? 'Unknown Title',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFFFFA500),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Icon(Icons.star, color: Color(0xFFFFA500), size: 14),
                  SizedBox(width: 4),
                  Text(
                    '${movie['vote_average']?.toStringAsFixed(1) ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 11, 
                      color: Color(0xFFFFA500).withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMovieSection(String title, List<dynamic> movies) {
    if (isGridView) {
      // Grid view for all movies combined
      List<dynamic> allMovies = [];
      if (selectedGenre == 'All') {
        allMovies = [...popularMovies, ...topRatedMovies, ...upcomingMovies];
      } else {
        allMovies = popularMovies; // When filtered, popularMovies contains the filtered results
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              selectedGenre == 'All' ? 'All Movies' : selectedGenre,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFA500),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: allMovies.length,
              itemBuilder: (context, index) {
                return buildMovieCard(allMovies[index]);
              },
            ),
          ),
        ],
      );
    } else {
      // Original horizontal list view
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFA500),
              ),
            ),
          ),
          Container(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                return buildMovieCard(movies[index]);
              },
            ),
          ),
        ],
      );
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CInfo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFA500),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isGridView = !isGridView;
                        });
                      },
                      child: Icon(
                        isGridView ? Icons.list : Icons.grid_view,
                        color: Color(0xFFFFA500),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                height: 50,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: genres.length,
                  itemBuilder: (context, index) {
                    final genre = genres[index];
                    final isSelected = selectedGenre == genre;
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedGenre = genre;
                          });
                          filterByGenre(genre);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Color(0xFFFFA500) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Color(0xFFFFA500),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            genre,
                            style: TextStyle(
                              color: isSelected 
                                  ? Colors.black 
                                  : Color(0xFFFFA500),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
                            if (isGridView) ...[
                              // Show all movies in grid view
                              buildMovieSection('All Movies', []),
                            ] else ...[
                              // Show sections in list view
                              if (popularMovies.isNotEmpty)
                                buildMovieSection('Popular', popularMovies),
                              
                              if (topRatedMovies.isNotEmpty)
                                buildMovieSection('Top-rated', topRatedMovies),
                              
                              if (upcomingMovies.isNotEmpty)
                                buildMovieSection('Upcoming Movies', upcomingMovies),
                            ],
                            
                            SizedBox(height: 20),
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