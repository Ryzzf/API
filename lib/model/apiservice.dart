import 'dart:convert';
import 'package:http/http.dart' as http;

class Article{

  final String title;
  final String? description;
  final String? urlToImage;

  Article({
    required this.title, this.description, this.urlToImage
  });

  factory Article.fromJson(Map<String, dynamic> json){
    return Article(
      title: json['title'],
      description: json['description'],
      urlToImage: json['urlToImage']
      );
  }
}


class Apiservice {

  static const _Apikey = "ac729e9549dc49fba64302252dd86903";
  static const _baseUrl = "https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=${_Apikey}";


  Future<List<Article>> fetchArticles() async{

    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if(response.statusCode == 200){
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> articlesjson = json['articles'];
        return articlesjson.map( (json) => Article.fromJson(json) ).toList();

      } else {
        throw Exception('Failed to Load : ${response.statusCode} ');
      }
    } catch (e) {
      throw Exception('Failed to Connect $e');
    }
  }
}