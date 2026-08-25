package com.ardakadi.productivityapp

import io.flutter.embedding.android.FlutterFragmentActivity

// FAZ 15 — `local_auth`, biyometrik prompt'u (BiometricPrompt) göstermek
// için bir FragmentActivity gerektirir; düz FlutterActivity ile
// `local_auth`'un authenticate() çağrısı sessizce başarısız olur.
class MainActivity : FlutterFragmentActivity()
