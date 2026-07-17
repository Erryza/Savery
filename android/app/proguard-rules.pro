# google_mlkit_text_recognition bundles a generic TextRecognizer that supports
# optional script modules (Chinese/Japanese/Korean/Devanagari) which this app
# does not depend on or use (only the default Latin recognizer is used for
# receipt OCR). R8 can't find those classes at compile time since their
# dependencies aren't included — safe to silence since they're never called.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
