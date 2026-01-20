import 'dart:typed_data';//Provides binary data types,Uint8List is required to upload image bytes to Supabase Storage
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../supabase_client.dart';
import 'edit_profile_page.dart';

const LinearGradient darkGradient = LinearGradient(
  colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final auth = AuthService();//Used for logout functionality
  Map<String, dynamic>? profile;//Stores user profile data from database
  bool loading = true;//if profile data is loaded
  int avatarVersion = 0;

  @override
  void initState() {//load profile data when page initialied
    super.initState();//Calls parent class initialization
    _loadProfile();//Loads user profile immediately from database
  }

  // PROFILE 

  Future<void> _loadProfile() async {
    final user = SupabaseConfig.client.auth.currentUser!;//
    final res = await SupabaseConfig.client
        .from('profiles')
        .select()
        .eq('id', user.id)//filter to get current user profile
        .maybeSingle();//fetch single record or null

    setState(() {//update state with loaded profile data
      profile = res ?? {'name': '', 'avatar_url': null};//default if profile not found
      loading = false;
    });
  }

  // AVATAR UPLOAD (WEB SAFE) 

  Future<void> _uploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked == null) return;

    final Uint8List bytes = await picked.readAsBytes();
    final user = SupabaseConfig.client.auth.currentUser!;
    final path = '${user.id}/avatar.png';//define storage path for avatar

    await SupabaseConfig.client.storage//upload img byte to supabase storage
        .from('avatars')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(//specify upload options
            upsert: true,//overrite existing file,replace ex. img
            contentType: 'image/png',
          ),
        );

    final url = SupabaseConfig.client.storage
        .from('avatars')
        .getPublicUrl(path);

    await SupabaseConfig.client
        .from('profiles')
        .update({'avatar_url': url})
        .eq('id', user.id);

    setState(() {
      avatarVersion++;
    });
    _loadProfile();//update profile to reflect new avatar
  }

  // AVATAR DELETE

  Future<void> _deleteAvatar() async {
    final user = SupabaseConfig.client.auth.currentUser!;
    final path = '${user.id}/avatar.png';

    await SupabaseConfig.client.storage.from('avatars').remove([path]);//detete av from storge 
    await SupabaseConfig.client
        .from('profiles')
        .update({'avatar_url': null})
        .eq('id', user.id);

    setState(() {
      avatarVersion++;
    });
    _loadProfile();
  }

  // PASSWORD CHANGE 

  Future<void> _changePassword() async {
    final ctrl = TextEditingController();

    final pass = await showDialog<String>(//
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Change Password"),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(hintText: "Minimum 6 characters"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (pass != null && pass.length >= 6) {
      await SupabaseConfig.client.auth.updateUser(
        UserAttributes(password: pass),
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Password updated")));
      }
    }
  }

  // UI

  @override
  Widget build(BuildContext context) {
    final user = SupabaseConfig.client.auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent, //  important
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),

      // full height gradient (no white space)
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(gradient: darkGradient),
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 110, 16, 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _profileCard(user),
                              const SizedBox(height: 24),
                              _actionTile(
                                icon: Icons.edit,
                                title: "Edit Profile",
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const EditProfilePage(),
                                    ),
                                  );
                                  _loadProfile();
                                },
                              ),
                              _actionTile(
                                icon: Icons.lock,
                                title: "Change Password",
                                onTap: _changePassword,
                              ),
                              _actionTile(
                                icon: Icons.logout,
                                title: "Logout",
                                onTap: () async {
                                  await auth.logout();
                                  if (mounted) Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  // PROFILE CARD

  Widget _profileCard(User? user) {
    final avatarUrl = profile?['avatar_url'];

    return Card(
      color: Colors.black.withOpacity(0.35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _uploadAvatar,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.tealAccent,
                backgroundImage:
                    avatarUrl != null && avatarUrl.toString().isNotEmpty
                    ? NetworkImage('$avatarUrl?v=$avatarVersion')
                    : null,
                child: avatarUrl == null
                    ? const Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 32,
                      )
                    : null,
              ),
            ),
            if (avatarUrl != null)
              TextButton(
                onPressed: _deleteAvatar,
                child: const Text(
                  "Remove Avatar",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              profile?['name'] ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              user?.email ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  //ACTION TILE 

  Widget _actionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.black.withOpacity(0.35),
      child: ListTile(
        leading: Icon(icon, color: Colors.tealAccent),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.white54,
        ),
        onTap: onTap,
      ),
    );
  }
}
