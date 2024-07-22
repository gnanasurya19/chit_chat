class UserModel {
  String? email;
  String? password;
  String? name;
  String? profileURL;
  bool? isVerified;
  UserModel(
      {this.name, this.email, this.password, this.profileURL, this.isVerified});
}
