import 'package:ethioventure/features/investor_profile/domain/entities/investor_profile_entity.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class InvestorProfileState {
  const InvestorProfileState();
}

/// Initial state before any action is taken.
final class InvestorProfileInitial extends InvestorProfileState {
  const InvestorProfileInitial();
}

/// State when fetching the investor profile.
final class InvestorProfileLoading extends InvestorProfileState {
  const InvestorProfileLoading();
}

/// State when a write operation (create/update/delete) is in progress.
final class InvestorProfileSaving extends InvestorProfileState {
  const InvestorProfileSaving();
}

/// State when an investor profile is successfully retrieved or persisted.
final class InvestorProfileLoaded extends InvestorProfileState {
  const InvestorProfileLoaded(this.profile);

  final InvestorProfileEntity profile;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvestorProfileLoaded && other.profile == profile;

  @override
  int get hashCode => profile.hashCode;
}

/// State when no investor profile exists for the current user.
final class InvestorProfileEmpty extends InvestorProfileState {
  const InvestorProfileEmpty();
}

/// State when the investor profile has been successfully deleted.
final class InvestorProfileDeleted extends InvestorProfileState {
  const InvestorProfileDeleted();
}

/// State when an operation fails.
final class InvestorProfileError extends InvestorProfileState {
  const InvestorProfileError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvestorProfileError && other.message == message;

  @override
  int get hashCode => message.hashCode;
}
