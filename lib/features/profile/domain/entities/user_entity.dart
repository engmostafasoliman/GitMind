class UserEntity {
  final String name;
  final String handle;
  final String initials;
  final String? avatarUrl;
  final String bio;
  final String location;
  final String company;
  final String joined;
  final int followers;
  final int following;
  final int publicRepos;
  final int stars;

  const UserEntity({
    required this.name,
    required this.handle,
    required this.initials,
    this.avatarUrl,
    required this.bio,
    required this.location,
    required this.company,
    required this.joined,
    required this.followers,
    required this.following,
    required this.publicRepos,
    required this.stars,
  });
}
