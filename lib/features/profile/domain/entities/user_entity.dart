class UserEntity {
  final String name;
  final String handle;
  final String initials;
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

const kMockUser = UserEntity(
  name: 'Mostafa Soliman',
  handle: 'engmostafasoliman',
  initials: 'MS',
  bio: 'Mobile engineer focused on Flutter, AI, and developer tooling. Building things that make repos easier to understand.',
  location: 'UAE',
  company: 'octolabs',
  joined: 'Joined Jun 2026',
  followers: 1284,
  following: 192,
  publicRepos: 47,
  stars: 38420,
);
