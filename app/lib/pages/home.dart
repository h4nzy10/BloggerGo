import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final titleController = TextEditingController();
  final slugController = TextEditingController();
  final contentController = TextEditingController();

  int? selectedCategoryId;
  bool isSaving = false;

  final List<Map<String, dynamic>> categories = [
    {'id': 1, 'name': 'Teknologi'},
    {'id': 2, 'name': 'Travel'},
    {'id': 3, 'name': 'Gaya Hidup'},
    {'id': 4, 'name': 'Edukasi'},
    {'id': 5, 'name': 'Kesehatan'},
  ];

  @override
  void dispose() {
    titleController.dispose();
    slugController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> addPost() async {
    if (selectedCategoryId == null ||
        titleController.text.trim().isEmpty ||
        slugController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields!')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/v1/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'category_id': selectedCategoryId,
          'title': titleController.text.trim(),
          'slug': slugController.text.trim(),
          'content': contentController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Posted!')),
        );
        Navigator.pop(context, true);
      } else {
        final responseData = jsonDecode(response.body);
        final errorMessage = responseData['message'] ?? 'Failed to add post';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error (${response.statusCode}): $errorMessage')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connection: $e')),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add"),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8338EC), Color(0xFF3A86FF)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 50),
              Text(
                "Add New Post",
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 50),
              DropdownButtonFormField<int>(
                value: selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                hint: const Text(
                  'Choose Category',
                  style: TextStyle(color: Colors.white70),
                ),
                dropdownColor: Colors.white,
                items: categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category['id'] as int,
                    child: Text(
                      category['name'].toString(),
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedCategoryId = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: slugController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Slug',
                  hint: Text("Example: how-to-make-your-own-blog",
                  style: TextStyle(color: Color.fromARGB(104, 255, 255, 255)),
                  ),
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isSaving ? null : addPost,
                child: isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Homepage
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> posts = [];
  bool isLoading = false;
  int _currentIndex = 0;

  Future<void> fetchApi() async {
    setState(() => isLoading = true);
    try {
      final resp = await http.get(
        Uri.parse("http://localhost:3000/api/v1/posts"),
      );

      if (!mounted) return;

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);

        setState(() {
          if (data is Map<String, dynamic> && data.containsKey('data')) {
            posts = data['data'];
          } else if (data is List) {
            posts = data;
          }
        });
      } else {
        print("Error fetching status code: ${resp.statusCode}");
      }
    } catch (e) {
      print("Error connection: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchApi();
  }

  Future<void> deletePost(int? id) async {
    if (id == null) return;
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api/v1/posts/$id'),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully deleted posts')),
        );
        setState(() {
          posts.removeWhere((item) => item['id'] == id);
        });
      } else {
        print('Failed to delete posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error delete: $e');
    }
  }

  Future<void> _navigateToAdd() async {
    final isAdded = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPostPage()),
    );

    setState(() => _currentIndex = 0);

    if (isAdded == true) {
      fetchApi();
    }
  }

  Future<void> _navigateToDetail(Map item) async {
    final isUpdated = await Navigator.pushNamed(
      context,
      '/detail',
      arguments: item,
    );

    if (isUpdated == true) {
      fetchApi();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add"),
        ],
        onTap: (index) {
          if (index == 1) {
            setState(() => _currentIndex = index);
            _navigateToAdd();
          }
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8338EC), Color(0xFF3A86FF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: fetchApi,
            child: isLoading && posts.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : posts.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada data post.',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final item = posts[index];
                          return ListTile(
                            onTap: () => _navigateToDetail(item),
                            title: Text(
                              item['title'] ?? '',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                            subtitle: Text(
                              item['slug']?.toString() ?? '',
                              style: GoogleFonts.poppins(
                                color: const Color.fromARGB(121, 255, 255, 255),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                if (item['id'] != null) {
                                  deletePost(item['id']);
                                }
                              },
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }
}