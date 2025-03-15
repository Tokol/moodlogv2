class TodoItem {
  final String title;
  final String description;
  final String url; // URL to the resource (e.g., YouTube video)
  final String thumbnailUrl; // Thumbnail image URL
  final String duration; // Duration of the activity (e.g., "10 minutes")
  final String category; // Category of the task (e.g., "Meditation")
  final List<String> tags; // Tags for the task (e.g., ["relaxation", "breathing"])
  bool isCompleted;

  TodoItem({
    required this.title,
    required this.description,
    required this.url,
    required this.thumbnailUrl,
    required this.duration,
    required this.category,
    required this.tags,
    this.isCompleted = false,
  });
}