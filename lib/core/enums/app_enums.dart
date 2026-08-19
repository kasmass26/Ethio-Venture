// Database-aligned Enums for EthioVenture
// Matches PostgreSQL database ENUM types.

/// CREATE TYPE account_type AS ENUM ('startup', 'investor');
enum AccountType {
  startup('startup'),
  investor('investor');

  final String value;
  const AccountType(this.value);

  static AccountType fromString(String val) {
    return AccountType.values.firstWhere(
      (e) => e.value == val.toLowerCase(),
      orElse: () => AccountType.startup,
    );
  }
}

/// CREATE TYPE funding_stage AS ENUM ('Idea', 'Pre-Seed', 'Seed', 'Series A', 'Series B', 'Series C', 'Series D', 'Growth');
enum FundingStage {
  idea('Idea'),
  preSeed('Pre-Seed'),
  seed('Seed'),
  seriesA('Series A'),
  seriesB('Series B'),
  seriesC('Series C'),
  seriesD('Series D'),
  growth('Growth');

  final String value;
  const FundingStage(this.value);

  static FundingStage fromString(String val) {
    return FundingStage.values.firstWhere(
      (e) => e.value.toLowerCase() == val.toLowerCase(),
      orElse: () => FundingStage.idea,
    );
  }
}

/// CREATE TYPE investor_type AS ENUM ('angel', 'vc', 'firm');
enum InvestorType {
  angel('angel'),
  vc('vc'),
  firm('firm');

  final String value;
  const InvestorType(this.value);

  static InvestorType fromString(String val) {
    return InvestorType.values.firstWhere(
      (e) => e.value == val.toLowerCase() || (val.toLowerCase() == 'institutional' && e == InvestorType.firm),
      orElse: () => InvestorType.angel,
    );
  }
}

/// CREATE TYPE document_type AS ENUM ('pitch_deck', 'business_doc', 'other');
enum DocumentType {
  pitchDeck('pitch_deck'),
  businessDoc('business_doc'),
  other('other');

  final String value;
  const DocumentType(this.value);

  static DocumentType fromString(String val) {
    return DocumentType.values.firstWhere(
      (e) => e.value == val.toLowerCase(),
      orElse: () => DocumentType.other,
    );
  }
}

/// CREATE TYPE match_status AS ENUM ('recommended', 'viewed', 'contacted', 'archived');
enum MatchStatus {
  recommended('recommended'),
  viewed('viewed'),
  contacted('contacted'),
  archived('archived');

  final String value;
  const MatchStatus(this.value);

  static MatchStatus fromString(String val) {
    return MatchStatus.values.firstWhere(
      (e) => e.value == val.toLowerCase(),
      orElse: () => MatchStatus.recommended,
    );
  }
}

/// CREATE TYPE notification_type AS ENUM ('match', 'message', 'system');
enum NotificationType {
  match('match'),
  message('message'),
  system('system');

  final String value;
  const NotificationType(this.value);

  static NotificationType fromString(String val) {
    return NotificationType.values.firstWhere(
      (e) => e.value == val.toLowerCase(),
      orElse: () => NotificationType.system,
    );
  }
}
