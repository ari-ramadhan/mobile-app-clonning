import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:instagram_flutter/models/post.dart';
import 'package:instagram_flutter/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profImage) async {
    String res = 'Some error occured';
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);
      String postId = Uuid().v1();

      Post post = Post(
          description: description,
          uid: uid,
          username: username,
          postId: postId,
          datePublished: DateTime.now(),
          postUrl: photoUrl,
          profImage: profImage,
          likes: []);

      _firestore.collection('posts').doc(postId).set(post.toJson());

      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> updateUserProfile(
      String uid, String newUsername, String newBio, String newEmail) async {
    String res = 'some error occured';
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

      if (newUsername.isNotEmpty && newBio.isNotEmpty && newEmail.isNotEmpty) {
        await userRef.update(
            {'username': newUsername, 'bio': newBio, 'email': newEmail});
        await FirebaseAuth.instance.currentUser!.updateEmail(newEmail);
      } else {
        print(res);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> likeComment(
      String postId, String commentId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> postComment(String postId, String text, String uid, String name,
      String profilePic) async {
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'likes': [],
          'datePublished': DateTime.now()
        });
      } else {
        print('Text is empty');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // delete post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> changeProfilePict(String uid, Uint8List file) async {
    final FirebaseStorage _storage = FirebaseStorage.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    String res = 'some error occured';
    try {
      if (uid.isEmpty || file != null) {
        await _firestore.collection('users').doc(uid).update({'photoUrl': ''});
        await _storage
            .ref()
            .child('profilePics')
            .child(_auth.currentUser!.uid)
            .delete();

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        await _firestore
            .collection('users')
            .doc(uid)
            .update({'photoUrl': photoUrl});
        res = 'success';
      }
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  Future<void> savePost(String userId, String postId) async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Ambil data pengguna
      final userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        final savedPosts =
            userSnapshot.data()?['savedPosts'] as List<String> ?? [];

        // Periksa apakah postingan sudah ada dalam daftar tersimpan
        if (!savedPosts.contains(postId)) {
          // Tambahkan ID postingan ke daftar tersimpan
          savedPosts.add(postId);

          // Update data pengguna dengan daftar tersimpan yang baru
          await userRef.update({'savedPosts': savedPosts});
        }
      }
    } catch (e) {
      print('Error saving post: $e');
    }
  }

  Future<void> replyComments(String userId, String postId, String commentId,
      String text, String profilePic, String name) async {
    try {
      if (text.isNotEmpty) {
        String replyId = Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('reply')
            .doc(replyId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': userId,
          'text': text,
          'likes': [],
          'replyId': replyId,
          'datePublished': DateTime.now(),
        });
      } else {}
    } catch (e) {
      print(e);
    }
  }

  // Future<void> sendChats(
  //     String senderId, String receiverId, String text) async {
  //   try {
  //     if (text.isNotEmpty) {
  //       // Cari ID chat yang sesuai berdasarkan partisipan
  //       QuerySnapshot chatQuery = await _firestore.collection('chats').get();

  //       String chatId;

  //       if (chatQuery.docs.isNotEmpty) {
  //         // Jika dokumen chat sudah ada, gunakan ID yang ada
  //         chatId = chatQuery.docs[0].id;
  //       } else {
  //         // Jika dokumen chat belum ada, buat ID baru
  //         chatId = Uuid().v1();

  //         // Buat dokumen chat baru dengan partisipan
  //         await _firestore.collection('chats').doc(chatId).set({
  //           'participants': [senderId, receiverId],
  //         });
  //       }

  //       // Tambahkan pesan ke koleksi pesan dalam dokumen chat yang sesuai
  //       String messageId = Uuid().v1();
  //       await _firestore
  //           .collection('chats')
  //           .doc(chatId)
  //           .collection('messages')
  //           .doc(messageId)
  //           .set({
  //         'message': text,
  //         'sender': senderId, // Simpan ID pengirim pesan
  //         'time': DateTime.now(),
  //       });
  //     }
  //   } catch (e) {
  //     print('Error sending chat: $e');
  //   }
  // }

  getChats(String senderId, String receiverId) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('chats')
        .where("participants", arrayContains: [senderId, receiverId]).get();

    String chatsId = query.docs[0].id;
    if (kDebugMode) {
      print('chatid = $chatsId');
    }

    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatsId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  Future<void> sendChats(
    String senderId,
    String receiverId,
    String text,
  ) async {
    try {
      if (text.isNotEmpty) {
        // Cari dokumen chat yang sesuai dengan senderId dan receiverId
        QuerySnapshot chatQuery = await _firestore.collection('chats').get();

        QueryDocumentSnapshot<Object?>? matchingChat;

        for (var chatDoc in chatQuery.docs) {
          final data = chatDoc.data() as Map<String, dynamic>;
          final participants = data['participants'] as List<dynamic>;

          // Periksa apakah chatDoc sesuai dengan senderId dan receiverId
          if (participants.contains(senderId) &&
              participants.contains(receiverId)) {
            matchingChat = chatDoc;
            break;
          }
        }

        if (matchingChat != null) {
          // Jika dokumen chat sudah ada, gunakan dokumen yang sesuai
          // untuk menambahkan pesan
          String messageId = Uuid().v1();
          await _firestore
              .collection('chats')
              .doc(matchingChat.id)
              .collection('messages')
              .doc(messageId)
              .set({
            'message': text,
            'sender': senderId, // Simpan ID pengirim pesan
            'time': DateTime.now(),
          });
        } else {
          // Jika dokumen chat belum ada, buat ID baru dan dokumen chat baru
          String chatId = Uuid().v1();

          await _firestore.collection('chats').doc(chatId).set({
            'participants': [senderId, receiverId],
          });

          String messageId = Uuid().v1();
          await _firestore
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .doc(messageId)
              .set({
            'message': text,
            'sender': senderId, // Simpan ID pengirim pesan
            'time': DateTime.now(),
          });
        }
      }
    } catch (e) {
      print('Error sending chat: $e');
    }
  }

  // Future<void> sendChats(
  //     String senderId, String receiverId, String text) async {
  //   try {
  //     if (text.isNotEmpty) {
  //       // Cari ID chat yang sesuai berdasarkan partisipan
  //       QuerySnapshot chatQuery = await _firestore.collection('chats').where(
  //           'participants',
  //           arrayContainsAny: [senderId, receiverId]).get();

  //       String chatId;

  //       if (chatQuery.docs.isNotEmpty) {
  //         // Jika dokumen chat sudah ada, gunakan ID yang ada
  //         chatId = chatQuery.docs[0].id;
  //       } else {
  //         // Jika dokumen chat belum ada, buat ID baru
  //         chatId = Uuid().v1();

  //         // Buat dokumen chat baru dengan partisipan
  //         await _firestore.collection('chats').doc(chatId).set({
  //           'participants': [senderId, receiverId],
  //         });
  //       }

  //       // Tambahkan pesan ke koleksi pesan dalam dokumen chat yang sesuai
  //       String messageId = Uuid().v1();
  //       await _firestore
  //           .collection('chats')
  //           .doc(chatId)
  //           .collection('messages')
  //           .doc(messageId)
  //           .set({
  //         'message': text,
  //         'sender': senderId, // Simpan ID pengirim pesan
  //         'time': DateTime.now(),
  //       });
  //     }
  //   } catch (e) {
  //     print('Error sending chat: $e');
  //   }
  // }

  // getChats(String senderId, String receiverId) async {
  //   QuerySnapshot query = await FirebaseFirestore.instance
  //       .collection('chats')
  //       .where("participants", arrayContains: [senderId, receiverId]).get();

  //   String chatsId = query.docs[0].id;
  //   if (kDebugMode) {
  //     print('chatid = $chatsId');
  //   }

  //   return FirebaseFirestore.instance
  //       .collection('chats')
  //       .doc(chatsId)
  //       .collection('messages')
  //       .orderBy('time')
  //       .snapshots();
  // }
}
