export '_get_image.dart';
class HelperFunctions {
  static bool isValidEmail(String email) {
    // Basic email validation using a regular expression.
    // You might need to adjust this based on your specific requirements.
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }
}
