class MediaDataModel {
  String filePath;
  String? fileUrl;
  String? fileName;
  int? width;
  int? height;

  MediaDataModel(
      {required this.filePath,
      this.height,
      this.width,
      this.fileUrl,
      this.fileName});
}
