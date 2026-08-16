import '../../domain/entities/admin_entity.dart';

abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final AdminEntity admin;

  AdminLoaded(this.admin);
}

class AdminError extends AdminState {
  final String message;

  AdminError(this.message);
}
