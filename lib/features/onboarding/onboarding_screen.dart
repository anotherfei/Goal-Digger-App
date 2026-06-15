import 'package:flutter/material.dart';

import '../../core/theme/gd_design.dart';

typedef EmailAuthCallback = Future<void> Function(
  String email,
  String password,
  String? displayName,
  bool isSignUp,
);
typedef PasswordResetCallback = Future<bool> Function(String email);

// Getters (not stored values) so they resolve against the live light/dark
// tokens on every read instead of baking a colour at first access.
Color get _authBackground => gdBackground;
Color get _authPanel => gdSurface;
Color get _authPanelSoft => gdCardLight;
Color get _authBorder => gdBorder;
Color get _authText => gdInk;
Color get _authMuted => gdMuted;
Color get _authAction => gdPrimary;
const Color _authBlue = gdPetMintTo;
Color get _authCoral => gdAccent;
const Color _googleBlue = Color(0xFF4285F4);
const Color _googleRed = Color(0xFFEA4335);
const Color _googleYellow = Color(0xFFFBBC05);
const Color _googleGreen = Color(0xFF34A853);

class _ProviderPalette {
  const _ProviderPalette({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.surface,
    required this.border,
  });

  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color surface;
  final Color border;
}

_ProviderPalette get _emailPalette => _ProviderPalette(
      primary: _authAction,
      secondary: _authBlue,
      tertiary: gdPetMintFrom,
      surface: gdPrimarySoft,
      border: const Color(0xFFD3E1F7),
    );
const _googlePalette = _ProviderPalette(
  primary: _googleBlue,
  secondary: _googleRed,
  tertiary: _googleYellow,
  surface: Color(0xFFEAF2FF),
  border: Color(0xFFD1E3FF),
);
_ProviderPalette get _guestPalette => _ProviderPalette(
      primary: _authCoral,
      secondary: gdGradientStudyFrom,
      tertiary: gdGradientCreativeFrom,
      surface: gdAccentSoft,
      border: const Color(0xFFFBD0D5),
    );

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({
    super.key,
    required this.onEmailAuth,
    required this.onPasswordReset,
    required this.onGoogle,
    required this.onGuest,
    required this.onClearError,
    required this.isLoading,
    this.errorMessage,
  });

  final EmailAuthCallback onEmailAuth;
  final PasswordResetCallback onPasswordReset;
  final VoidCallback onGoogle;
  final VoidCallback onGuest;
  final VoidCallback onClearError;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _authBackground,
      body: Stack(
        children: [
          const Positioned.fill(child: _AnimatedAuthBackdrop()),
          SafeArea(
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
                                      onPasswordReset: onPasswordReset,
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
                                    onPasswordReset: onPasswordReset,
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
        ],
      ),
    );
  }
}

class _AnimatedAuthBackdrop extends StatefulWidget {
  const _AnimatedAuthBackdrop();

  @override
  State<_AnimatedAuthBackdrop> createState() => _AnimatedAuthBackdropState();
}

class _AnimatedAuthBackdropState extends State<_AnimatedAuthBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 38),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _AuthBackdropPainter(progress: _controller.value),
            );
          },
        ),
      ),
    );
  }
}

class _AuthBackdropPainter extends CustomPainter {
  const _AuthBackdropPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _authBackground,
          gdPrimarySoft,
          gdAccentSoft,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, basePaint);

    final emailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..color = _emailPalette.primary.withValues(alpha: 0.08);
    final googlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..color = _googlePalette.primary.withValues(alpha: 0.07);
    final guestPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..color = _guestPalette.primary.withValues(alpha: 0.08);
    final bluePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = _emailPalette.secondary.withValues(alpha: 0.07);

    final compact = size.width < 520;
    final tileWidth = compact ? 260.0 : 360.0;
    final tileHeight = compact ? 240.0 : 320.0;
    final baseScale = compact ? 0.48 : 0.62;
    final drift = Offset(-progress * tileWidth, -progress * tileHeight);
    final rows = (size.height / tileHeight).ceil() + 4;
    final columns = (size.width / tileWidth).ceil() + 4;

    for (var row = -2; row < rows; row++) {
      final stagger = row.isEven ? 0.0 : tileWidth * 0.5;
      for (var column = -2; column < columns; column++) {
        final anchor = Offset(
              column * tileWidth + stagger,
              row * tileHeight,
            ) +
            drift;
        final variant = (row + column).abs() % 4;
        final mirrored = variant.isOdd;
        final scale = baseScale + (variant == 0 ? 0.05 : 0);

        _drawBackdropCluster(
          canvas,
          size,
          anchor,
          variant == 0
              ? emailPaint
              : variant == 1
                  ? googlePaint
                  : bluePaint,
          variant >= 2 ? emailPaint : guestPaint,
          scale: scale,
          mirrored: mirrored,
        );
      }
    }
  }

  void _drawBackdropCluster(
    Canvas canvas,
    Size size,
    Offset anchor,
    Paint arcPaint,
    Paint ringPaint, {
    required double scale,
    bool mirrored = false,
  }) {
    final arcRect = Rect.fromCenter(
      center: anchor,
      width: 230 * scale,
      height: 230 * scale,
    );
    canvas.drawArc(
      arcRect,
      mirrored ? 2.55 : 0.2,
      mirrored ? -4.2 : 4.5,
      false,
      arcPaint,
    );
    canvas.drawCircle(
      anchor + Offset((mirrored ? -118 : 118) * scale, 126 * scale),
      72 * scale,
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AuthBackdropPainter oldDelegate) {
    return oldDelegate.progress != progress;
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gdSurface,
            gdPrimarySoft,
            Color(0xFFFFF7F8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: gdPrimary.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
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
                child: Text(
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
    required this.onPasswordReset,
    required this.onGoogle,
    required this.onGuest,
    required this.onClearError,
    required this.isLoading,
    required this.errorMessage,
  });

  final EmailAuthCallback onEmailAuth;
  final PasswordResetCallback onPasswordReset;
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

  Future<void> _requestPasswordReset() async {
    if (widget.isLoading) return;

    final email = _emailController.text.trim();
    final emailError = _validateEmail(email);
    if (emailError != null) {
      _showResetSnack(emailError);
      return;
    }

    widget.onClearError();
    final sent = await widget.onPasswordReset(email);
    if (!mounted || !sent) return;

    _showResetSnack(
      'If this email uses password login, reset instructions were sent.',
    );
  }

  void _showResetSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
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
            color: gdPrimary.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 16),
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
              style: TextStyle(
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
                palette: _emailPalette,
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
              palette: _emailPalette,
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
              palette: _emailPalette,
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
            if (!_isSignUp) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.isLoading ? null : _requestPasswordReset,
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: _authMuted,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Used Google before? Continue with Google instead.',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: _googlePalette.primary.withValues(alpha: 0.88),
                  fontSize: 12,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (widget.errorMessage != null) ...[
              const SizedBox(height: 14),
              _InlineAuthError(message: widget.errorMessage!),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: widget.isLoading ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: _emailPalette.primary,
                disabledBackgroundColor:
                    _emailPalette.primary.withValues(alpha: 0.52),
                foregroundColor: gdOnDark,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: widget.isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        color: gdOnDark,
                      ),
                    )
                  : Text(primaryLabel),
            ),
            const SizedBox(height: 22),
            const _AuthDivider(),
            const SizedBox(height: 18),
            _SocialAuthButton(
              icon: Icons.g_mobiledata_rounded,
              palette: _googlePalette,
              multiColorAccent: true,
              label: socialLabel,
              onPressed: widget.isLoading ? null : widget.onGoogle,
            ),
            const SizedBox(height: 12),
            _SocialAuthButton(
              icon: Icons.person_outline_rounded,
              palette: _guestPalette,
              label: 'Preview as guest',
              onPressed: widget.isLoading ? null : widget.onGuest,
            ),
            const SizedBox(height: 28),
            Text(
              switchPrompt,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _authMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: widget.isLoading ? null : _toggleMode,
              child: Text(
                switchLabel,
                style: TextStyle(
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
    required this.palette,
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
  final _ProviderPalette palette;
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
      style: TextStyle(
        color: _authText,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: palette.primary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: palette.surface.withValues(alpha: 0.58),
        labelStyle: TextStyle(
          color: _authText,
          fontWeight: FontWeight.w900,
        ),
        hintStyle: TextStyle(
          color: gdHint,
          fontWeight: FontWeight.w600,
        ),
        errorStyle: TextStyle(
          color: gdError,
          fontWeight: FontWeight.w800,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: palette.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: gdError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: gdError, width: 2),
        ),
      ),
    );
  }
}

class _SocialAuthButton extends StatelessWidget {
  const _SocialAuthButton({
    required this.icon,
    required this.palette,
    required this.label,
    required this.onPressed,
    this.multiColorAccent = false,
  });

  final IconData icon;
  final _ProviderPalette palette;
  final String label;
  final VoidCallback? onPressed;
  final bool multiColorAccent;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: enabled
            ? palette.surface.withValues(alpha: 0.68)
            : _authPanelSoft.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: palette.primary.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(icon, color: palette.primary, size: 28),
            if (multiColorAccent)
              const Positioned(
                right: -2,
                bottom: 1,
                child: _GoogleAccentDots(),
              ),
          ],
        ),
        label: Text(label, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          foregroundColor: _authText,
          disabledForegroundColor: _authMuted,
          side: BorderSide(
            color: enabled ? palette.border : gdBorderStrong,
            width: 1.4,
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _GoogleAccentDots extends StatelessWidget {
  const _GoogleAccentDots();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: Stack(
        children: const [
          Positioned(
            left: 0,
            top: 1,
            child: _AccentDot(color: _googleRed),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: _AccentDot(color: _googleYellow),
          ),
          Positioned(
            left: 3,
            bottom: 0,
            child: _AccentDot(color: _googleGreen),
          ),
        ],
      ),
    );
  }
}

class _AccentDot extends StatelessWidget {
  const _AccentDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: const SizedBox(width: 5, height: 5),
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
        Padding(
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
        color: gdErrorSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gdError.withValues(alpha: 0.32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: gdError),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
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
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/app_icon2.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _BrandGrid extends StatefulWidget {
  const _BrandGrid();

  @override
  State<_BrandGrid> createState() => _BrandGridState();
}

class _BrandGridState extends State<_BrandGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _BrandGridPainter(progress: _controller.value),
        );
      },
    );
  }
}

class _BrandGridPainter extends CustomPainter {
  const _BrandGridPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const cellSize = 36.0;
    final gridDrift = -progress * cellSize;

    final linePaint = Paint()
      ..color = gdPrimary.withValues(alpha: 0.075)
      ..strokeWidth = 1;
    for (var x = -cellSize + gridDrift;
        x < size.width + cellSize;
        x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (var y = -cellSize + gridDrift;
        y < size.height + cellSize;
        y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BrandGridPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _PreviewStrip extends StatelessWidget {
  const _PreviewStrip();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _PreviewPill(
          icon: Icons.flag_rounded,
          label: '4 goals active',
          color: _emailPalette.primary,
        ),
        _PreviewPill(
          icon: Icons.local_fire_department_rounded,
          label: '7 day streak',
          color: _guestPalette.primary,
        ),
        _PreviewPill(
          icon: Icons.timer_rounded,
          label: 'Focus ready',
          color: _googlePalette.primary,
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
        color: gdSurface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _authBorder),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: _authText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
