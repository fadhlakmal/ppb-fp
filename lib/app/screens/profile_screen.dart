import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/app/models/user_model.dart';
import 'package:myapp/app/services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();

  UserModel? _currentUser;
  bool _isLoading = true;
  String? _error;

  final _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _error = "Not logged in";
          _isLoading = false;
        });
        return;
      }

      final UserModel? userModel = await _userService.getUserById(
        currentUser.uid,
      );
      if (userModel != null) {
        setState(() {
          _currentUser = userModel;
          _usernameController.text = userModel.username;
        });
      } else {
        setState(() {
          _error = "Failed to load user data";
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, 'login');
    } catch (e) {
      setState(() {
        _error = "Error signing out: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: _signOut)],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _profileContent(),
    );
  }

  Widget _profileContent() {
    if (_currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle_outlined, size: 70, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Please log in to view your profile',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text('Go to Login'),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: _loadUserData,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  _currentUser?.imgUrl != null &&
                          _currentUser!.imgUrl!.isNotEmpty
                      ? NetworkImage(_currentUser!.imgUrl!)
                      : null,
              child:
                  _currentUser?.imgUrl == null || _currentUser!.imgUrl!.isEmpty
                      ? Icon(Icons.person, size: 70, color: Colors.grey)
                      : null,
            ),
            SizedBox(height: 24.0,),
            Text(
              _currentUser!.username,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              _currentUser!.email,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
