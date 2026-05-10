part of 'course_detail_model.dart';

class SheetScoreModel {
  final String itemId;
  final double? score;

  const SheetScoreModel({required this.itemId, this.score});

  factory SheetScoreModel.fromJson(Map<String, dynamic> json) => SheetScoreModel(
        itemId: json['item_id'] as String,
        score: (json['score'] as num?)?.toDouble(),
      );

  SheetScore toEntity() => SheetScore(itemId: itemId, score: score);
}

