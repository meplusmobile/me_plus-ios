import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:me_plus/presentation/theme/app_colors.dart';
import 'package:me_plus/presentation/widgets/custom_select_field.dart';
import 'package:me_plus/presentation/widgets/gradient_text.dart';
import 'package:me_plus/presentation/widgets/gradient_button.dart';
import 'package:me_plus/presentation/widgets/verification_overlay.dart';
import 'package:me_plus/data/services/auth_service.dart';
import 'package:me_plus/data/models/school.dart';
import 'package:me_plus/data/models/class_model.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

class SchoolClassSelectionScreen extends StatefulWidget {
  const SchoolClassSelectionScreen({super.key});

  @override
  State<SchoolClassSelectionScreen> createState() =>
      _SchoolClassSelectionScreenState();
}

class _SchoolClassSelectionScreenState
    extends State<SchoolClassSelectionScreen> {
  String? selectedSchool;
  String? selectedClass;
  bool _isLoading = false;
  bool _isLoadingSchools = true;
  bool _isLoadingClasses = false;
  final AuthService _authService = AuthService();
  List<School> schools = [];
  List<ClassModel> classes = [];
  String? _errorMessage;

  bool get _isFormValid =>
      selectedSchool != null && selectedClass != null && !_isLoading;

  @override
  void initState() {
    super.initState();
    _fetchSchools();
  }

  Future<void> _fetchSchools() async {
    try {
      setState(() {
        _isLoadingSchools = true;
        _errorMessage = null;
      });

      final fetchedSchools = await _authService.getSchools();

      if (mounted) {
        setState(() {
          schools = fetchedSchools;
          _isLoadingSchools = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSchools = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _fetchClasses(int schoolId) async {
    try {
      setState(() {
        _isLoadingClasses = true;
        selectedClass = null;
        classes = [];
      });

      final fetchedClasses = await _authService.getClassesBySchool(schoolId);

      if (mounted) {
        setState(() {
          classes = fetchedClasses;
          _isLoadingClasses = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingClasses = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error loading classes: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _submitRequest() async {
    if (selectedSchool == null || selectedClass == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.submitStudentRequest(
        schoolId: selectedSchool!,
        classId: selectedClass!,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show verification overlay
        VerificationOverlay.show(
          context,
          duration: const Duration(seconds: 3),
          onComplete: () {
            if (mounted) {
              context.go('/onboarding/student');
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Background blur image
            Positioned(
              top: -180,
              left: 0,
              right: 0,
              child: Image.network(
                'https://c.animaapp.com/mhqrlq9bisClG6/img/blur.png',
                height: 430,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 430,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.orange.withValues(alpha: 0.1),
                        Colors.blue.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom decoration
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Image.asset(
                'assets/images/bottombackgroundloginpage.png',
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
              ),
            ),

            // Top left logo (with IgnorePointer to allow clicks through)
            Positioned(
              top: 40,
              left: 12,
              child: IgnorePointer(
                child: SvgPicture.asset(
                  'assets/images/logo.svg',
                  width: 199,
                  height: 70,
                ),
              ),
            ),

            // Main content
            _isLoadingSchools
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed to load schools',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchSchools,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 158),

                          // Header
                          Builder(
                            builder: (context) {
                              final localizations = AppLocalizations.of(
                                context,
                              )!;
                              return Column(
                                children: [
                                  GradientText(
                                    localizations.t('select_school_and_class'),
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.secondary,
                                      ],
                                    ),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.64,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    localizations.t('choose_school_class_desc'),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.disabled,
                                      letterSpacing: -0.12,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 48),

                          // Form
                          Builder(
                            builder: (context) {
                              final localizations = AppLocalizations.of(
                                context,
                              )!;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomSelectField(
                                    label: localizations.t('school'),
                                    value: selectedSchool,
                                    items: schools
                                        .map((s) => s.id.toString())
                                        .toList(),
                                    itemLabels: schools
                                        .map((s) => s.name)
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedSchool = value;
                                        selectedClass = null;
                                        classes = [];
                                      });
                                      if (value != null) {
                                        _fetchClasses(int.parse(value));
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  _isLoadingClasses
                                      ? const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: CircularProgressIndicator(
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        )
                                      : CustomSelectField(
                                          label: localizations.t('class'),
                                          value: selectedClass,
                                          items: classes
                                              .map((c) => c.id.toString())
                                              .toList(),
                                          itemLabels: classes
                                              .map((c) => c.name)
                                              .toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedClass = value;
                                            });
                                          },
                                          enabled:
                                              selectedSchool != null &&
                                              classes.isNotEmpty,
                                        ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 48),

                          // Submit Button
                          Builder(
                            builder: (context) {
                              final localizations = AppLocalizations.of(
                                context,
                              )!;
                              return GradientButton(
                                text: _isLoading
                                    ? localizations.t('submitting_request')
                                    : localizations.t('submit_request'),
                                onPressed: _submitRequest,
                                enabled: _isFormValid,
                              );
                            },
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
