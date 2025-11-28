class ClientModel {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String? photo; // локальний шлях
  ClientModel(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.birthDate,
      this.photo});
  String get fullName => '$lastName $firstName';
  Map<String, dynamic> toMap() => {
        'firstName': firstName,
        'lastName': lastName,
        'birthDate': birthDate.toIso8601String(),
        'photo': photo,
      };
}
