import 'dart:convert';
import 'package:hive/hive.dart';

part 'bonus.g.dart';

@HiveType(
    typeId: 20) // Make sure this ID is unique and not used by other models
class BonusResponse {
  @HiveField(0)
  bool success;

  @HiveField(1)
  List<BonusProduct> data;

  @HiveField(2)
  String message;

  BonusResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory BonusResponse.fromJson(Map<String, dynamic> json) {
    return BonusResponse(
      success: json['success'],
      data: json['data'] != null
          ? List<BonusProduct>.from(
              json['data'].map((x) => BonusProduct.fromJson(x)))
          : [],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((x) => x.toJson()).toList(),
      'message': message,
    };
  }
}

@HiveType(typeId: 21)
class BonusProduct {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title; // Product name/title

  @HiveField(2)
  String price;

  @HiveField(3)
  String? image;

  BonusProduct({
    required this.id,
    required this.title,
    required this.price,
    this.image,
  });

  factory BonusProduct.fromJson(Map<String, dynamic> json) {
    // Extract the title from attribute_data based on available language
    String title = '';
    if (json['attribute_data'] != null &&
        json['attribute_data']['name'] != null &&
        json['attribute_data']['name']['chopar'] != null) {
      var chopar = json['attribute_data']['name']['chopar'];
      // Try to get the Russian name first, then Uzbek, then English
      title = chopar['ru'] ??
          chopar['uz'] ??
          chopar['en'] ??
          json['custom_name'] ??
          '';
    } else if (json['custom_name'] != null) {
      title = json['custom_name'];
    }

    return BonusProduct(
      id: json['id'],
      title: title,
      price: json['price'] ?? '0',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'image': image,
    };
  }
}

@HiveType(typeId: 22)
class AttributeData {
  @HiveField(0)
  LanguageData? name;

  @HiveField(1)
  LanguageData? xmlId;

  @HiveField(2)
  LanguageData? description;

  AttributeData({
    this.name,
    this.xmlId,
    this.description,
  });

  factory AttributeData.fromJson(Map<String, dynamic> json) {
    return AttributeData(
      name: json['name'] != null ? LanguageData.fromJson(json['name']) : null,
      xmlId:
          json['xml_id'] != null ? LanguageData.fromJson(json['xml_id']) : null,
      description: json['description'] != null
          ? LanguageData.fromJson(json['description'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) {
      data['name'] = name!.toJson();
    }
    if (xmlId != null) {
      data['xml_id'] = xmlId!.toJson();
    }
    if (description != null) {
      data['description'] = description!.toJson();
    }
    return data;
  }
}

@HiveType(typeId: 23)
class LanguageData {
  @HiveField(0)
  Chopar? chopar;

  LanguageData({
    this.chopar,
  });

  factory LanguageData.fromJson(Map<String, dynamic> json) {
    return LanguageData(
      chopar: json['chopar'] != null ? Chopar.fromJson(json['chopar']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (chopar != null) {
      data['chopar'] = chopar!.toJson();
    }
    return data;
  }
}

@HiveType(typeId: 24)
class Chopar {
  @HiveField(0)
  String? ru;

  @HiveField(1)
  String? uz;

  @HiveField(2)
  String? en;

  @HiveField(3)
  String? val;

  Chopar({
    this.ru,
    this.uz,
    this.en,
    this.val,
  });

  factory Chopar.fromJson(Map<String, dynamic> json) {
    return Chopar(
      ru: json['ru'],
      uz: json['uz'],
      en: json['en'],
      val: json['val'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (ru != null) {
      data['ru'] = ru;
    }
    if (uz != null) {
      data['uz'] = uz;
    }
    if (en != null) {
      data['en'] = en;
    }
    if (val != null) {
      data['val'] = val;
    }
    return data;
  }
}

@HiveType(typeId: 25)
class Modifier {
  @HiveField(0)
  int id;

  @HiveField(1)
  String createdAt;

  @HiveField(2)
  String updatedAt;

  @HiveField(3)
  String name;

  @HiveField(4)
  String xmlId;

  @HiveField(5)
  int price;

  @HiveField(6)
  int weight;

  @HiveField(7)
  String groupId;

  @HiveField(8)
  dynamic nameUz;

  @HiveField(9)
  List<dynamic> assets;

  Modifier({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.xmlId,
    required this.price,
    required this.weight,
    required this.groupId,
    this.nameUz,
    required this.assets,
  });

  factory Modifier.fromJson(Map<String, dynamic> json) {
    return Modifier(
      id: json['id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      name: json['name'],
      xmlId: json['xml_id'],
      price: json['price'],
      weight: json['weight'],
      groupId: json['groupId'],
      nameUz: json['name_uz'],
      assets: json['assets'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'name': name,
      'xml_id': xmlId,
      'price': price,
      'weight': weight,
      'groupId': groupId,
      'name_uz': nameUz,
      'assets': assets,
    };
  }
}
