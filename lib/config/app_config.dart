class AppConfig {
  static const supabaseUrl = 'https://wywbhjsepqndygicuwbc.supabase.co';
  static const supabaseAnonKey =
      'sb_publishable_6jMKuokoxh3K7-XmuHP-qQ_efLvFlH0';

  // From Google Cloud Console → Credentials → Web client
  static const googleWebClientId =
      '718364120617-c80vejeh4qu0cg9f3novhgiifk4e9g1i.apps.googleusercontent.com';

  // From Google Cloud Console → Credentials → iOS client
  static const googleIosClientId =
      '718364120617-fggnfesgnv0fol9atoufae09l8k6qo0o.apps.googleusercontent.com';

  // Reversed iOS client ID — added as URL scheme in ios/Runner/Info.plist
  static const googleIosReversedClientId =
      'com.googleusercontent.apps.718364120617-fggnfesgnv0fol9atoufae09l8k6qo0o';
}
