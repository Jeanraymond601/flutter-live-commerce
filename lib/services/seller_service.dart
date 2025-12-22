import '../models/seller_profile.dart';

class SellerService {
  // ignore: unused_field
  final String _baseUrl =
      'https://api.votre-app.com'; // À remplacer par votre URL

  Future<SellerProfile> getSellerProfile() async {
    // Simulation d'une API call
    await Future.delayed(const Duration(seconds: 1)); // Simuler un délai réseau

    // Pour l'instant, retourner un profil par défaut
    // Dans une vraie application, vous feriez:
    // final response = await http.get(Uri.parse('$_baseUrl/api/seller/profile'));
    // return SellerProfile.fromMap(json.decode(response.body));

    return SellerProfile.defaultProfile();
  }

  Future<bool> updateProfileImage(String imagePath) async {
    // Simulation de l'upload d'image
    await Future.delayed(const Duration(seconds: 2));

    // Dans une vraie application:
    // var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/seller/profile/image'));
    // request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    // var response = await request.send();
    // return response.statusCode == 200;

    return true;
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    await Future.delayed(const Duration(seconds: 1));

    // Simulation de la mise à jour
    return true;
  }

  Future<bool> updateFacebookToken(String token) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> logout() async {
    await Future.delayed(const Duration(seconds: 1));

    // Ici, vous effaceriez le token d'authentification, etc.
    return true;
  }
}
