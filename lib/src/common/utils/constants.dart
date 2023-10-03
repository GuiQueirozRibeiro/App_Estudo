class Constants {
  static const openaiApiKey = String.fromEnvironment('OPENAI_KEY');

  Constants() {
    if (openaiApiKey.isEmpty) {
      throw AssertionError('OpenAI API key is not set');
    }
  }

  static const baseUrl = 'https://api.openai.com/v1';
}
