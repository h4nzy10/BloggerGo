import 'package:ats/pages/edit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailPostPage extends StatefulWidget {
  const DetailPostPage({super.key});

  @override
  State<DetailPostPage> createState() => _DetailPostPageState();
}

class _DetailPostPageState extends State<DetailPostPage> {
  Map<String, dynamic>? item;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        item = Map<String, dynamic>.from(args);
      }
      _isInit = false;
    }
  }

  Future<void> _navigateToEdit() async {
    if (item == null) return;

    final updatedData = await Navigator.push(context, MaterialPageRoute(
          builder: (context) => EditPostPage(posts: item!)));

    if (updatedData != null && mounted) {
      setState(() {
        item = updatedData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Artikel')),
        body: const Center(child: Text('Data tidak ditemukan')),
      );
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Read Article',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF8338EC),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _navigateToEdit,
            ),
            SizedBox(
              width: 20,
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item!['title'] ?? 'Tanpa Judul',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${item!['slug'] ?? '-'}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const Divider(height: 32, thickness: 1),
              Text(
                item!['content'] ?? item!['body'] ?? 'Tidak ada isi artikel.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}