class OnboardingContents {
  final String title;
  final String image;
  final String desc;

  OnboardingContents({
    required this.title,
    required this.image,
    required this.desc,
  });
}

List<OnboardingContents> contents = [
  OnboardingContents(
    title: "Welcome to MoonChat",
    image: "images/icon.png",
    desc: "Connect with your universe through secure, fun, and personalized messaging.",
  ),
  OnboardingContents(
    title: "Stay Connected to the market",
    image: "images/icon.png",
    desc:
    "Get real-time updates and stay ahead of the curve.",
  ),
  OnboardingContents(
    title: "Get notified when work happens",
    image: "images/icon.png",
    desc:
    "Take control of notifications, collaborate live or on your own time.",
  ),
];