// This will called whenever the function call be the user
// void getMessages() async {
//   final messages = await _firestore.collection('messages').get();
//   for (var message in messages.docs) {
//     print(message.data());
//   }
// }

// This will invoked whenever there is changes occur in the db (by itself it will be called)
// void getMessagesStream() async {
//   await for (var snapshot in _firestore.collection('messages').snapshots()) {
//     for (var message in snapshot.docs) {
//       print(message.data());
//     }
//   }
// }
