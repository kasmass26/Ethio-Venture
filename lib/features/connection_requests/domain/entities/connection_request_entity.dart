/// Represents the status of a connection request between a founder and investor.
enum ConnectionRequestStatus {
  pending,
  accepted,
  declined;

  static ConnectionRequestStatus fromString(String value) {
    return ConnectionRequestStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ConnectionRequestStatus.pending,
    );
  }
}

/// Domain entity for a connection request sent from a founder to an investor.
class ConnectionRequestEntity {
  const ConnectionRequestEntity({
    required this.id,
    required this.founderUserId,
    required this.investorUserId,
    this.startupProfileId,
    this.investorProfileId,
    required this.status,
    this.message,
    required this.createdAt,
    required this.updatedAt,
    // Display helpers (optional, populated by join)
    this.founderName,
    this.startupName,
    this.investorName,
  });

  final String id;
  final String founderUserId;
  final String investorUserId;
  final String? startupProfileId;
  final String? investorProfileId;
  final ConnectionRequestStatus status;
  final String? message;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Display helpers joined from profiles
  final String? founderName;
  final String? startupName;
  final String? investorName;

  bool get isPending => status == ConnectionRequestStatus.pending;
  bool get isAccepted => status == ConnectionRequestStatus.accepted;
  bool get isDeclined => status == ConnectionRequestStatus.declined;
}
