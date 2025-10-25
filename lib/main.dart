import 'package:flutter/material.dart';
import 'package:pertemuan4/model/apiservice.dart';

void main() {
  runApp(const Appberita());
}

class Appberita extends StatelessWidget {
  const Appberita({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TampilanBerita(),
    );
  }
}

class TampilanBerita extends StatefulWidget {
  const TampilanBerita({super.key});

  @override
  State<TampilanBerita> createState() => _TampilanBeritaState();
}

class _TampilanBeritaState extends State<TampilanBerita> {
  late Future<List<Article>> _articlesFuture;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();
    _articlesFuture = Apiservice().fetchArticles();

    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showScrollToTopButton) {
        setState(() {
          _showScrollToTopButton = true;
        });
      } else if (_scrollController.offset <= 300 && _showScrollToTopButton) {
        setState(() {
          _showScrollToTopButton = false;
        });
      }
    });
  }

  void _refreshArticles() {
    setState(() {
      _showScrollToTopButton = false;
      _articlesFuture = Apiservice().fetchArticles();
    });
    _scrollController.jumpTo(0);
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 81, 118, 205),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Carita Ayeuna Barudak",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshArticles,
            color: Colors.white,
          ),
        ],
      ),
      body: FutureBuilder<List<Article>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final articles = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                _refreshArticles();
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final berita = articles[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: ListTile(
                        leading: berita.urlToImage != null
                            ? Image.network(
                                berita.urlToImage!,
                                width: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                              )
                            : const Icon(Icons.image_not_supported),
                        title: Text(
                          berita.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(berita.description ?? "-"),
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(child: Text("Tidak ada berita"));
          }
        },
      ),
      floatingActionButton: _showScrollToTopButton
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }
}
