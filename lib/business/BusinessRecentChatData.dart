class BusinessRecentChatData {
  String createDate;
  String employeeId;
  bool isCreated;
  String storeId;
  String userId;
  String employeeName;
  String userName;
  String employeePhotoUrl;
  String employeeStatus;
  BusinessRecentChatData(
      {this.createDate, this.employeeId, this.isCreated, this.storeId,this.userId,this.employeeName,this.userName,this.employeePhotoUrl,this.employeeStatus});

  String getEmployeeUniqueChat(){
    return employeeId+userId;
  }

}