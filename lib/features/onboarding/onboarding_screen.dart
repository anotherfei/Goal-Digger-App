import 'package:flutter/material.dart';

import '../../core/theme/gd_colors.dart';

typedef EmailAuthCallback = Future<void> Function(
  String email,
  String password,
  String? displayName,
  bool isSignUp,
);

const Color _authBackground = Color(0xFF0B1120);
const Color _authPanel = Color(0xFF111827);
const Color _authPanelSoft = Color(0xFF172033);
const Color _authBorder = Color(0xFF344256);
const Color _authText = Color(0xFFF8FAFC);
const Color _authMuted = Color(0xFFB8C4D6);
const Color _authAction = Color(0xFF5CE0A4);
const Color _authBlue = Color(0xFF6EA8FE);
const Color _authCoral = Color(0xFFFF7A7A);

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({
    super.key,
    required this.onEmailAuth,
    required this.onGoogle,
    required this.onGuest,
    required this.onClearError,
    required this.isLoading,
    this.errorMessage,
  });

  final EmailAuthCallback onEmailAuth;
  final VoidCallback onGoogle;
  final VoidCallback onGuest;
  final VoidCallback onClearError;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _authBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 880;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? 28 : 18,
                vertical: wide ? 28 : 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (wide ? 56 : 40),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: wide
                        ? Row(
                            children: [
                              const Expanded(
                                flex: 5,
                                child: _BrandPanel(compact: false),
                              ),
                              const SizedBox(width: 28),
                              Expanded(
                                flex: 4,
                                child: _AuthFormPanel(
                                  onEmailAuth: onEmailAuth,
                                  onGoogle: onGoogle,
                                  onGuest: onGuest,
                                  onClearError: onClearError,
                                  isLoading: isLoading,
                                  errorMessage: errorMessage,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _BrandPanel(compact: true),
                              const SizedBox(height: 18),
                              _AuthFormPanel(
                                onEmailAuth: onEmailAuth,
                                onGoogle: onGoogle,
                                onGuest: onGuest,
                                onClearError: onClearError,
                                isLoading: isLoading,
                                errorMessage: errorMessage,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 190 : 620),
      padding: EdgeInsets.all(compact ? 22 : 36),
      decoration: BoxDecoration(
        color: _authPanel,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _authBorder),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF111827),
            Color(0xFF102033),
            Color(0xFF18213A),
          ],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _BrandGrid()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                compact ? MainAxisAlignment.center : MainAxisAlignment.end,
            children: [
              const _GoalDiggerMark(size: 64),
              SizedBox(height: compact ? 16 : 24),
              Text(
                'Goal Digger',
                style: TextStyle(
                  color: _authText,
                  fontSize: compact ? 42 : 66,
                  height: 0.96,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: const Text(
                  'Dig into the next win with goals, focus sessions, streaks, and a little momentum in your pocket.',
                  style: TextStyle(
                    color: _authMuted,
                    fontSize: 17,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: 28),
                const _PreviewStrip(),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AuthFormPanel extends StatefulWidget {
  const _AuthFormPanel({
    required this.onEmailAuth,
    required this.onGoogle,
    required this.onGuest,
    required this.onClearError,
    required this.isLoading,
    required this.errorMessage,
  });

  final EmailAuthCallback onEmailAuth;
  final VoidCallback onGoogle;
  final VoidCallback onGuest;
  final VoidCallback onClearError;
  final bool isLoading;
  final String? errorMessage;

  @override
  State<_AuthFormPanel> createState() => _AuthFormPanelState();
}

class _AuthFormPanelState extends State<_AuthFormPanel> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.isLoading) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    widget.onClearError();
    await widget.onEmailAuth(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
      _isSignUp,
    );
  }

  void _toggleMode() {
    setState(() => _isSignUp = !_isSignUp);
    widget.onClearError();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isSignUp ? 'Create your account' : 'Welcome back';
    final primaryLabel = _isSignUp ? 'Create account' : 'Log in';
    final socialLabel =
        _isSignUp ? 'Sign up with Google' : 'Continue with Google';
    final switchPrompt =
        _isSignUp ? 'Already have an account?' : 'New to Goal Digger?';
    final switchLabel = _isSignUp ? 'Log in' : 'Create account';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      decoration: BoxDecoration(
        color: _authPanel,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _authBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 34,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: _GoalDiggerMark(size: 52)),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _authText,
                fontSize: 38,
                height: 1.02,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            if (_isSignUp) ...[
              _AuthTextField(
                controller: _nameController,
                label: 'Display name',
                hint: 'What should we call you?',
                icon: Icons.badge_outlined,
                textInputAction: TextInputAction.next,
                enabled: !widget.isLoading,
                onChanged: (_) => widget.onClearError(),
              ),
              const SizedBox(height: 14),
            ],
            _AuthTextField(
              controller: _emailController,
              label: 'Email address',
              hint: 'name@domain.com',
              icon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: !widget.isLoading,
              onChanged: (_) => widget.onClearError(),
              validator: _validateEmail,
            ),
            const SizedBox(height: 14),
            _AuthTextField(
              controller: _passwordController,
              label: 'Password',
              hint: _isSignUp ? 'At least 6 characters' : 'Your password',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              enabled: !widget.isLoading,
              onChanged: (_) => widget.onClearError(),
              onFieldSubmitted: (_) => _submit(),
              validator: _validatePassword,
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                onPressed: widget.isLoading
                    ? null
                    : () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _authMuted,
                ),
              ),
            ),
            if (widget.errorMessage != null) ...[
              const SizedBox(height: 14),
              _InlineAuthError(message: widget.errorMessage!),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: widget.isLoading ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: _authAction,
                disabledBackgroundColor: _authAction.withValues(alpha: 0.52),
                foregroundColor: const Color(0xFF05130D),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        color: Color(0xFF05130D),
                      ),
                    )
                  : Text(primaryLabel),
            ),
            const SizedBox(height: 22),
            const _AuthDivider(),
            const SizedBox(height: 18),
            _SocialAuthButton(
              icon: Icons.g_mobiledata_rounded,
              iconColor: _authBlue,
              label: socialLabel,
              onPressed: widget.isLoading ? null : widget.onGoogle,
            ),
            const SizedBox(height: 12),
            _SocialAuthButton(
              icon: Icons.person_outline_rounded,
              iconColor: _authCoral,
              label: 'Preview as guest',
              onPressed: widget.isLoading ? null : widget.onGuest,
            ),
            const SizedBox(height: 28),
            Text(
              switchPrompt,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _authMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: widget.isLoading ? null : _toggleMode,
              child: Text(
                switchLabel,
                style: const TextStyle(
                  color: _authText,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required.';
    if (!email.contains('@') || !email.contains('.')) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password is required.';
    if (_isSignUp && password.length < 6) {
      return 'Use at least 6 characters.';
    }
    return null;
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.enabled,
    required this.onChanged,
    this.validator,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(
        color: _authText,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _authMuted),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF0F172A),
        labelStyle: const TextStyle(
          color: _authText,
          fontWeight: FontWeight.w900,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF7C8CA3),
          fontWeight: FontWeight.w600,
        ),
        errorStyle: const TextStyle(
          color: Color(0xFFFFA7A7),
          fontWeight: FontWeight.w800,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _authBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _authAction, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _authCoral),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _authCoral, width: 2),
        ),
      ),
    );
  }
}

class _SocialAuthButton extends StatelessWidget {
  const _SocialAuthButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: iconColor, size: 28),
      label: Text(label, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        foregroundColor: _authText,
        disabledForegroundColor: _authMuted,
        side: const BorderSide(color: Color(0xFF59667A), width: 1.4),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}

class _AuthDivider extends StatelessWidget {
  const _AuthDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: _authBorder)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or',
            style: TextStyle(
              color: _authMuted,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: _authBorder)),
      ],
    );
  }
}

class _InlineAuthError extends StatelessWidget {
  const _InlineAuthError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: gdError.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gdError.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFFFB4B4)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: _authText,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalDiggerMark extends StatelessWidget {
  const _GoalDiggerMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _authText,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _authAction.withValues(alpha: 0.24),
            blurRadius: size * 0.5,
            offset: Offset(0, size * 0.18),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.track_changes_rounded,
              color: gdPrimary, size: size * 0.58),
          Positioned(
            right: size * 0.18,
            bottom: size * 0.2,
            child: Icon(
              Icons.terrain_rounded,
              color: _authCoral,
              size: size * 0.28,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandGrid extends StatelessWidget {
  const _BrandGrid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BrandGridPainter());
  }
}

class _BrandGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.045)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (var y = 0.0; y < size.height; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final accentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..color = _authAction.withValues(alpha: 0.16);
    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.55, size.height * 0.08, 180, 180),
      0.2,
      4.5,
      false,
      accentPaint,
    );

    final coralPaint = Paint()
      ..color = _authCoral.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(
      Offset(size.width * 0.86, size.height * 0.78),
      58,
      coralPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PreviewStrip extends StatelessWidget {
  const _PreviewStrip();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: const [
        _PreviewPill(
          icon: Icons.flag_rounded,
          label: '4 goals active',
          color: _authAction,
        ),
        _PreviewPill(
          icon: Icons.local_fire_department_rounded,
          label: '7 day streak',
          color: _authCoral,
        ),
        _PreviewPill(
          icon: Icons.timer_rounded,
          label: 'Focus ready',
          color: _authBlue,
        ),
      ],
    );
  }
}

class _PreviewPill extends StatelessWidget {
  const _PreviewPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _authPanelSoft.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _authBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: _authText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
