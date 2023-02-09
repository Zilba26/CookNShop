import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';

class ChatGPTAPI {
  static const String key = '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';
  static final openAI = OpenAI.instance.build(token: key, isLogger: true);

  Future<String?> request(prompt) async {
    final request = CompleteText(prompt: prompt, model: kTranslateModelV3, maxTokens: 200);

    CTResponse? response = await openAI.onCompleteText(request: request);
    return response?.choices[0].text;
  }

  Future<String?> getQuantityAndUnit(Map data) async {
    print(data.toString());
    String prompt = baseQuantityAndUnitPrompt + data.toString();
    return await request(prompt);
  }

  static const String baseQuantityAndUnitPrompt = "Peux tu me séparer la quantité et l'unité d'un ingrédient. Voici quelques exemples :" +
  "Premier exemple :" +
  "Entrée (ce que je vais t'envoyer) :" +
  "{" +
  "'data': '300g'" +
  "}" +
  "Sortie (Ce que tu me renvoie) :" +
  "{" +
  "'quantity': 300" +
  "'unit': 'g'" +
  "}" +
"" +
  "Deuxième exemple :" +
  "Entrée (ce que je vais t'envoyer) :" +
  "{" +
  "'data': '300 g'" +
  "}" +
  "Sortie (Ce que tu me renvoie) :" +
  "{" +
  "'quantity': 300" +
  "'unit': 'g'" +
  "}" +
"" +
  "Troisième exemple :" +
  "Entrée (ce que je vais t'envoyer) :" +
  "{" +
  "'data': '2 c.à.s'" +
  "}" +
  "Sortie (Ce que tu me renvoie) :" +
  "{" +
  "'quantity': 2" +
  "'unit': 'c.à.s'" +
  "}" +
"" +
  "Quatrième exemple :" +
  "Entrée (ce que je vais t'envoyer) :" +
  "{" +
  "'data': '1'" +
  "}" +
  "Sortie (Ce que tu me renvoie) :" +
  "{" +
  "'quantity': 1" +
  "'unit': """ +
  "}" +
"" +
  "Cinquième exemple :" +
  "Entrée (ce que je vais t'envoyer) :" +
  "{" +
  "'data': """ +
  "}" +
  "Sortie (Ce que tu me renvoie) :" +
  "{" +
  "'quantity': """ +
  "'unit': """ +
  "}" +
"" +
  "Sixième exemple :" +
  "Entrée (ce que je vais t'envoyer) :" +
  "{" +
  "'data': '50 cl'" +
  "}" +
  "Sortie (Ce que tu me renvoie) :" +
  "{" +
  "'quantity': 50" +
  "'unit': cl" +
  "}" +

  "Evidemment, renvoie moi une map sous format JSON sans écrire le \"Sortie :\". Maintenant que tu as les exemples pour satisfaire ma demande, voici la réelle entrée :";

}