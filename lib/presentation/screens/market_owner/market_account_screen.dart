import 'dart:io';
import 'package:me_plus/core/constants/app_colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:me_plus/core/localization/app_localizations.dart';
import 'package:me_plus/presentation/providers/market_profile_provider.dart';

class MarketAccountScreen extends StatefulWidget {
  const MarketAccountScreen({super.key});

  @override
  State<MarketAccountScreen> createState() => _MarketAccountScreenState();
}

class _MarketAccountScreenState extends State<MarketAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _marketNameController;
  late TextEditingController _marketAddressController;

  bool _obscurePassword = true;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final profile = context.read<MarketProfileProvider>().profile;
    _firstNameController = TextEditingController(
      text: profile?.firstName ?? '',
    );
    _lastNameController = TextEditingController(text: profile?.lastName ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _phoneController = TextEditingController(text: profile?.phoneNumber ?? '');
    _passwordController = TextEditingController();
    _marketNameController = TextEditingController(
      text: profile?.schoolName ?? '',
    ); // Assuming schoolName is used for Market Name as per UserProfile model usage
    _marketAddressController = TextEditingController(
      text: profile?.address ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _marketNameController.dispose();
    _marketAddressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.t('my_account'),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfileImage(),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: AppLocalizations.of(context)!.t('first_name'),
                      controller: _firstNameController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      label: AppLocalizations.of(context)!.t('last_name'),
                      controller: _lastNameController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: AppLocalizations.of(context)!.t('email'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
                hintText: AppLocalizations.of(
                  context,
                )!.t('email_cannot_be_changed'),
              ),
              const SizedBox(height: 16),
              _buildPhoneField(),
              const SizedBox(height: 16),
              _buildTextField(
                label: AppLocalizations.of(context)!.t('password'),
                controller: _passwordController,
                obscureText: _obscurePassword,
                hintText: AppLocalizations.of(
                  context,
                )!.t('leave_empty_to_keep_current'),
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              _buildTextField(
                label: AppLocalizations.of(context)!.t('market_name'),
                controller: _marketNameController,
                readOnly: true,
                hintText: AppLocalizations.of(
                  context,
                )!.t('market_name_cannot_be_changed'),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: AppLocalizations.of(context)!.t('market_address'),
                controller: _marketAddressController,
                readOnly: true,
                hintText: AppLocalizations.of(
                  context,
                )!.t('address_cannot_be_changed'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Consumer<MarketProfileProvider>(
                  builder: (context, provider, child) {
                    return ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                final Map<String, dynamic> data = {
                                  'FirstName':
                                      '${_firstNameController.text}||${_marketNameController.text}',
                                  'LastName': _lastNameController.text,
                                  'PhoneNumber': _phoneController
                                      .text, // Assuming phone controller has full number
                                  'SchoolName': _marketNameController.text,
                                  'Address': _marketAddressController.text,
                                };

                                if (_passwordController.text.isNotEmpty) {
                                  data['Password'] = _passwordController.text;
                                }

                                if (_selectedImage != null) {
                                  // Handle image upload if needed, or add to data map if repository handles File
                                  // But repository expects Map<String, dynamic> and converts to FormData.
                                  // We need to pass MultipartFile.
                                  data['Image'] = await MultipartFile.fromFile(
                                    _selectedImage!.path,
                                  );
                                }

                                try {
                                  await provider.updateProfile(data);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.t('profile_updated_successfully'),
                                        ),
                                      ),
                                    );
                                    context.pop();
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${AppLocalizations.of(context)!.t('failed_to_update_profile')}: ${provider.error}',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: provider.isLoading
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

  Widget _buildProfileImage() {
    return Consumer<MarketProfileProvider>(
      builder: (context, provider, child) {
        final profile = provider.profile;
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
                          profile!.profileImageUrl!.isNotEmpty)
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
                      ),
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
                    Icons.edit,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ),
          ],
        );
      },
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? hintText,
    Widget? suffix,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: readOnly ? Colors.grey[100] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: suffix,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.t('phone_number'),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: IntlPhoneField(
            controller: _phoneController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              counterText: '',
            ),
            initialCountryCode: 'PS',
            disableLengthCheck: true,
            showDropdownIcon: true,
            dropdownIconPosition: IconPosition.trailing,
          ),
        ),
      ],
    );
  }
}
