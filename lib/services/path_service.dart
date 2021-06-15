/*
This class defines all the possible read/write locations from the Firestore database.
In future, any new path can be added here.
This class work together with FirestoreService and FirestoreDatabase.
*/
class PathService {
  static String flybis(String tagId) => 'flybis/public/$tagId';
  static String flybisChild(String tagId, String childId) =>
      'flybis/public/$tagId/$childId';

  static String bells(String? userId) => 'bells/$userId/bells';
  static String bell(String userId, String bellId) =>
      'bells/$userId/bells/$bellId';

  static String comments(String? userId, String? commentType, String? postId) =>
      'comments/$userId/$commentType/$postId/comments';
  static String comment(
          String? userId, String? commentType, String? postId, String commentId) =>
      'comments/$userId/$commentType/$postId/comments/$commentId';

  static String followers() => 'followers';
  static String follower(String? userId, String? followerId) =>
      'followers/$userId/followers/$followerId';

  static String followings(String? userId) => 'followings/$userId/followings';
  static String following(String? userId, String? followingId) =>
      'followings/$userId/followings/$followingId';

  static String friends(String? userId) => 'friends/$userId/friends';
  static String friend(String? userId, String? friendId) =>
      'friends/$userId/friends/$friendId';
  static String friendRequests(String userId) => 'friends/$userId/requests';
  static String friendRequest(String? userId, String? friendId) =>
      'friends/$userId/requests/$friendId';

  static String chats() => 'chats';
  static String chat(String chatId) => 'chats/$chatId';
  static String calls(String chatId) => 'chats/$chatId/calls';
  static String call(String chatId, String callId) =>
      'chats/$chatId/calls/$callId';
  static String messages(String chatId) => 'chats/$chatId/messages';
  static String message(String? chatId, String? messageId) =>
      'chats/$chatId/messages/$messageId';

  static String posts(String? userId) => 'posts/$userId/posts';
  static String post(String? userId, String? postId) =>
      'posts/$userId/posts/$postId';
  static String postLikesDislikes(String userId, String postId, String type) =>
      'posts/$userId/posts/$postId/$type';
  static String postLikeDislike(
          String? userId, String? postId, String type, String? sender) =>
      'posts/$userId/posts/$postId/$type/$sender';
  static String postLikes(String userId, String postId) =>
      'posts/$userId/posts/$postId/likes';
  static String postLike(String userId, String postId, String sender) =>
      'posts/$userId/posts/$postId/likes/$sender';
  static String postDislikes(String userId, String postId) =>
      'posts/$userId/posts/$postId/dislikes';
  static String postDislike(String userId, String postId, String sender) =>
      'posts/$userId/posts/$postId/dislikes/$sender';

  static String timelines() => 'timelines';
  static String timeline(String userId) => 'timelines/$userId';
  static String timelinePosts(String? userId) => 'timelines/$userId/posts';
  static String timelinePost(String userId, String postId) =>
      'timelines/$userId/posts/$postId';

  static String usernames() => 'usernames';
  static String username(String username) => 'usernames/$username';

  static String users() => 'users';
  static String user(String? userId) => 'users/$userId';
  static String userTokens(String userId) => 'users/$userId/tokens';
  static String userToken(String userId, String tokenId) =>
      'users/$userId/tokens/$tokenId';

  static String status(String userId) => 'status/$userId';

  static String lives() => 'lives';
  static String live(String? userId) => 'lives/$userId';
}
