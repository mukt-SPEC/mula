import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:facial_liveness_verification/facial_liveness_verification.dart';
import 'package:flutter/material.dart';
import 'package:mula/root_page.dart';

enum _LivenessUiPhase { initializing, ready, running, success, error }

class LivenessCheckView extends StatefulWidget {
  const LivenessCheckView({super.key});

  @override
  State<LivenessCheckView> createState() => _LivenessCheckViewState();
}

class _LivenessCheckViewState extends State<LivenessCheckView> {
  static const String _defaultInstruction = 'Center your face in the frame';

  LivenessDetector? _detector;
  StreamSubscription<LivenessState>? _subscription;

  _LivenessUiPhase _uiPhase = _LivenessUiPhase.initializing;
  LivenessStateType? _currentStateType;
  String _status = 'Preparing camera...';
  bool _isResetting = false;

  @override
  void initState() {
    super.initState();
    _initializeForReadyState();
  }

  Future<void> _initializeForReadyState() async {
    if (mounted) {
      setState(() {
        _uiPhase = _LivenessUiPhase.initializing;
        _currentStateType = null;
        _status = 'Preparing camera...';
      });
    }

    await _replaceDetector();
    final detector = _detector;
    if (detector == null) return;

    try {
      await detector.initialize();
      if (!mounted) return;

      setState(() {
        _uiPhase = _LivenessUiPhase.ready;
        _status = _defaultInstruction;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _uiPhase = _LivenessUiPhase.error;
        _status = 'Unable to access camera. Tap Cancel to retry.';
      });
    }
  }

  Future<void> _replaceDetector() async {
    await _subscription?.cancel();
    _subscription = null;

    final existingDetector = _detector;
    if (existingDetector != null) {
      try {
        await existingDetector.dispose();
      } catch (_) {}
    }

    final detector = LivenessDetector(
      const LivenessConfig(enableAntiSpoofing: true, shuffleChallenges: true),
    );

    _detector = detector;
    _subscription = detector.stateStream.listen(_onLivenessState);
  }

  Future<void> _startVerification() async {
    if (_uiPhase != _LivenessUiPhase.ready || _isResetting) return;

    final detector = _detector;
    if (detector == null) return;

    setState(() {
      _uiPhase = _LivenessUiPhase.running;
      _currentStateType = LivenessStateType.detecting;
      _status = 'Position your face in the frame';
    });

    try {
      await detector.start();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _uiPhase = _LivenessUiPhase.error;
        _currentStateType = LivenessStateType.error;
        _status = 'Could not start verification. Tap Cancel to reset.';
      });
    }
  }

  Future<void> _resetLivenessCheck() async {
    if (_isResetting) return;

    setState(() {
      _isResetting = true;
    });

    await _initializeForReadyState();

    if (!mounted) return;
    setState(() {
      _isResetting = false;
    });
  }

  void _onLivenessState(LivenessState state) {
    if (!mounted) return;

    final nextStatus = _mapStatusMessage(state);

    if (state.type == LivenessStateType.completed) {
      setState(() {
        _uiPhase = _LivenessUiPhase.success;
        _currentStateType = state.type;
        _status = nextStatus;
      });

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RootScreen()),
        );
      });
      return;
    }

    if (state.type == LivenessStateType.error) {
      setState(() {
        _uiPhase = _LivenessUiPhase.error;
        _currentStateType = state.type;
        _status = nextStatus;
      });
      unawaited(_detector?.stop());
      return;
    }

    if (_uiPhase != _LivenessUiPhase.running) return;

    setState(() {
      _currentStateType = state.type;
      _status = nextStatus;
    });
  }

  String _mapStatusMessage(LivenessState state) {
    switch (state.type) {
      case LivenessStateType.initialized:
      case LivenessStateType.detecting:
        return 'Position your face in the frame';
      case LivenessStateType.noFace:
        return 'No face detected - look at the camera';
      case LivenessStateType.faceDetected:
      case LivenessStateType.positioning:
        return 'Move your face to the center';
      case LivenessStateType.positioned:
        return 'Hold still...';
      case LivenessStateType.challengeInProgress:
        return state.currentChallenge?.instruction ?? 'Follow the instruction';
      case LivenessStateType.challengeCompleted:
        return 'Great! Keep going...';
      case LivenessStateType.completed:
        return 'Verified successfully';
      case LivenessStateType.error:
        return state.error?.message ??
            'Verification failed. Tap Cancel to retry.';
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    unawaited(_detector?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canStart =
        _uiPhase == _LivenessUiPhase.ready && !_isResetting && !_isBusy;
    final actionLabel = _primaryActionLabel;
    final statusMessage = _uiPhase == _LivenessUiPhase.running
        ? _status
        : _defaultInstruction;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 520,
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        _buildHeaderBadge(),
                        const SizedBox(height: 32),
                        const Text(
                          'Identity Verification',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF001A3F),
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'We need to perform a quick liveness check',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF4A5568),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildInstructionPill(statusMessage),
                        const SizedBox(height: 32),
                        _buildCameraCircle(),
                        const SizedBox(height: 32),
                        _buildEncryptedPill(),
                        const Spacer(),
                        const SizedBox(height: 24),
                        _buildPrimaryButton(
                          label: actionLabel,
                          enabled: canStart,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _isResetting ? null : _resetLivenessCheck,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF1E6AFF),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            _isResetting ? 'Resetting...' : 'Cancel',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
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

  bool get _isBusy =>
      _uiPhase == _LivenessUiPhase.initializing ||
      _uiPhase == _LivenessUiPhase.running;

  String get _primaryActionLabel {
    switch (_uiPhase) {
      case _LivenessUiPhase.initializing:
        return 'Preparing...';
      case _LivenessUiPhase.running:
        return 'Verifying...';
      case _LivenessUiPhase.success:
        return 'Verified';
      case _LivenessUiPhase.error:
      case _LivenessUiPhase.ready:
        return 'Start Verification';
    }
  }

  Widget _buildHeaderBadge() {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFD6E4FF),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.face_retouching_natural_rounded,
        size: 36,
        color: Color(0xFF001A3F),
      ),
    );
  }

  Widget _buildInstructionPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC0D7FF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: Color(0xFF1E6AFF),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1A2B45),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraCircle() {
    final previewController = _detector?.cameraController;
    final showLivePreview =
        _uiPhase == _LivenessUiPhase.running &&
        previewController != null &&
        previewController.value.isInitialized;
    final circleSize = math.min(MediaQuery.sizeOf(context).width * 0.78, 380.0);

    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF1E6AFF), width: 6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E6AFF).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: ClipOval(
        child: ColoredBox(
          color: const Color(0xFFE2E8F0),
          child: showLivePreview
              ? _buildLivePreview(previewController!)
              : const Center(
                  child: Icon(
                    Icons.videocam_outlined,
                    size: 80,
                    color: Color(0xFFCBD5E0),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLivePreview(CameraController controller) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) {
      return CameraPreview(controller);
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: previewSize.height,
        height: previewSize.width,
        child: CameraPreview(controller),
      ),
    );
  }

  Widget _buildEncryptedPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shield_rounded, size: 16, color: Color(0xFF001A3F)),
          const SizedBox(width: 8),
          Text(
            'End-to-end encrypted',
            style: TextStyle(
              color: const Color(0xFF718096),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({required String label, required bool enabled}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled ? _startVerification : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF001A3F),
          disabledBackgroundColor: const Color(0xFFE2E8F0),
          foregroundColor: Colors.white,
          disabledForegroundColor: const Color(0xFFA0AEC0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

