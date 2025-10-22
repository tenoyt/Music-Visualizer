import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer song;
FFT fft;
BeatDetect beat;

ArrayList<Float> amplitudeHistory = new ArrayList<Float>();
float rotationAngle = 0;
color[] gradientColors;

void setup() {
  size(800, 600);
  minim = new Minim(this);
  song = minim.loadFile("your_audio.mp3", 1024); // Replace with your audio file
  fft = new FFT(song.bufferSize(), song.sampleRate());
  beat = new BeatDetect();
  song.play();

  // Create a color gradient from blue to pink
  gradientColors = new color[fft.specSize()];
  for (int i = 0; i < gradientColors.length; i++) {
    float t = map(i, 0, gradientColors.length, 0, 1);
    gradientColors[i] = lerpColor(color(0, 100, 255), color(255, 0, 150), t);
  }
}

void draw() {
  background(0);
  fft.forward(song.mix);
  beat.detect(song.mix);

  float amplitude = song.mix.level();
  amplitudeHistory.add(amplitude);
  if (amplitudeHistory.size() > width) {
    amplitudeHistory.remove(0);
  }

  // Rotate slowly, faster on beat
  float rotationSpeed = beat.isOnset() ? 0.05 : 0.01;
  rotationAngle += rotationSpeed;

  pushMatrix();
  translate(width / 2, height / 2);
  rotate(rotationAngle);
  drawCircularSpectrum();
  popMatrix();

  drawAmplitudeTrail();
}

void drawCircularSpectrum() {
  noFill();
  beginShape();
  for (int i = 0; i < fft.specSize(); i++) {
    float angle = map(i, 0, fft.specSize(), 0, TWO_PI);
    float bandValue = fft.getBand(i);
    float radius = 150 + bandValue * 2;
    float x = cos(angle) * radius;
    float y = sin(angle) * radius;

    stroke(gradientColors[i]);
    vertex(x, y);
  }
  endShape(CLOSE);
}

void drawAmplitudeTrail() {
  noFill();
  stroke(0, 255, 0);
  beginShape();
  for (int i = 0; i < amplitudeHistory.size(); i++) {
    float y = map(amplitudeHistory.get(i), 0, 0.5, height, height - 100);
    vertex(i, y);
  }
  endShape();
}


