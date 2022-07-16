import Foundation

public class JoinDao: NSObject {
    
    var closure: (() -> Void)?
    
    public var cell_num:String = ""
    public var passwd:String = ""
    public var birthymd:String = ""
    public var weak_type:String = ""
    public var hc_type:String = ""
    public var er_key:String = ""
    public var b_type:String = ""
    public var g_name:String = ""
    public var gcell_num:String = ""
    public var name: String = ""
    public var f_mobil: String = ""
    
    
    /*
    cell_num    핸드폰번호    int
    passwd      비밀번호    string
    birthymd    생년월일    string
    hc_type     장애형태    int
    er_key      응급정보    char
    b_type      혈액형    int
    g_name      보호자이름    string
    gcell_num   긴급 연락처    string
    name        닉네임   String
    f_mobil     첫번째선호수단   String
    s_mobil     두번째선호수단   String

    */
}
