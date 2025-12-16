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
    image: "assets/images/image1.png",
    desc: "Connect with your universe through secure, fun, and personalized messaging.",
  ),
  OnboardingContents(
    title: "Stay Connected to the market",
    image: "assets/images/image2.png",
    desc:
    "",
  ),
  OnboardingContents(
    title: "Get notified when work happens",
    image: "assets/images/image3.png",
    desc:
    "Take control of notifications, collaborate live or on your own time.",
  ),
];