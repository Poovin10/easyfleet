import 'dart:typed_data';

import 'package:easyfleet_domain/easyfleet_domain.dart';
import 'package:easyfleet_network/easyfleet_network.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';

enum OnboardingRole { driver, transporter }

class OnboardingState {
  const OnboardingState({
    this.role,
    this.verification = VerificationStatus.notSubmitted,
    this.isSubmitting = false,
    this.error,
  });

  final OnboardingRole? role;
  final VerificationStatus verification;
  final bool isSubmitting;
  final String? error;

  bool get isApproved => verification == VerificationStatus.approved;

  OnboardingState copyWith({
    OnboardingRole? role,
    VerificationStatus? verification,
    bool? isSubmitting,
    String? error,
  }) {
    return OnboardingState(
      role: role ?? this.role,
      verification: verification ?? this.verification,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

/// Drives DL (driver) and GST (transporter) onboarding with manual approval.
final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  Future<void> refresh() async {
    final auth = ref.read(authControllerProvider);
    final userId = auth.userId;
    if (userId == null) return;

    final status = await ref
        .read(onboardingServiceProvider)
        .verificationStatus(
          userId: userId,
          isTransporter: state.role == OnboardingRole.transporter,
        );
    state = state.copyWith(
      verification: VerificationStatus.values.byName(status),
    );
  }

  Future<void> submitDriverDl({
    required String dlNumber,
    required LicenseClass licenseClass,
    required Uint8List documentBytes,
  }) async {
    await _submit(OnboardingRole.driver, () async {
      final userId = ref.read(authControllerProvider).userId!;
      final service = ref.read(onboardingServiceProvider);
      final url = await service.uploadDocument(
        userId: userId,
        kind: 'dl',
        bytes: documentBytes,
        extension: 'jpg',
      );
      await service.submitDriverDl(
        userId: userId,
        dlNumber: dlNumber,
        licenseClass: licenseClass,
        documentUrl: url,
      );
    });
  }

  Future<void> submitCompanyGst({
    required String gst,
    required String legalName,
    required Uint8List documentBytes,
  }) async {
    await _submit(OnboardingRole.transporter, () async {
      final userId = ref.read(authControllerProvider).userId!;
      final service = ref.read(onboardingServiceProvider);
      final url = await service.uploadDocument(
        userId: userId,
        kind: 'gst',
        bytes: documentBytes,
        extension: 'jpg',
      );
      await service.submitCompanyGst(
        userId: userId,
        gst: gst,
        legalName: legalName,
        documentUrl: url,
      );
    });
  }

  Future<void> _submit(
    OnboardingRole role,
    Future<void> Function() action,
  ) async {
    state = state.copyWith(role: role, isSubmitting: true, error: null);
    try {
      await action();
      state = state.copyWith(
        isSubmitting: false,
        verification: VerificationStatus.pending,
      );
    } catch (error) {
      state = state.copyWith(isSubmitting: false, error: error.toString());
    }
  }
}
