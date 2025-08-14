import 'package:flutter/material.dart';

class ProductImagesViewer extends StatefulWidget {
  final List<String> imageUrls;

  const ProductImagesViewer({super.key, required this.imageUrls});

  @override
  ProductImagesViewerState createState() => ProductImagesViewerState();
}

class ProductImagesViewerState extends State<ProductImagesViewer> {
  late String displayedImageUrl;

  @override
  void initState() {
    super.initState();
    displayedImageUrl = widget.imageUrls.first;
  }

  void updateDisplayedImage(String imageUrl) {
    setState(() {
      displayedImageUrl = imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main Image
        Container(
          height: 350,
          width: double.infinity,
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              displayedImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: const Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Thumbnails
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.imageUrls.map((url) {
              return GestureDetector(
                onTap: () => updateDisplayedImage(url),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          url == displayedImageUrl ? Colors.blue : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image,
                          size: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
