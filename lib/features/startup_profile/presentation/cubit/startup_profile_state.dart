import 'package:equatable/equatable.dart';
import '../../domain/entities/startup_profile_entity.dart';

abstract class StartupProfileState extends Equatable {
  const StartupProfileState();

  @override
  List<Object?> get props => [];
}

class StartupProfileInitial extends StartupProfileState {
  const StartupProfileInitial();
}

class StartupProfileLoading extends StartupProfileState {
  const StartupProfileLoading();
}

class StartupProfileCreating extends StartupProfileState {
  const StartupProfileCreating();
}

class StartupProfileLoaded extends StartupProfileState {
  final StartupProfileEntity profile;

  const StartupProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class StartupProfileUpdating extends StartupProfileState {
  final StartupProfileEntity currentProfile;

  const StartupProfileUpdating(this.currentProfile);

  @override
  List<Object?> get props => [currentProfile];
}

class StartupProfileError extends StartupProfileState {
  final String message;

  const StartupProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
