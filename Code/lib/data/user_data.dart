class User {
  final String name ;
  final String email;
  final String RFID_UID;
  final String UID;
  final String ID_number;
  final String gender;

  User(Map data) :
        this.email = data == null || data["Email"] == null ? "" : data["Email"],
        this.name = data == null || data["Name"] == null ? "" : data["Name"],
        this.RFID_UID = data == null || data["RFID UID"].toString() == null ? "" : data["RFID UID"],
        this.UID = data == null || data["UID"].toString() == null ? "" : data["UID"],
        this.ID_number = data == null || data["ID number"].toString() == null ? "" : data["ID number"],
        this.gender = data == null || data["Gender"] == null ? "" : data["Gender"];

}