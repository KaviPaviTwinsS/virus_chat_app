class BusinessChatData {
  String businessId = '';
  int businessChatPriority;
  String userId = '';
  String name ='';
  String photoUrl ='';
  String userToken ='';
  String businessName ='';
  String businessChatWith;
  String businessType = '';
  BusinessChatData(
      {this.businessId, this.businessChatPriority,this.userId,this.name,this.photoUrl,this.userToken,this.businessName,this.businessChatWith,this.businessType});

}