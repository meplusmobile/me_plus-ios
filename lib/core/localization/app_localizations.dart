import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static Map<String, Map<String, String>> get _localizedValues => {
    'en': {
      // Common
      'save': 'Save',
      'cancel': 'Cancel',
      'update': 'Update',
      'delete': 'Delete',
      'search': 'Search',
      'close': 'Close',
      'yes': 'Yes',
      'no': 'No',
      'retry': 'Retry',
      'confirm': 'Confirm',
      'ok': 'OK',
      'error': 'Error',
      'loading': 'Loading',
      'success': 'Success',

      // Authentication
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'enter_email_password_to_sign_in':
          'Enter your email and password to Sign in',
      'remember_me': 'Remember me',
      'forgot_password': 'Forgot Password ?',
      'signing_in': 'Signing In...',
      'or_sign_in_with': 'Or Sign in with',
      'dont_have_account': "Don't have an account?",
      'already_have_account': 'Already have an account?',
      'please_enter_email_and_password': 'Please enter email and password',
      'login_failed': 'Login Failed',
      'invalid_credentials_message': 'The email or password you entered is incorrect. Please check your credentials and try again.',
      'network_error_message': 'Unable to connect to the server. Please check your internet connection and try again.',
      'timeout_error_message': 'The request took too long to complete. Please try again.',
      'user_not_found_message': 'No account found with this email address. Please check your email or sign up for a new account.',
      'request_waiting_for_school_approval':
          'Your request is waiting for school approval.',
      'notify_when_approved':
          'You will be notified once the school approves your request. Please check back later.',
      'google_sign_in_coming_soon': 'Google Sign In - Coming Soon',
      'account_not_found_please_complete_signup':
          'Account not found. Please complete your signup.',
      'complete_signup': 'Complete Sign Up',
      'select_role': 'Select Your Role',
      'date_of_birth': 'Date of Birth',
      'phone_number': 'Phone Number',
      'password': 'Password',
      'please_select_date_of_birth': 'Please select your date of birth',
      'first_name_label': 'First Name',
      'last_name_label': 'Last Name',
      'phone_number_label': 'Phone Number',
      'set_password': 'Set Password',
      'confirm_password': 'Confirm Password',
      'date_of_birth_label': 'Date of Birth',
      'next': 'Next',
      'please_fill_all_fields': 'Please fill all fields',
      'passwords_do_not_match': 'Passwords do not match',
      'password_required': 'Password is required',
      'password_min_8_chars': 'Password must be at least 8 characters',
      'password_uppercase':
          'Password must contain at least one uppercase letter',
      'password_lowercase':
          'Password must contain at least one lowercase letter',
      'password_number': 'Password must contain at least one number',
      'password_special_char':
          'Password must contain at least one special character',
      'please_confirm_password': 'Please confirm your password',
      'forgot_your_password': 'Forgot Your Password?',
      'enter_email_to_reset':
          'Enter your email address and we will send you a verification code to reset your password',
      'send_verification_code': 'Send Verification Code',
      'back_to_sign_in': 'Back to Sign In',
      'email_sent': 'Email Sent!',
      'verification_code_sent':
          'A verification code has been sent to your email address',
      'continue': 'Continue',
      'verify_code': 'Verify Code',
      'enter_code': 'Enter Code',
      'enter_4_digit_code':
          'Enter the 4 digit code that you received on your email',
      'resend_email': 'Resend Email',
      'verify': 'Verify',
      'please_enter_complete_code':
          'Please enter complete 4-digit verification code',
      'verification_code_sent_to': 'Verification code sent to',
      'set_new_password': 'Set New Password',
      'set_a_new_password': 'Set a new password',
      'create_new_password_security':
          'Create a new password. Ensure it differs from\nprevious ones for security',
      'enter_new_password_to_reset':
          'Enter your new password to reset your password',
      'new_password': 'New Password',
      'confirm_new_password': 'Confirm New Password',
      'reset_password': 'Reset Password',
      'update_password': 'Update password',
      'password_reset_success': 'Password Reset Successfully!',
      'password_changed_successfully':
          'Your password has been changed successfully',
      'successful': 'Successful',
      'congratulations_password_changed':
          'Congratulations! Your password has been changed. Click continue to login',
      'login': 'Login',
      'please_fill_in_all_fields': 'Please fill in all fields',
      'passwords_do_not_match_error': 'Passwords do not match',
      'invalid_reset_data': 'Invalid reset data',

      // Role Selection
      'student': 'Student',
      'parent': 'Parent',
      'market_owner': 'Market Owner',
      'choose_role': 'Choose Your Role',
      'select_role_to_continue': 'Select your role to continue your journey',

      // Onboarding - Student
      'track_behavior_easily': 'Track Behavior Easily',
      'track_behavior_desc':
          'Track daily behavior and performance\nin a fun, simple way.',
      'track_daily_behavior_desc':
          'Track daily behavior and performance\nin a fun, simple way.',
      'earn_points_rewards': 'Earn Points & Rewards',
      'earn_points_desc':
          'Good behavior = More points.\nRedeem them for cool rewards!',
      'good_behavior_points_desc':
          'Good behavior = More points.\nRedeem them for cool rewards!',
      'go': 'Go',
      'skip': 'Skip',

      // Onboarding - Parent
      'stay_connected': 'Stay Connected',
      'stay_connected_desc':
          'Track your child\'s daily performance and\nbehavior in real time',
      'track_child_performance_desc':
          'Track your child\'s daily performance and\nbehavior in real time',
      'support_and_encourage': 'Support and Encourage',
      'support_encourage_desc':
          'Get insights that help you guide and motivate\nyour child better',
      'get_insights_guide_desc':
          'Get insights that help you guide and motivate\nyour child better',
      'track_their_progress': 'Track Their Progress',
      'track_progress_desc':
          'Watch your child improve and join them in\ncelebrating milestones',
      'watch_child_improve_desc':
          'Watch your child improve and join them in\ncelebrating milestones',

      // Onboarding - Market Owner
      'be_part_of_motivation': 'Be Part of the Motivation',
      'be_part_motivation': 'Be Part of the Motivation',
      'be_part_motivation_desc':
          'Add rewards that inspire students to do\nbetter every day',
      'add_rewards_inspire_desc':
          'Add rewards that inspire students to do\nbetter every day',
      'manage_reward_requests': 'Manage Reward Requests Easily',
      'manage_reward_desc':
          'Track student redemptions and keep your stock\nupdated',
      'track_redemptions_desc':
          'Track student redemptions and keep your stock\nupdated',
      'grow_your_impact': 'Grow Your Impact',
      'grow_impact_desc':
          'Help schools build a positive environment\none reward at a time',
      'help_schools_build_desc':
          'Help schools build a positive environment\none reward at a time',

      // School Selection
      'select_school_and_class': 'Select School & Class',
      'choose_school_class_desc':
          'Choose your school and class. Your request will be sent to the school for approval.',
      'submit_request': 'Submit Request',
      'submitting_request': 'Submitting Request...',

      // Student Signup
      'class': 'Class',
      'select_school_class': 'Select your school and class to continue',
      'failed_to_load_schools': 'Failed to load schools',
      'error_loading_classes': 'Error loading classes',

      // Parent Signup
      'childs_email': 'Child\'s Email',
      'add_child_email': 'Add Child Email',
      'please_add_child_email': 'Please add at least one child email',
      'please_enter_valid_email': 'Please enter a valid email',
      'almost_there_add_child_email':
          'Almost there! Add your child\'s email to\nconnect your account.',
      'creating_account': 'Creating Account...',

      // Market Owner Signup
      'market_name': 'Market Name',
      'market_address': 'Market Address',
      'email_cannot_be_changed': 'Email cannot be changed',
      'market_name_cannot_be_changed': 'Market Name cannot be changed',
      'address_cannot_be_changed': 'Address cannot be changed',
      'leave_empty_to_keep_current': 'Leave empty to keep current',
      'help_students_find_store':
          'Help students find your store easily by adding your details.',
      'create_account': 'Create Account',

      // Verification Overlay
      'were_verifying_your_info': 'We\'re verifying your info.',
      'this_wont_take_long': 'This won\'t take long.',

      // Navigation
      'behavior': 'Behavior',
      'activity': 'Activity',
      'home': 'Home',
      'notifications': 'Notifications',
      'profile': 'Profile',

      // Profile Screen
      'my_profile': 'My Profile',
      'my_account': 'My Account',
      'make_changes_to_your_account': 'Make changes to your account',
      'my_purchases': 'My Purchases',
      'check_your_previous_prizes': 'Check your previous prizes',
      'report_a_missing_reward': 'Report a Missing Reward',
      'report_missing_well_handle_it': 'Report missing? We\'ll handle it',
      'language': 'Language',
      'select_your_language': 'Select your language',
      'logout': 'Logout',
      'are_you_sure_you_want_to_logout': 'Are you sure you want to logout?',

      // Account Screen
      'first_name': 'First Name',
      'last_name': 'Last Name',
      'email': 'Email',
      'leave_empty_to_keep_current_password':
          'Leave empty to keep current password',
      'school': 'School',
      'grade': 'Grade',
      'save_changes': 'Save Changes',
      'profile_updated_successfully': 'Profile updated successfully',
      'failed_to_update_profile': 'Failed to update profile',
      'reward_updated_successfully': 'Reward updated successfully!',
      'error_picking_image': 'Error picking image',
      'error_updating_reward': 'Error updating reward',
      'please_enter_your_first_name': 'Please enter your first name',
      'please_enter_your_last_name': 'Please enter your last name',
      'please_enter_your_phone_number': 'Please enter your phone number',
      'invalid_mobile_number': 'Invalid Mobile Number',

      // Language Dialog
      'search_language': 'Search Language',
      'english': 'English',
      'arabic': 'Arabic',

      // Home Screen
      'welcome_back': 'Welcome Back',
      'my_kids': 'My Kids',
      'more_details': 'More Details',
      'view_reports': 'View Reports',
      'last_activity': 'Last Activity',
      'pending_approval': 'Pending Approval',
      'still_waiting_for_approval': 'Still waiting For Approval!',
      'no_children_yet': 'No Children Yet',
      'add_children_to_track':
          'Add your children to start tracking their progress',
      'report': 'Report',
      'monthly_overview': 'Monthly Overview',
      'coins_given': 'Coins Given',
      'points_given': 'Points Given',
      'exchanged': 'Exchanged',
      'exchanged_xps': 'Exchanged XPs',
      'positive': 'Positive',
      'negative': 'Negative',
      'average': 'Average Behavior',
      'purchases': 'Purchases',
      'since_last_month': 'Since last month',
      'view_all': 'View All',
      'no_purchases_yet': 'No purchases yet',
      'points': 'Points',
      'expert_points': 'Expert Points',
      'expert_points_to_next_level': 'Expert Points to next level',
      'level_completed': 'Level completed!',
      'top_3': 'Top 3',
      'see_top_10': 'See Top 10 >',
      'see_more': 'See more',
      'error_loading_data': 'Error loading data',
      'no_items_available': 'No items available in store',

      // Store Screen
      'store': 'Store',
      'search_here': 'Search here...',
      'sort_by_cost': 'Sort by Cost',
      'none': 'None',
      'low_to_high': 'Low to High',
      'high_to_low': 'High to Low',
      'are_you_sure_redeem': 'Are you sure you want to redeem',
      'coins': 'Coins',
      'for_this_reward': 'for this reward?',
      'not_enough_coins': 'Not enough coins!',
      'you_need': 'You need',
      'but_you_have': 'but you have',
      'purchase_request_sent':
          'Purchase request sent successfully! Waiting for market owner approval.',
      'purchase_successful': 'Purchase successful!',
      'purchase_confirmed':
          'Purchase confirmed! Credits deducted successfully.',
      'purchase_id_missing':
          'Purchase information is incomplete. Please contact support.',
      'purchase_failed': 'Purchase failed',
      'error_loading_store': 'Error loading store',
      'no_items_found': 'No items found',

      // Top 10 Screen
      'top_10': 'Top 10',
      'honor_list': 'Honor List',
      'name': 'Name',
      'score': 'Score',

      // Purchases Screen
      'filter_by_status': 'Filter by Status',
      'all': 'All',
      'owned': 'owned',
      'on_the_way': 'On the way',
      'rejected': 'rejected',
      'pending': 'Pending',
      'in_progress': 'in progress',
      'delivered': 'Delivered',
      'cancelled': 'Cancelled',
      'no_purchases_found': 'No purchases found',
      'market': 'Market',
      'address': 'Address',
      'status': 'Status',
      'purchase_date': 'Purchase Date',

      // Missing Reward Screen
      'missing_reward': 'Missing Reward',
      'select_purchase': 'Select Purchase',
      'report_details': 'Report Details',
      'submit_report': 'Submit Report',
      'please_select_purchase': 'Please select a purchase to report',
      'please_provide_details': 'Please provide report details',
      'report_submitted':
          'Report submitted successfully! We will investigate this issue.',
      'failed_to_submit': 'Failed to submit report',
      'no_purchases': 'No purchases found',
      'choose_purchase': 'Choose a purchase...',
      'describe_issue': 'Describe the issue in detail...',
      'missing_reward_info':
          'Didn\'t receive your reward? Select the purchase below and let us know the details.',

      // Error Messages
      'error_loading': 'Error loading',
      'something_went_wrong': 'Something went wrong',
      'try_again_later': 'Please try again later',

      // Behavior Screen
      'weekly_behavior': 'Weekly Behavior',
      'this_week': 'This Week',
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'sat': 'Sat',
      'sun': 'Sun',
      'mon': 'Mon',
      'tue': 'Tue',
      'wed': 'Wed',
      'thu': 'Thu',
      'fri': 'Fri',
      'positive_behaviors': 'Positive Behaviors',
      'negative_behaviors': 'Negative Behaviors',
      'no_behavior_data': 'No behavior data available',
      'behavior_summary': 'Behavior Summary',
      'total_positive': 'Total Positive',
      'total_negative': 'Total Negative',

      // Claim Reward
      'claim_reward': 'Claim Reward',
      'reward_claimed_successfully': 'Reward claimed successfully!',
      'already_claimed_reward': 'You have already claimed your reward!',
      'unlock_reward_no_bad_behavior':
          'To unlock this reward, you need to have no bad behavior this month.',
      'failed_to_claim_reward': 'Failed to claim reward',
      'congratulations_eligible_reward':
          'Congratulations! You are eligible for the reward!\nDo you want to claim it now?',

      // Months
      'january': 'January',
      'february': 'February',
      'march': 'March',
      'april': 'April',
      'may': 'May',
      'june': 'June',
      'july': 'July',
      'august': 'August',
      'september': 'September',
      'october': 'October',
      'november': 'November',
      'december': 'December',
      'jan': 'Jan',
      'feb': 'Feb',
      'mar': 'Mar',
      'apr': 'Apr',
      'jun': 'Jun',
      'jul': 'Jul',
      'aug': 'Aug',
      'sep': 'Sep',
      'oct': 'Oct',
      'nov': 'Nov',
      'dec': 'Dec',

      // Notifications Screen
      'no_notifications': 'No notifications',
      'notification_deleted': 'Notification deleted',
      'failed_to_delete': 'Failed to delete',
      'just_now': 'Just now',
      'd_ago': 'd ago',
      'h_ago': 'h ago',
      'm_ago': 'm ago',

      // Market Owner
      'orders': 'Orders',
      'my_market': 'My Market',
      'recent_reward_requests': 'Recent Reward Requests',
      'accept': 'Accept',
      'reject': 'Reject',
      'add_reward': 'Add Reward',
      'edit_reward': 'Edit Reward',
      'reward_image': 'Reward Image',
      'reward_name': 'Reward Name',
      'price': 'Price',
      'add': 'Add',
      'upload_image': 'Upload Image',
      'order_requests': 'Order Requests',
      'order_history': 'Order History',
      'no_pending_requests': 'No pending requests',
      'requested_for_coins': 'Requested {item} for {coins} coins',
      'this_month': 'This month',
      'last_month': 'Last month',
      'select_month': 'Select Month',
      'no_order_history': 'No order history',
      'no_items_yet': 'No items yet',
      'no_recent_requests': 'No recent requests',
      'delete_reward': 'Delete Reward',
      'delete_reward_confirm': 'Are you sure you want to delete this reward?',
      'filter': 'Filter',
      'sort_by': 'Sort By',
      'oldest': 'Oldest',
      'newest': 'Newest',
      'note_format_photos': 'Note : Format photos SVG, PNG (Max size 4mb)',
      'please_enter_reward_name': 'Please enter a reward name',
      'please_enter_price': 'Please enter a price',
      'please_enter_valid_number': 'Please enter a valid number',
      'category': 'Category',
      'nis': 'NIS',
      'active': 'Active',
      'out_of_stock': 'Out of stock',
      'snacks': 'Snacks',
      'most_popular': 'Most popular',

      // Filters
      'filters': 'Filters',
      'reset': 'Reset',
      'cost': 'Cost',
      'reward_type': 'Reward Type',
      'apply': 'Apply',
      'stationery': 'Stationery',
      'food_snacks': 'Food & Snacks',
      'school_supplies': 'School Supplies',
      'others': 'Others',
      'press_back_again_to_exit': 'Press back again to exit',
    },
    'ar': {
      // Common
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'update': 'تحديث',
      'delete': 'حذف',
      'search': 'بحث',
      'close': 'إغلاق',
      'yes': 'نعم',
      'no': 'لا',
      'retry': 'إعادة المحاولة',
      'confirm': 'تأكيد',
      'ok': 'حسناً',
      'error': 'خطأ',
      'loading': 'جار التحميل',
      'success': 'نجاح',

      // Authentication
      'sign_in': 'تسجيل الدخول',
      'sign_up': 'التسجيل',
      'enter_email_password_to_sign_in':
          'أدخل بريدك الإلكتروني وكلمة المرور لتسجيل الدخول',
      'remember_me': 'تذكرني',
      'forgot_password': 'نسيت كلمة المرور؟',
      'signing_in': 'جاري تسجيل الدخول...',
      'or_sign_in_with': 'أو قم بتسجيل الدخول باستخدام',
      'dont_have_account': 'ليس لديك حساب؟',
      'already_have_account': 'هل لديك حساب بالفعل؟',
      'please_enter_email_and_password':
          'الرجاء إدخال البريد الإلكتروني وكلمة المرور',
      'login_failed': 'فشل تسجيل الدخول',
      'invalid_credentials_message': 'البريد الإلكتروني أو كلمة المرور التي أدخلتها غير صحيحة. يرجى التحقق من بياناتك والمحاولة مرة أخرى.',
      'network_error_message': 'غير قادر على الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
      'timeout_error_message': 'استغرق الطلب وقتاً طويلاً جداً. يرجى المحاولة مرة أخرى.',
      'user_not_found_message': 'لم يتم العثور على حساب بهذا البريد الإلكتروني. يرجى التحقق من بريدك الإلكتروني أو التسجيل للحصول على حساب جديد.',
      'request_waiting_for_school_approval': 'طلبك في انتظار موافقة المدرسة.',
      'notify_when_approved':
          'سيتم إخطارك بمجرد موافقة المدرسة على طلبك. يرجى التحقق لاحقاً.',
      'google_sign_in_coming_soon': 'تسجيل الدخول بجوجل - قريباً',
      'account_not_found_please_complete_signup':
          'الحساب غير موجود. يرجى إكمال التسجيل.',
      'complete_signup': 'إكمال التسجيل',
      'select_role': 'اختر دورك',
      'date_of_birth': 'تاريخ الميلاد',
      'phone_number': 'رقم الهاتف',
      'password': 'كلمة المرور',
      'please_select_date_of_birth': 'يرجى اختيار تاريخ ميلادك',
      'first_name_label': 'الاسم الأول',
      'last_name_label': 'الاسم الأخير',
      'phone_number_label': 'رقم الهاتف',
      'set_password': 'تعيين كلمة المرور',
      'confirm_password': 'تأكيد كلمة المرور',
      'date_of_birth_label': 'تاريخ الميلاد',
      'next': 'التالي',
      'please_fill_all_fields': 'الرجاء ملء جميع الحقول',
      'passwords_do_not_match': 'كلمات المرور غير متطابقة',
      'password_required': 'كلمة المرور مطلوبة',
      'password_min_8_chars': 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل',
      'password_uppercase':
          'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل',
      'password_lowercase':
          'يجب أن تحتوي كلمة المرور على حرف صغير واحد على الأقل',
      'password_number': 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل',
      'password_special_char':
          'يجب أن تحتوي كلمة المرور على حرف خاص واحد على الأقل',
      'please_confirm_password': 'الرجاء تأكيد كلمة المرور',
      'forgot_your_password': 'نسيت كلمة المرور؟',
      'enter_email_to_reset':
          'أدخل عنوان بريدك الإلكتروني وسنرسل لك رمز التحقق لإعادة تعيين كلمة المرور',
      'send_verification_code': 'إرسال رمز التحقق',
      'back_to_sign_in': 'العودة لتسجيل الدخول',
      'email_sent': 'تم إرسال البريد الإلكتروني!',
      'verification_code_sent':
          'تم إرسال رمز التحقق إلى عنوان بريدك الإلكتروني',
      'continue': 'متابعة',
      'verify_code': 'تحقق من الرمز',
      'enter_code': 'أدخل الرمز',
      'enter_4_digit_code':
          'أدخل الرمز المكون من 4 أرقام الذي تلقيته على بريدك الإلكتروني',
      'resend_email': 'إعادة إرسال البريد الإلكتروني',
      'verify': 'تحقق',
      'please_enter_complete_code':
          'الرجاء إدخال رمز التحقق المكون من 4 أرقام كاملاً',
      'verification_code_sent_to': 'تم إرسال رمز التحقق إلى',
      'set_new_password': 'تعيين كلمة مرور جديدة',
      'set_a_new_password': 'تعيين كلمة مرور جديدة',
      'create_new_password_security':
          'قم بإنشاء كلمة مرور جديدة. تأكد من أنها تختلف عن\nكلمات المرور السابقة للأمان',
      'enter_new_password_to_reset':
          'أدخل كلمة المرور الجديدة لإعادة تعيين كلمة المرور',
      'new_password': 'كلمة المرور الجديدة',
      'confirm_new_password': 'تأكيد كلمة المرور الجديدة',
      'reset_password': 'إعادة تعيين كلمة المرور',
      'update_password': 'تحديث كلمة المرور',
      'password_reset_success': 'تم إعادة تعيين كلمة المرور بنجاح!',
      'password_changed_successfully': 'تم تغيير كلمة المرور بنجاح',
      'successful': 'نجح',
      'congratulations_password_changed':
          'تهانينا! تم تغيير كلمة المرور الخاصة بك. انقر فوق متابعة لتسجيل الدخول',
      'login': 'تسجيل الدخول',
      'please_fill_in_all_fields': 'يرجى ملء جميع الحقول',
      'passwords_do_not_match_error': 'كلمات المرور غير متطابقة',
      'invalid_reset_data': 'بيانات إعادة التعيين غير صالحة',

      // Role Selection
      'student': 'طالب',
      'parent': 'ولي أمر',
      'market_owner': 'صاحب متجر',
      'choose_role': 'اختر دورك',
      'select_role_to_continue': 'اختر دورك لمتابعة رحلتك',

      // Onboarding - Student
      'track_behavior_easily': 'تتبع السلوك بسهولة',
      'track_behavior_desc': 'تتبع السلوك والأداء اليومي\nبطريقة ممتعة وبسيطة.',
      'track_daily_behavior_desc':
          'تتبع السلوك والأداء اليومي\nبطريقة ممتعة وبسيطة.',
      'earn_points_rewards': 'اكسب نقاطًا ومكافآت',
      'earn_points_desc':
          'السلوك الجيد = المزيد من النقاط.\nاستبدلها بمكافآت رائعة!',
      'good_behavior_points_desc':
          'السلوك الجيد = المزيد من النقاط.\nاستبدلها بمكافآت رائعة!',
      'go': 'انطلق',
      'skip': 'تخطي',

      // Onboarding - Parent
      'stay_connected': 'ابق على اتصال',
      'stay_connected_desc': 'تتبع أداء طفلك اليومي\nوسلوكه في الوقت الفعلي',
      'track_child_performance_desc':
          'تتبع أداء طفلك اليومي\nوسلوكه في الوقت الفعلي',
      'support_and_encourage': 'ادعم وشجع',
      'support_encourage_desc':
          'احصل على رؤى تساعدك على توجيه وتحفيز\nطفلك بشكل أفضل',
      'get_insights_guide_desc':
          'احصل على رؤى تساعدك على توجيه وتحفيز\nطفلك بشكل أفضل',
      'track_their_progress': 'تتبع تقدمهم',
      'track_progress_desc': 'شاهد طفلك يتحسن وشاركه في\nالاحتفال بالإنجازات',
      'watch_child_improve_desc':
          'شاهد طفلك يتحسن وشاركه في\nالاحتفال بالإنجازات',

      // Onboarding - Market Owner
      'be_part_of_motivation': 'كن جزءًا من التحفيز',
      'be_part_motivation': 'كن جزءًا من التحفيز',
      'be_part_motivation_desc':
          'أضف مكافآت تلهم الطلاب لتحقيق\nأفضل أداء كل يوم',
      'add_rewards_inspire_desc':
          'أضف مكافآت تلهم الطلاب لتحقيق\nأفضل أداء كل يوم',
      'manage_reward_requests': 'إدارة طلبات المكافآت بسهولة',
      'manage_reward_desc': 'تتبع استبدالات الطلاب وحافظ على\nمخزونك محدثًا',
      'track_redemptions_desc':
          'تتبع استبدالات الطلاب وحافظ على\nمخزونك محدثًا',
      'grow_your_impact': 'اصنع تأثيرك',
      'grow_impact_desc':
          'ساعد المدارس على بناء بيئة إيجابية\nمكافأة واحدة في كل مرة',
      'help_schools_build_desc':
          'ساعد المدارس على بناء بيئة إيجابية\nمكافأة واحدة في كل مرة',

      // School Selection
      'select_school_and_class': 'اختر المدرسة والصف',
      'choose_school_class_desc':
          'اختر مدرستك وصفك. سيتم إرسال طلبك إلى المدرسة للموافقة عليه.',
      'submit_request': 'إرسال الطلب',
      'submitting_request': 'جارٍ إرسال الطلب...',

      // Student Signup
      'class': 'الصف',
      'select_school_class': 'اختر مدرستك وصفك للمتابعة',
      'failed_to_load_schools': 'فشل تحميل المدارس',
      'error_loading_classes': 'خطأ في تحميل الصفوف',

      // Parent Signup
      'childs_email': 'البريد الإلكتروني للطفل',
      'add_child_email': 'أضف بريد الطفل الإلكتروني',
      'please_add_child_email':
          'الرجاء إضافة بريد إلكتروني واحد للطفل على الأقل',
      'please_enter_valid_email': 'الرجاء إدخال بريد إلكتروني صالح',
      'almost_there_add_child_email':
          'على وشك الانتهاء! أضف البريد الإلكتروني\nلطفلك لربط حسابك.',
      'creating_account': 'جاري إنشاء الحساب...',

      // Market Owner Signup
      'market_name': 'اسم المتجر',
      'market_address': 'عنوان المتجر',
      'email_cannot_be_changed': 'لا يمكن تغيير البريد الإلكتروني',
      'market_name_cannot_be_changed': 'لا يمكن تغيير اسم المتجر',
      'address_cannot_be_changed': 'لا يمكن تغيير العنوان',
      'leave_empty_to_keep_current': 'اتركه فارغاً للاحتفاظ بالقيمة الحالية',
      'help_students_find_store':
          'ساعد الطلاب في العثور على متجرك بسهولة عن طريق إضافة التفاصيل الخاصة بك.',
      'create_account': 'إنشاء حساب',

      // Verification Overlay
      'were_verifying_your_info': 'نحن نتحقق من معلوماتك.',
      'this_wont_take_long': 'لن يستغرق هذا وقتاً طويلاً.',

      // Navigation
      'behavior': 'السلوك',
      'activity': 'النشاط',
      'home': 'الرئيسية',
      'notifications': 'الإشعارات',
      'profile': 'الملف الشخصي',

      // Profile Screen
      'my_profile': 'ملفي الشخصي',
      'my_account': 'حسابي',
      'make_changes_to_your_account': 'قم بإجراء تغييرات على حسابك',
      'my_purchases': 'مشترياتي',
      'check_your_previous_prizes': 'تحقق من جوائزك السابقة',
      'report_a_missing_reward': 'الإبلاغ عن مكافأة مفقودة',
      'report_missing_well_handle_it': 'أبلغ عن المفقود؟ سنتعامل معه',
      'language': 'اللغة',
      'select_your_language': 'اختر لغتك',
      'logout': 'تسجيل الخروج',
      'are_you_sure_you_want_to_logout': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',

      // Account Screen
      'first_name': 'الاسم الأول',
      'last_name': 'الاسم الأخير',
      'email': 'البريد الإلكتروني',
      'leave_empty_to_keep_current_password':
          'اتركه فارغاً للاحتفاظ بكلمة المرور الحالية',
      'school': 'المدرسة',
      'grade': 'الصف',
      'save_changes': 'حفظ التغييرات',
      'profile_updated_successfully': 'تم تحديث الملف الشخصي بنجاح',
      'failed_to_update_profile': 'فشل تحديث الملف الشخصي',
      'reward_updated_successfully': 'تم تحديث المكافأة بنجاح!',
      'error_picking_image': 'خطأ في اختيار الصورة',
      'error_updating_reward': 'خطأ في تحديث المكافأة',
      'please_enter_your_first_name': 'الرجاء إدخال اسمك الأول',
      'please_enter_your_last_name': 'الرجاء إدخال اسمك الأخير',
      'please_enter_your_phone_number': 'الرجاء إدخال رقم هاتفك',
      'invalid_mobile_number': 'رقم الهاتف غير صالح',

      // Language Dialog
      'search_language': 'بحث عن لغة',
      'english': 'الإنجليزية',
      'arabic': 'العربية',

      // Home Screen
      'welcome_back': 'مرحباً بعودتك',
      'my_kids': 'أطفالي',
      'more_details': 'المزيد من التفاصيل',
      'view_reports': 'عرض التقارير',
      'last_activity': 'آخر نشاط',
      'pending_approval': 'بانتظار الموافقة',
      'still_waiting_for_approval': 'لا يزال في انتظار الموافقة!',
      'no_children_yet': 'لا يوجد أطفال بعد',
      'add_children_to_track': 'أضف أطفالك لبدء تتبع تقدمهم',
      'report': 'تقرير',
      'monthly_overview': 'نظرة عامة شهرية',
      'coins_given': 'عملات معطاة',
      'points_given': 'نقاط معطاة',
      'exchanged': 'تم استبداله',
      'exchanged_xps': 'نقاط مستبدلة',
      'positive': 'إيجابي',
      'negative': 'سلبي',
      'average': 'متوسط السلوك',
      'purchases': 'مشتريات',
      'since_last_month': 'منذ الشهر الماضي',
      'view_all': 'عرض الكل',
      'no_purchases_yet': 'لا توجد مشتريات',
      'points': 'النقاط',
      'expert_points': 'نقاط الخبرة',
      'expert_points_to_next_level': 'نقاط الخبرة للمستوى التالي',
      'level_completed': 'المستوى مكتمل!',
      'top_3': 'أفضل 3',
      'see_top_10': 'عرض أفضل 10 <',
      'see_more': 'عرض المزيد',
      'error_loading_data': 'خطأ في تحميل البيانات',
      'no_items_available': 'لا توجد عناصر متاحة في المتجر',

      // Store Screen
      'store': 'المتجر',
      'search_here': 'ابحث هنا...',
      'sort_by_cost': 'ترتيب حسب السعر',
      'none': 'بلا',
      'low_to_high': 'من الأقل إلى الأعلى',
      'high_to_low': 'من الأعلى إلى الأقل',
      'are_you_sure_redeem': 'هل أنت متأكد أنك تريد استبدال',
      'coins': 'عملات',
      'for_this_reward': 'لهذه المكافأة؟',
      'not_enough_coins': 'عملات غير كافية!',
      'you_need': 'تحتاج إلى',
      'but_you_have': 'لكن لديك',
      'purchase_request_sent':
          'تم إرسال طلب الشراء بنجاح! في انتظار موافقة صاحب المتجر.',
      'purchase_successful': 'عملية شراء ناجحة!',
      'purchase_confirmed': 'تم تأكيد الشراء! تم خصم النقاط بنجاح.',
      'purchase_id_missing':
          'معلومات الشراء غير مكتملة. يرجى التواصل مع الدعم.',
      'purchase_failed': 'فشلت عملية الشراء',
      'error_loading_store': 'خطأ في تحميل المتجر',
      'no_items_found': 'لم يتم العثور على عناصر',

      // Top 10 Screen
      'top_10': 'أفضل 10',
      'honor_list': 'قائمة الشرف',
      'name': 'الاسم',
      'score': 'النقاط',

      // Purchases Screen
      'filter_by_status': 'تصفية حسب الحالة',
      'all': 'الكل',
      'owned': 'مملوك',
      'on_the_way': 'في الطريق',
      'rejected': 'مرفوض',
      'pending': 'قيد الانتظار',
      'in_progress': 'قيد التنفيذ',
      'delivered': 'تم التوصيل',
      'cancelled': 'ملغى',
      'no_purchases_found': 'لم يتم العثور على مشتريات',
      'market': 'السوق',
      'address': 'العنوان',
      'status': 'الحالة',
      'purchase_date': 'تاريخ الشراء',

      // Missing Reward Screen
      'missing_reward': 'مكافأة مفقودة',
      'select_purchase': 'اختر عملية شراء',
      'report_details': 'تفاصيل التقرير',
      'submit_report': 'إرسال التقرير',
      'please_select_purchase': 'الرجاء اختيار عملية شراء للإبلاغ عنها',
      'please_provide_details': 'الرجاء تقديم تفاصيل التقرير',
      'report_submitted':
          'تم إرسال التقرير بنجاح! سنقوم بالتحقيق في هذه المشكلة.',
      'failed_to_submit': 'فشل إرسال التقرير',
      'no_purchases': 'لم يتم العثور على مشتريات',
      'choose_purchase': 'اختر عملية شراء...',
      'describe_issue': 'صف المشكلة بالتفصيل...',
      'missing_reward_info':
          'لم تحصل على مكافأتك؟ اختر عملية الشراء أدناه وأخبرنا بالتفاصيل.',

      // Error Messages
      'error_loading': 'خطأ في التحميل',
      'something_went_wrong': 'حدث خطأ ما',
      'try_again_later': 'يرجى المحاولة مرة أخرى لاحقاً',

      // Behavior Screen
      'weekly_behavior': 'السلوك الأسبوعي',
      'this_week': 'هذا الأسبوع',
      'daily': 'يومي',
      'weekly': 'أسبوعي',
      'monthly': 'شهري',
      'sat': 'السبت',
      'sun': 'الأحد',
      'mon': 'الإثنين',
      'tue': 'الثلاثاء',
      'wed': 'الأربعاء',
      'thu': 'الخميس',
      'fri': 'الجمعة',
      'positive_behaviors': 'السلوكيات الإيجابية',
      'negative_behaviors': 'السلوكيات السلبية',
      'no_behavior_data': 'لا توجد بيانات سلوكية متاحة',
      'behavior_summary': 'ملخص السلوك',
      'total_positive': 'إجمالي الإيجابية',
      'total_negative': 'إجمالي السلبية',

      // Claim Reward
      'claim_reward': 'استلم المكافأة',
      'reward_claimed_successfully': 'تم استلام المكافأة بنجاح!',
      'already_claimed_reward': 'لقد حصلت على المكافأة من قبل!',
      'unlock_reward_no_bad_behavior':
          'لفتح هذه المكافأة، يجب ألا يكون لديك سلوك سيئ هذا الشهر.',
      'failed_to_claim_reward': 'فشل استلام المكافأة',
      'congratulations_eligible_reward':
          'مبروك! أنت مؤهل للحصول على المكافأة!\nهل تريد استلامها الآن؟',

      // Months
      'january': 'يناير',
      'february': 'فبراير',
      'march': 'مارس',
      'april': 'أبريل',
      'may': 'مايو',
      'june': 'يونيو',
      'july': 'يوليو',
      'august': 'أغسطس',
      'september': 'سبتمبر',
      'october': 'أكتوبر',
      'november': 'نوفمبر',
      'december': 'ديسمبر',
      'jan': 'يناير',
      'feb': 'فبراير',
      'mar': 'مارس',
      'apr': 'أبريل',
      'jun': 'يونيو',
      'jul': 'يوليو',
      'aug': 'أغسطس',
      'sep': 'سبتمبر',
      'oct': 'أكتوبر',
      'nov': 'نوفمبر',
      'dec': 'ديسمبر',

      // Notifications Screen
      'no_notifications': 'لا توجد إشعارات',
      'notification_deleted': 'تم حذف الإشعار',
      'failed_to_delete': 'فشل الحذف',
      'just_now': 'الآن',
      'd_ago': 'ي مضت',
      'h_ago': 'س مضت',
      'm_ago': 'د مضت',

      // Market Owner
      'orders': 'الطلبات',
      'my_market': 'متجري',
      'recent_reward_requests': 'طلبات المكافآت الأخيرة',
      'accept': 'قبول',
      'reject': 'رفض',
      'add_reward': 'إضافة مكافأة',
      'edit_reward': 'تعديل المكافأة',
      'reward_image': 'صورة المكافأة',
      'reward_name': 'اسم المكافأة',
      'price': 'السعر',
      'add': 'إضافة',
      'upload_image': 'تحميل صورة',
      'order_requests': 'طلبات جديدة',
      'order_history': 'سجل الطلبات',
      'no_pending_requests': 'لا توجد طلبات معلقة',
      'requested_for_coins': 'طلب {item} مقابل {coins} عملة',
      'this_month': 'هذا الشهر',
      'last_month': 'الشهر الماضي',
      'select_month': 'اختر الشهر',
      'no_order_history': 'لا يوجد سجل طلبات',
      'no_items_yet': 'لا توجد عناصر بعد',
      'no_recent_requests': 'لا توجد طلبات حديثة',
      'delete_reward': 'حذف المكافأة',
      'delete_reward_confirm': 'هل أنت متأكد أنك تريد حذف هذه المكافأة؟',
      'filter': 'تصفية',
      'sort_by': 'ترتيب حسب',
      'oldest': 'الأقدم',
      'newest': 'الأحدث',
      'note_format_photos':
          'ملاحظة: تنسيق الصور SVG، PNG (الحد الأقصى للحجم 4 ميجابايت)',
      'please_enter_reward_name': 'الرجاء إدخال اسم المكافأة',
      'please_enter_price': 'الرجاء إدخال السعر',
      'please_enter_valid_number': 'الرجاء إدخال رقم صحيح',
      'category': 'الفئة',
      'nis': 'شيكل',
      'active': 'نشط',
      'out_of_stock': 'غير متوفر',
      'snacks': 'وجبات خفيفة',
      'most_popular': 'الأكثر شعبية',

      // Filters
      'filters': 'تصفية',
      'reset': 'إعادة تعيين',
      'cost': 'التكلفة',
      'reward_type': 'نوع المكافأة',
      'apply': 'تطبيق',
      'stationery': 'قرطاسية',
      'food_snacks': 'طعام ووجبات خفيفة',
      'school_supplies': 'أدوات مدرسية',
      'others': 'أخرى',
      'press_back_again_to_exit': 'اضغط مرة أخرى للخروج',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Helper method for easier access
  String t(String key) => translate(key);

  // Translate month name
  String translateMonth(String monthName) {
    final monthKey = monthName.toLowerCase();
    return translate(monthKey);
  }

  // Format date with translated month
  String formatMonthYear(DateTime date) {
    final months = [
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december',
    ];
    final monthName = translate(months[date.month - 1]);

    // Capitalize first letter for English
    if (locale.languageCode == 'en') {
      return '${monthName[0].toUpperCase()}${monthName.substring(1)} ${date.year}';
    }
    return '$monthName ${date.year}';
  }

  // Format short date with translated month (MMM dd)
  String formatShortDate(DateTime date) {
    final months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];
    final monthName = translate(months[date.month - 1]);

    // Capitalize first letter for English
    if (locale.languageCode == 'en') {
      return '${monthName[0].toUpperCase()}${monthName.substring(1)} ${date.day}';
    }
    return '$monthName ${date.day}';
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
