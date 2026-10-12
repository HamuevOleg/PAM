/// Public profile data for the current app session. Passwords are never stored.
class RunnerIdentity {
  final String name;
  final String email;

  const RunnerIdentity({required this.name, required this.email});
}
