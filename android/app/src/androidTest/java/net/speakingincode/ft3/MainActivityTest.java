package net.speakingincode.ft3;

import androidx.test.rule.ActivityTestRule;
import dev.flutter.plugins.integration_test.FlutterTestRunner;
import org.junit.Rule;
import org.junit.runner.RunWith;

import com.ryanheise.audioservice.AudioServiceActivity;

@RunWith(FlutterTestRunner.class)
public class MainActivityTest {
  @Rule
  public ActivityTestRule<AudioServiceActivity> rule = new ActivityTestRule<>(AudioServiceActivity.class, true, false);
}
