class Band {
  final String id;
  final String name;
  final int votes;

  Band({required this.id, required this.name, required this.votes});

  factory Band.fromJson(Map<String, dynamic> json) {
    return Band(
      id: json['id'] ?? 'not-id',
      name: json['name'] ?? 'not-name',
      votes: json['votes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'votes': votes,
    };
  }
}
