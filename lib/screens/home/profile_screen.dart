import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:domini/constants/app_colors.dart';
import 'package:domini/models/user_profile.dart';
import 'package:domini/services/database_service.dart';
import 'package:domini/services/theme_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }
  
  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final databaseService = DatabaseService();
      final userProfile = await databaseService.getCurrentUserProfile();
      
      if (mounted) {
        setState(() {
          _userProfile = userProfile;
          if (userProfile != null) {
            _displayNameController.text = userProfile.displayName;
            _emailController.text = userProfile.email ?? '';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load profile: $e';
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _userProfile == null) {
      return;
    }
    
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    
    try {
      final databaseService = DatabaseService();
      
      final updatedProfile = _userProfile!.copyWith(
        displayName: _displayNameController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        lastLoginAt: DateTime.now(),
      );
      
      await databaseService.updateUserProfile(updatedProfile);
      
      if (mounted) {
        setState(() {
          _userProfile = updatedProfile;
          _isSaving = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to save profile: $e';
          _isSaving = false;
        });
      }
    }
  }
  
  Future<void> _pickImage() async {
    if (_userProfile == null) return;
    
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    
    if (image == null) return;
    
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    
    try {
      final databaseService = DatabaseService();
      final imagePath = await databaseService.saveProfileImage(
        _userProfile!.username,
        File(image.path),
      );
      
      if (imagePath != null) {
        final updatedProfile = _userProfile!.copyWith(
          profileImagePath: imagePath,
        );
        
        await databaseService.updateUserProfile(updatedProfile);
        
        if (mounted) {
          setState(() {
            _userProfile = updatedProfile;
            _isSaving = false;
          });
        }
      } else {
        throw Exception('Failed to save image');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to update profile image: $e';
          _isSaving = false;
        });
      }
    }
  }
  
  Widget _buildProfileImage() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final hasImage = _userProfile?.profileImagePath != null;
    
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              image: hasImage
                  ? DecorationImage(
                      image: FileImage(File(_userProfile!.profileImagePath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: !hasImage
                ? Center(
                    child: Text(
                      _userProfile?.displayName.isNotEmpty == true
                          ? _userProfile!.displayName.substring(0, 1).toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  )
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDarkMode ? Colors.black : Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
        actions: [
          if (_userProfile != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveProfile,
              tooltip: 'Save Profile',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No profile found',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(child: _buildProfileImage()),
                        const SizedBox(height: 24),
                        Text(
                          '@${_userProfile!.username}',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        TextFormField(
                          controller: _displayNameController,
                          decoration: InputDecoration(
                            labelText: 'Display Name',
                            hintText: 'How you want to be known',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Display name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email (optional)',
                            hintText: 'Your email address',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              // Simple email validation
                              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        const SectionHeader(title: 'Preferences'),
                        ListTile(
                          title: const Text('Dark Mode'),
                          subtitle: const Text('Enable dark theme'),
                          leading: const Icon(Icons.dark_mode),
                          trailing: Switch(
                            value: themeProvider.isDarkMode,
                            onChanged: (value) {
                              themeProvider.setDarkMode(value);
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text('Use System Theme'),
                          subtitle: const Text('Follow system dark/light setting'),
                          leading: const Icon(Icons.settings_system_daydream),
                          trailing: Switch(
                            value: themeProvider.useSystemTheme,
                            onChanged: (value) {
                              themeProvider.setUseSystemTheme(value);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        const SectionHeader(title: 'Account Information'),
                        ListTile(
                          title: const Text('Member Since'),
                          subtitle: Text(
                            '${_userProfile!.createdAt.day}/${_userProfile!.createdAt.month}/${_userProfile!.createdAt.year}',
                          ),
                          leading: const Icon(Icons.calendar_today),
                        ),
                        ListTile(
                          title: const Text('Last Login'),
                          subtitle: Text(
                            '${_userProfile!.lastLoginAt.day}/${_userProfile!.lastLoginAt.month}/${_userProfile!.lastLoginAt.year}',
                          ),
                          leading: const Icon(Icons.login),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  
  const SectionHeader({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 1,
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}
