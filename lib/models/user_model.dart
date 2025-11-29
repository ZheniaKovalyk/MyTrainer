class TrainerProfile {
  final String trainerId;
  final String email;
  final String? name;
  final String? photo;
  final DateTime? birthDate;
  TrainerProfile(
      {required this.trainerId,
      required this.email,
      this.name,
      this.photo,
      this.birthDate});
  Map<String, dynamic> toMap() => {
        'email': email,
        'name': name,
        'photo': photo,
        'birthDate': birthDate?.toIso8601String(),
      };
}
