import 'package:drivers_app/authentication/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountDeletionScreen extends StatefulWidget {
  @override
  _AccountDeletionScreenState createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> deleteAccount() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Show confirmation dialog
      bool shouldDelete = await showDialog(
        context: context as BuildContext,
        builder: (context) => AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete your account?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Delete"),
            ),
          ],
        ),
      );

      if (shouldDelete) {
        try {
          // Delete the user's account
          await user.delete();

          // Navigate to the login screen after successful deletion
          Navigator.pushAndRemoveUntil(
            context as BuildContext,
            MaterialPageRoute(
              builder: (context) => Login(), // Replace with your login screen widget
            ),
            (route) => false, // Remove all existing routes from the stack
          );
        } catch (e) {
          // Handle any errors that occur during account deletion
          print("Error deleting account: $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Account Deletion")),
      body: Center(
        child: ElevatedButton(
          onPressed: deleteAccount,
          child: Text("Delete Account"),
        ),
      ),
    );
  }
}

class AccountDeletedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Account Deleted")),
      body: Center(
        child: Text("Your account has been deleted."),
      ),
    );
  }
}

