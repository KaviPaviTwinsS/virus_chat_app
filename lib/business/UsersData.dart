class UsersData {
  String businessId;
  String businessName;
  String businessType;
  int createdAt;
  String email;
  String id;
  String name;
  String nickName;
  String phoneNo;
  String photoUrl;
  String status;
  String userDistanceISWITHINRADIUS;
  String user_token;
  String lastMessage;

  int userDistance;

  String distanceMetric;
  UsersData(
      {this.businessId, this.businessName, this.businessType, this.createdAt, this.email, this.id, this.name, this.nickName,
        this.phoneNo,this.photoUrl,
        this.status, this.userDistanceISWITHINRADIUS,
        this.userDistance,
        this.user_token,this.lastMessage,this.distanceMetric});

}