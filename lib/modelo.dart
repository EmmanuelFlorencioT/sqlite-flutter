final String table = 'my_table';

class ModelDatabase {
  //Naming convention to match the database columns
  static final String id = '_id';
  static final String age = '_age';
  static final String name = '_name';

  static final List<String> values = [
    /// Add all fields
    id, name, age
  ];

}

class Model {
  final int? id;
  final int age;
  final String name;

  const Model({
    this.id,
    required this.age,
    required this.name,
  });

  Model copy({
    int? id,
    int? age,
    String? name,
  }) =>
      Model(
        id: id ?? this.id,
        age: age ?? this.age,
        name: name ?? this.name,
      );

  static Model fromJson(Map<String, Object?> json) => Model(
    id: json[ModelDatabase.id] as int?,
    age: json[ModelDatabase.age] as int,
    name: json[ModelDatabase.name] as String
  );

  Map<String, Object?> toJson() => {
    ModelDatabase.id: id,
    ModelDatabase.name: name,
    ModelDatabase.age: age,
  };
}