import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TodoCard extends StatelessWidget {
  final String title;
  final String description;
  final String url;
  final String thumbnailUrl;
  final String duration;
  final String category;
  final List<String> tags;
  final bool isCompleted;
  final Function(bool?) onCheckboxChanged;

  const TodoCard({
    required this.title,
    required this.description,
    required this.url,
    required this.thumbnailUrl,
    required this.duration,
    required this.category,
    required this.tags,
    required this.isCompleted,
    required this.onCheckboxChanged,
  });

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.amber.shade600, // Background color changed to amber
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: InkWell(
        onTap: () => _launchURL(url),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail (Adjusted size & wrapped in SizedBox)
              SizedBox(
                width: 70,
                height: 70,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    thumbnailUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Expanded column for text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with strikethrough if completed
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? Colors.grey.shade800 : Colors.white,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),

                    // Description
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70, // Lightened text for contrast
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Row for category & duration
                    Row(
                      children: [
                        Flexible(
                          child: _buildInfoChip(Icons.timer, duration, Colors.white70),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: _buildInfoChip(Icons.category, category, Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Tags
                    Wrap(
                      spacing: 4,
                      runSpacing: -6,
                      children: tags.map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          backgroundColor: Colors.amber.shade800, // Darker shade for contrast
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Checkbox with matching theme color
              SizedBox(
                width: 40,
                child: Checkbox(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  activeColor: Colors.white, // Matches the white text theme
                  checkColor: Colors.amber.shade600, // Inverted color for contrast
                  value: isCompleted,
                  onChanged: onCheckboxChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function for category & duration chips
  Widget _buildInfoChip(IconData icon, String text, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade800, // Darker amber shade for better visibility
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: textColor),
              overflow: TextOverflow.ellipsis, // Prevents overflow
            ),
          ),
        ],
      ),
    );
  }
}
