/// A startup in the investor's tracked/watch list, with funding progress.
class TrackedStartup {
  final String id;
  final String name;
  final String fundingGoalLabel; // e.g. "Seeking $500k Seed"
  final int progressPercent;

  const TrackedStartup({
    required this.id,
    required this.name,
    required this.fundingGoalLabel,
    required this.progressPercent,
  });
}