class ExerciseGroup {
  final String id;
  String name;
  String? parentGroupId;
  int orderIndex;

  ExerciseGroup({
    required this.id,
    required this.name,
    this.parentGroupId,
    required this.orderIndex,
  });

  factory ExerciseGroup.fromJson(Map<String, dynamic> json) => ExerciseGroup(
        id: json['id'] as String,
        name: json['name'] as String,
        parentGroupId: json['parent_group_id'] as String?,
        orderIndex: (json['order_index'] as int?) ?? 0,
      );
}
