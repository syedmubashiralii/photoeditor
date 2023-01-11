class BackgroundImage {
  String? id;
  String? name;
  String? category;
  String? template_json_link;
  String? thumbnail_link;
  String? created_at;
  String? updated_at;

  BackgroundImage({
    required this.id,
    required this.name,
    required this.category,
    required this.template_json_link,
    required this.thumbnail_link,
    required this.created_at,
    required this.updated_at,
  });

  BackgroundImage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    category = json['category'];
    template_json_link = json['template_json_link'];
    thumbnail_link = json['thumbnail_link'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['category'] = this.category;
    data['template_json_link'] = this.template_json_link;
    data['created_at'] = this.created_at;
    data['updated_at'] = this.updated_at;
    return data;
  }
}
