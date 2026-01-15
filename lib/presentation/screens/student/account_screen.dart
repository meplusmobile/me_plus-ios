import 'package:flutter/material.dart';
import 'package:me_plus/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'dart:io';
import 'package:me_plus/presentation/providers/profile_provider.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dobController = TextEditingController();
  final _schoolController = TextEditingController();
  final _gradeController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSaving = false;
  bool _isPasswordEmpty = true;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  String? _initialCountryCode;
  String? _fullPhoneNumber;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshProfile();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload profile data every time the screen becomes active
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    final profileProvider = context.read<ProfileProvider>();
    await profileProvider.loadProfile();
    _loadProfileData();
  }

  void _loadProfileData() {
    final profileProvider = context.read<ProfileProvider>();
    if (profileProvider.profile != null) {
      final profile = profileProvider.profile!;

      setState(() {
        _firstNameController.text = profile.firstName;
        _lastNameController.text = profile.lastName;
        _emailController.text = profile.email ?? '';

        if (profile.phone != null && profile.phone!.isNotEmpty) {
          _fullPhoneNumber = profile.phone;
          // Extract country code and number
          // Format: +9610597777777 or +961597777777
          final String phone = profile.phone!;
          if (phone.startsWith('+')) {
            // Try to extract country code
            if (phone.startsWith('+961')) {
              _initialCountryCode = 'LB';
              String number = phone.substring(4); // Remove +961
              if (number.startsWith('0')) {
                number = number.substring(1);
              }
              _phoneController.text = number;
            } else if (phone.startsWith('+970')) {
              _initialCountryCode = 'PS';
              String number = phone.substring(4); // Remove +970
              if (number.startsWith('0')) {
                number = number.substring(1);
              }
              _phoneController.text = number;
            } else if (phone.startsWith('+1')) {
              _initialCountryCode = 'US';
              _phoneController.text = phone.substring(2); // Remove +1
            } else {
              // Generic handling: extract digits after country code
              final match = RegExp(r'^\+(\d{1,3})(.*)$').firstMatch(phone);
              if (match != null) {
                String number = match.group(2) ?? '';
                if (number.startsWith('0')) {
                  number = number.substring(1);
                }
                _phoneController.text = number;
              } else {
                _phoneController.text = phone;
              }
            }
          } else {
            _phoneController.text = phone;
          }
        }

        _dobController.text = profile.birthDate ?? '';
        _schoolController.text = profile.schoolName ?? '';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final profileProvider = context.read<ProfileProvider>();

      final updateData = <String, dynamic>{
        'FirstName': _firstNameController.text.trim(),
        'LastName': _lastNameController.text.trim(),
        'PhoneNumber':
            _fullPhoneNumber ?? _phoneController.text.trim(), // Use full number
      };

      // Add birthDate if provided
      if (_dobController.text.isNotEmpty) {
        updateData['BirthDate'] = _dobController.text;
      }

      // Add password if changed
      if (_passwordController.text.isNotEmpty && !_isPasswordEmpty) {
        updateData['Password'] = _passwordController.text;
      }

      // Add image if selected
      if (_selectedImage != null) {
        updateData['image'] = await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: 'profile.jpg',
        );
      }

      await profileProvider.updateProfile(updateData);

      if (mounted) {
        // Reload profile data from API after successful update
        await _refreshProfile();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.t('profile_updated_successfully'),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        // Clear password field and selected image after successful update
        _passwordController.clear();
        _isPasswordEmpty = true;
        setState(() {
          _selectedImage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.t('failed_to_update_profile')}: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: AppColors.errorLight,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.errorLight,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    _schoolController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Container(
          color: AppColors.background,
          child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    if (profileProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Update controllers when profile loads
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (profileProvider.profile != null &&
                          _firstNameController.text.isEmpty) {
                        _loadProfileData();
                      }
                    });

                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildProfileImage(profileProvider),
                              const SizedBox(height: 24),
                              _buildForm(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => context.go('/student/profile'),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'My Account',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildProfileImage(ProfileProvider profileProvider) {
    final profile = profileProvider.profile;
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: ClipOval(
            child: _selectedImage != null
                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                : (profile?.profileImageUrl != null &&
                          profile!.profileImageUrl!.isNotEmpty
                      ? Image.network(
                          _getImageUrl(profile.profileImageUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.secondary,
                            );
                          },
                        )
                      : const Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.secondary,
                        )),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: InkWell(
            onTap: _pickImage,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 18,
                color: AppColors.secondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getImageUrl(String url) {
    if (url.startsWith('http')) {
      return url;
    }
    const baseUrl = 'https://meplus2.blob.core.windows.net/images';
    String cleanPath = url
        .replaceAll('/uploads/images/', '')
        .replaceAll('//', '/');
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    return '$baseUrl/$cleanPath';
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: AppLocalizations.of(context)!.t('first_name'),
                controller: _firstNameController,
                enabled: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(
                      context,
                    )!.t('please_enter_your_first_name');
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                label: AppLocalizations.of(context)!.t('last_name'),
                controller: _lastNameController,
                enabled: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(
                      context,
                    )!.t('please_enter_your_last_name');
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: AppLocalizations.of(context)!.t('email'),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          enabled: false, // Email cannot be edited
        ),
        const SizedBox(height: 16),
        _buildPhoneField(),
        const SizedBox(height: 16),
        _buildTextField(
          label: AppLocalizations.of(context)!.t('password'),
          controller: _passwordController,
          obscureText: _obscurePassword,
          enabled: false, // Disable password field for students
          hintText: AppLocalizations.of(
            context,
          )!.t('leave_empty_to_keep_current_password'),
          suffix: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildDateField(),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: AppLocalizations.of(context)!.t('school'),
          value: _schoolController.text.isNotEmpty
              ? _schoolController.text
              : 'ICS',
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: AppLocalizations.of(context)!.t('grade'),
          value: _gradeController.text.isNotEmpty
              ? _gradeController.text
              : 'Third',
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.t('phone_number'),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        IntlPhoneField(
          key: ValueKey(
            _initialCountryCode ?? 'PS',
          ), // Force rebuild when country changes
          controller: _phoneController,
          enabled: false,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE8E8E8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            counterText: '',
          ),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
          dropdownTextStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
          initialCountryCode:
              _initialCountryCode ?? 'PS', // Use parsed country code
          dropdownIconPosition: IconPosition.trailing,
          flagsButtonPadding: const EdgeInsets.symmetric(horizontal: 8),
          showDropdownIcon: true,
          onChanged: (phone) {
            // Store complete phone number with country code
            _fullPhoneNumber = phone.completeNumber;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
    String? hintText,
    Widget? prefix,
    Widget? suffix,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: enabled ? AppColors.background : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled ? const Color(0xFFE0E0E0) : const Color(0xFFD0D0D0),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            enabled: enabled,
            validator: validator,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFFAAAAAA),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.errorLight,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              prefixIcon: prefix != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: prefix,
                    )
                  : null,
              suffixIcon: suffix,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.t('date_of_birth'),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD0D0D0),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _dobController.text.isNotEmpty
                    ? _formatDisplayDate(_dobController.text)
                    : 'MM / DD / YYYY',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: _dobController.text.isNotEmpty
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
              const Icon(
                Icons.calendar_today,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDisplayDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.month.toString().padLeft(2, '0')} / ${date.day.toString().padLeft(2, '0')} / ${date.year}';
    } catch (e) {
      return isoDate;
    }
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.disabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                AppLocalizations.of(context)!.t('save_changes'),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildDropdownField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD0D0D0),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }
}
