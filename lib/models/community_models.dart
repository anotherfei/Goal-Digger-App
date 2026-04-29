class CommunityUser {
  final String name;
  final int? compatibility;
  final String avatar;
  const CommunityUser({required this.name, this.compatibility, required this.avatar});
}

class CommunityGroup {
  final String name;
  final int members;
  final String tag;
  final String creator;
  final String created;
  final String about;
  const CommunityGroup({required this.name, required this.members, required this.tag, required this.creator, required this.created, required this.about});
}

class FriendItem {
  final String name;
  final String status;
  FriendItem({required this.name, required this.status});
}
