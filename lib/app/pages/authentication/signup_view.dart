// 🐦 Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:feather_icons/feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart' as rf;

// 🌎 Project imports:
import '../../../generated/l10n.dart' as l;
import '../../core/helpers/fuctions/helper_functions.dart';
import '../../core/static/static.dart';
import '../../widgets/widgets.dart';

//Sign Up View
import 'dart:convert';
import 'package:http/http.dart' as http;

//Firebase Auth
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  bool showPassword = false;
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // Menambahkan state untuk loading


  //Used when using external API
  Future<void> _submitForm() async {
    final lang = l.S.of(context);
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true); // Mengatur loading menjadi true
      try {
        final response = await http.post(
          Uri.parse(
              'https://uv.deutschefreunde.com/api/api.php?register_user'), // <----- Ganti dengan API endpoint kamu
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          encoding: Encoding.getByName('utf-8'),
          body: {
            // <----- Send data as x-www-form-urlencoded
            'name': _fullNameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
          },
        );

        final responseData = jsonDecode(response.body); // Decode response
        if (responseData['value'] == 1) {
          //Register Success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(lang.signupSuccessful)), // "Pendaftaran berhasil!"
          );
          context.go('/authentication/signin'); // Navigasi ke halaman login
        } else {
          //Check Error
          String errorMessage = lang.signupFailed;
          if (responseData['message'] == "Oops! Email already registered!") {
            errorMessage = lang.emailAlreadyExist; // Email already exist
          } else if (responseData['message'] == "Register failed!") {
            errorMessage = lang
                .dataNotComplete; // Data not complete, or method not allowed
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(lang
                  .networkError)), // "Kesalahan jaringan" sesuaikan juga dengan l10n
        );
      } finally {
        setState(() => _isLoading = false); // Mengatur loading menjadi false
      }
    }
  }

  Future<String?> getApplicationId() async {
    const platform = MethodChannel('com.example.app/app_id');
    try {
      final String? result = await platform.invokeMethod('getApplicationId');
      return result;
    } on PlatformException catch (e) {
      print("Failed to get application ID: '${e.message}'.");
      return null;
    }
  }

  Future<void> _firebaseSubmitForm() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      User? user = userCredential.user;
      if (user != null) {
        // Perbarui profil pengguna dengan nama lengkap
        await user.updateProfile(displayName: _fullNameController.text);

        //Tambahkan fungsi untuk membuat dokumen di firestore
        await _createUserDocument(user); // <---- Tambahkan ini

        await user.sendEmailVerification(); // Kirim email verifikasi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Verfication Email has been sent. Please check your Email.')),
        );
        context.go('/authentication/signin'); // Kembali ke halaman sign in
      }
    } on FirebaseAuthException catch (e) {
      // Tangani error pendaftaran
      String errorMessage = 'Something went wrong while signing up.';
      if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Email already exists.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  // Fungsi untuk membuat dokumen pengguna di Firestore
  Future<void> _createUserDocument(User user) async {
    final uuid = Uuid();
    final customUserId = uuid.v4(); // Generate UUID
  final applicationId = await getApplicationId();

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': _fullNameController.text,
      'customUserId': customUserId, // ID unik Anda
      'applicationId': applicationId,
    });
    // Verifikasi data
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      print('Firestore displayName: ${doc.data()?['displayName']}');
    }
  }


  @override
  Widget build(BuildContext context) {
    final lang = l.S.of(context);
    final _theme = Theme.of(context);
    final _screenWidth = MediaQuery.sizeOf(context).width;

    final _desktopView = _screenWidth >= 1200;

    final _ssoButtonStyle = OutlinedButton.styleFrom(
      side: BorderSide(
        color: _theme.colorScheme.outline,
      ),
      foregroundColor: _theme.colorScheme.onTertiary,
      padding: rf.ResponsiveValue<EdgeInsetsGeometry?>(
        context,
        conditionalValues: [
          const rf.Condition.between(
            start: 0,
            end: 576,
            value: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ],
      ).value,
    );

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Row(
          children: [
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  minWidth: _desktopView ? (_screenWidth * 0.45) : _screenWidth,
                ),
                decoration: BoxDecoration(
                  color: _theme.colorScheme.primaryContainer,
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header With Logo
                      const CompanyHeaderWidget(),

                      // Sign up form
                      Flexible(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 375),
                          child: Center(
                              child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    lang.signUp,
                                    //'Sign up',
                                    style: _theme.textTheme.headlineSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  Text.rich(
                                    TextSpan(
                                      //text: 'Already have an account? ',
                                      text: lang.alreadyHaveAnAccount,
                                      children: [
                                        TextSpan(
                                          // text: 'Sign in',
                                          text: lang.signIn,
                                          style: _theme.textTheme.labelLarge
                                              ?.copyWith(
                                            color: _theme.colorScheme.primary,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              context.push(
                                                '/authentication/signin',
                                              );
                                            },
                                        ),
                                      ],
                                    ),
                                    style:
                                        _theme.textTheme.labelLarge?.copyWith(
                                      color: _theme.checkboxTheme.side?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // SSO Login Buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: OutlinedButton.icon(
                                          onPressed: () {},
                                          //label: const Text('Use Google'),
                                          label: Text(lang.useGoogle),
                                          icon: getImageType(
                                            AcnooStaticImage.googleIcon,
                                            height: 14,
                                            width: 14,
                                          ),
                                          style: _ssoButtonStyle,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: OutlinedButton.icon(
                                          onPressed: () {},
                                          // label: const Text('Use Apple'),
                                          label: Text(lang.useApple),
                                          icon: getImageType(
                                            AcnooStaticImage.appleIcon,
                                            height: 14,
                                            width: 14,
                                          ),
                                          style: _ssoButtonStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          height: 1,
                                          color: _theme.colorScheme.outline,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        lang.or,
                                        // 'or',
                                        style: _theme.textTheme.bodyMedium
                                            ?.copyWith(),
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Container(
                                          height: 1,
                                          color: _theme.colorScheme.outline,
                                        ),
                                      )
                                    ],
                                  ),
                                  TextFieldLabelWrapper(
                                    labelText: lang.fullName,
                                    inputField: TextFormField(
                                      controller: _fullNameController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return lang.pleaseEnterFullName;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: lang.enterFullName,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextFieldLabelWrapper(
                                    labelText: lang.email,
                                    inputField: TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return lang.pleaseEnterEmail;
                                        }
                                        if (!HelperFunctions.isValidEmail(
                                            value)) {
                                          return lang.invalidEmail;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: lang.enterEmailAddress,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextFieldLabelWrapper(
                                    labelText: lang.password,
                                    inputField: TextFormField(
                                      controller: _passwordController,
                                      obscureText: !showPassword,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return lang.pleaseEnterPassword;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: lang.enterYourPassword,
                                        suffixIcon: IconButton(
                                          onPressed: () => setState(
                                            () => showPassword = !showPassword,
                                          ),
                                          icon: Icon(
                                            showPassword
                                                ? FeatherIcons.eye
                                                : FeatherIcons.eyeOff,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Submit Button
                                  SizedBox(
                                    width: double.maxFinite,
                                    child: _isLoading
                                        ? const CircularProgressIndicator()
                                        : ElevatedButton(
                                            onPressed: _firebaseSubmitForm,
                                            child: Text(lang.signUp),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Cover Image
            if (_desktopView)
              Container(
                constraints: BoxConstraints(
                  maxWidth: _screenWidth * 0.55,
                  maxHeight: double.maxFinite,
                ),
                decoration: BoxDecoration(
                  color: _theme.colorScheme.tertiaryContainer,
                ),
                child: getImageType(
                  AcnooStaticImage.signUpCover,
                  fit: BoxFit.contain,
                  height: double.maxFinite,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
