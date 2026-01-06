import 'package:flutter/material.dart';

/// Google Sign-In Button theo đúng Brand Guidelines của Google
/// https://developers.google.com/identity/branding-guidelines
/// 
/// Sử dụng PNG asset chính thức của Google "G" icon
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.text = 'Đăng nhập với Google',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A73E8), // Google Blue
          side: BorderSide(color: Colors.grey.shade300, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A73E8)),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Google "G" Icon từ PNG asset
                  Image.asset(
                    'assets/images/google.png',
                    width: 20,
                    height: 20,
                    semanticLabel: 'Google logo',
                  ),
                  const SizedBox(width: 12),
                  // Text
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.25,
                      color: Color(0xFF1A73E8),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
