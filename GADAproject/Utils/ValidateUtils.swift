import Foundation


class ValidateUtils {
    
    private static var sharedValidateUtils: ValidateUtils = {
        
        let obj = ValidateUtils(/*parameta*/)
        // Configuration
        
        return obj
    }()
    
    private init(/*parameta*/) {
    }
    
    class func shared() -> ValidateUtils {
        return sharedValidateUtils
    }
    
    
    enum GrammarCheckerError: Error {
        case invalidRegexPattern
        case matchNoPattern
    }
    
    
    /**
     - note: Regular Expression 체크
     - parameters:
        - pattern: Regular Expression
        - input: 문자열
     */
    func match(for pattern: String, input: String) throws -> Bool {
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            throw GrammarCheckerError.invalidRegexPattern
        }
        
        let range = NSRange(input.startIndex...,  in: input)
        let matches = regex.matches(in: input, options: [], range: range)
        let matchedString = matches.map { match -> String in
            let range = Range(match.range, in: input)!
            return String(input[range])
        }
        return matchedString.count == 1 && matchedString[0] == input
    }
    
    func checkEmail(str: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return  NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: str)
    }
    
    // 이름 유효성 체크 (한글 2~10)
    func checkName(str: String) -> Bool {

        let regex:String = "^[가-힣]{2,10}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: str)
    }
    
    // ID 유효성 체크 (영문 4~10)
    func checkId(str: String) -> Bool {
        
        let regex:String = "^[a-z0-9]{4,10}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: str)
    }
    
    // 비밀번호 유효성 체크
    func checkPassword(str:String) -> Bool {
        
        let regex:String = "(?=.*[0-9])(?=.*[a-z]).{6,20}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: str)
    }
    
    // 휴대폰 유효성 체크
    func checkPhone(str:String) -> Bool {
        
        let regex:String = "^\\s*(010|011|012|013|014|015|016|017|018|019)(-|\\)|\\s)*(\\d{3,4})(-|\\s)*(\\d{4})\\s*$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: str)
    }
}
