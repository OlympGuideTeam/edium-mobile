import 'package:no_screenshot/no_screenshot.dart';

class ScreenProtectionService {
  final _noScreenshot = NoScreenshot.instance;

  Future<void> enableProtection() async {
    await _noScreenshot.screenshotOff();
  }

  Future<void> disableProtection() async {
    await _noScreenshot.screenshotOn();
  }
}
