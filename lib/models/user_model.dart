import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel userModel) => json.encode(userModel.toJson());

class UserModel {
  late String uId, name, image, number;

  UserModel({
    required this.uId,
    required this.name,

  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uId: json["uId"],
        name: json["name"],

      );

  Map<String, dynamic> toJson() => {
        "uId": uId,
        "name": name,

      };
}
