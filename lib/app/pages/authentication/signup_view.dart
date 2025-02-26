// 🐦 Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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

  Future<void> _submitForm() async {
    final lang = l.S.of(context); // <----- PINDAHKAN DISINI
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true); // Mengatur loading menjadi true
      try {
        final response = await http.post(
          Uri.parse(
              'https://api.tun.asia/signup.php'), // <----- Ganti dengan API endpoint kamu
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'fullName': _fullNameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
          }),
        );

        if (response.statusCode == 201) {
          // <----- Ganti dengan kode sukses yang sesuai
          // Pendaftaran berhasil, tampilkan pesan dan/atau navigasi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(lang.signupSuccessful)), // "Pendaftaran berhasil!"
          );
          context.go('/authentication/signin'); // Navigasi ke halaman login
        } else {
          // Tangani kesalahan pendaftaran
          final errorData = jsonDecode(response.body);
          String errorMessage = errorData['error'] ??
              lang.signupFailed; // "Pendaftaran gagal" sesuaikan juga dengan l10n
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(lang.networkError)), // "Kesalahan jaringan" sesuaikan juga dengan l10n
        );
      } finally {
        setState(() => _isLoading = false); // Mengatur loading menjadi false
      }
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

                                  // Divider
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

                                  // Full Name Field
                                  TextFieldLabelWrapper(
                                    //labelText: 'Full Name',
                                    labelText: lang.fullName,
                                    inputField: TextFormField(
                                      controller:
                                          _fullNameController, // <----- Tambahkan controller
                                      validator: (value) {
                                        // <----- Tambahkan validator
                                        if (value == null || value.isEmpty) {
                                          return lang.pleaseEnterFullName; // "Silakan masukkan nama lengkap"
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        // hintText: 'Enter full name',
                                        hintText: lang.enterFullName,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Email Field
                                  TextFieldLabelWrapper(
                                    // labelText: 'Email',
                                    labelText: lang.email,
                                    inputField: TextFormField(
                                      controller:
                                          _emailController, // <----- Tambahkan controller
                                      keyboardType: TextInputType
                                          .emailAddress, // <----- Tambahkan keyboard type
                                      validator: (value) {
                                        // <----- Tambahkan validator
                                        if (value == null || value.isEmpty) {
                                          return lang.pleaseEnterEmail; // "Silakan masukkan email"
                                        }
                                        if (!HelperFunctions.isValidEmail(
                                            value)) {
                                          return lang.invalidEmail; // "Email tidak valid"
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        //hintText: 'Enter email address',
                                        hintText: lang.enterEmailAddress,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Password Field
                                  TextFieldLabelWrapper(
                                    //labelText: 'Password',
                                    labelText: lang.password,
                                    inputField: TextFormField(
                                      controller:
                                          _passwordController, // <----- Tambahkan controller
                                      obscureText: !showPassword,
                                      validator: (value) {
                                        // <----- Tambahkan validator
                                        if (value == null || value.isEmpty) {
                                          return lang.pleaseEnterPassword; // "Silakan masukkan password"
                                        }
                                        // Tambahkan validasi password yang lebih kompleks jika diperlukan
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        //hintText: 'Enter your password',
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
                                    child:
                                        _isLoading // <----- Menampilkan CircularProgressIndicator saat loading
                                            ? const CircularProgressIndicator()
                                            : ElevatedButton(
                                                onPressed:
                                                    _submitForm, // <----- Panggil _submitForm disini
                                                child: Text(
                                                    lang.signUp), // "Sign Up"
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
