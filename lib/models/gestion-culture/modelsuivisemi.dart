class StepModel {
  String name;
  bool completed;
  String? date;

  StepModel({
    required this.name,
    required this.completed,
    this.date,
  });

  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      name: json['name'],
      completed: json['completed'],
      date: json['date']?.toString(),
    );
  }
}