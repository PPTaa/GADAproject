//
//  BaseConst.swift
//  GADAproject
//
//  Created by leejungchul on 2022/06/22.
//

import Foundation
import Alamofire

struct BaseConst {
    
    /**
     - note: Global
     */
    public static let APP_SERVICE_CODE = "S00001"
    public static let APP_OS_CODE = "ios"
    public static let APP_AUTH = "y1aok44g7s4w8mith9fzon9wbinby378es5txymo"
    
    // #
    public static let MAP_API_KEY = "l7xx98d2ab7920cb4d80ae85d92e7772a4b5"
    public static let ODSAY_API_KEY = "QZAAy+xFjr6Z3q9oIWbBFw"
    public static let BUS_API_KEY = "iAh8MOA2pXvhPDWVyA0RQN9VTqsGEclC+SnVsB9dKrrew0sbfHf2ED50PR/7BacLTvyweIs++bH/cFqHJbKpZw=="
    
    /**
     - note: 설정
     */
    public static let SPC_PUSH_TOKEN = "SPC_PUSH_TOKEN"                 // 푸시토큰
    
    public static let SPC_USER_ID = "SPC_USER_ID"                       // 유저 아이디
    public static let SPC_USER_PWD = "SPC_USER_PWD"                     // 유저 패스워드
    public static let SPC_USER_LOGIN = "SPC_USER_LOGIN"                 // 자동로그인 여부
    public static let SPC_USER_TOKEN = "SPC_USER_TOKEN"                 // 로그인 토큰
    public static let SPC_USER_NAME = "SPC_USER_NAME"                   // 유저 이름
    public static let SPC_USER_PHONE = "SPC_USER_PHONE"                 // 유저 휴대폰번호
    public static let SPC_USER_BIRTHDAY = "SPC_USER_BIRTHDAY"           // 유저 생년월일
    public static let SPC_USER_IMAGE = "SPC_USER_IMAGE"                 // 유저 이미지
    public static let SPC_USER_NICKNAME = "SPC_USER_NICKNAME"           // 유저 닉네임
    public static let SPC_DATA_ADDRESS = "SPC_DATA_ADDRESS"             // 최근 목적지 저장
    
    
    /**0
     - note: 네트워크
     */
    
    public static let SERVICE_SERVER_HOST:String = "http://52.79.47.107:8080"
    public static let DEV_SERVER_HOST:String = "http://52.79.47.107:8080"
    
    public static let NET_MEMBER_REGISTER:String = "/TrafficPathTraced/register" // 회원 가입
    public static let NET_MEMBER_LOGIN:String = "/TrafficPathTraced/login"       // 회원 로그인
    public static let NET_MEMBER_CHECK:String = "/TrafficPathTraced/num_check"   // 휴대폰번호 중복 확인
    public static let NET_MEMBER_UPDATE:String = "/TrafficPathTraced/member"     // 회원 정보 수정
    public static let NET_MEMBER_FINDPWD:String = "/TrafficPathTraced/findpwd"   // 회원 비밀번호 찾기
    public static let NET_MEMBER_UPDATEPWD:String = "/TrafficPathTraced/updatePwd"   // 회원 비밀번호 수정
    public static let NET_MEMBER_QUIT:String = "/TrafficPathTraced/quit"         // 회원 탈퇴
    public static let NET_MEMBER_INFO:String = "/TrafficPathTraced/memberInfo"   // 회원 정보 확인
    public static let NET_APP_VERSION:String = "/TrafficPathTraced/version"      // 앱 버전
    public static let NET_MEMBER_NICKNAME_CHECK: String = "/TrafficPathTraced/nickname_check" // 닉네임 중복확인
    public static let NET_MEMBER_NICKNAME_UPDATE: String = "/TrafficPathTraced_dev/nickname_update" // 닉네임 수정

    public static let NET_REVIEW_REGISTER: String = "/TrafficPathTraced/register_review" // 리뷰 등록
    public static let NET_REVIEW_READ: String = "/TrafficPathTraced/read_review" // 리뷰 읽기
    public static let NET_REVIEW_DELETE: String = "/TrafficPathTraced/delete_review" // 리뷰 삭제
    public static let NET_REVIEW_UPDATE: String = "/TrafficPathTraced/update_review" // 리뷰
    
    public static let NET_STATION_PHONE: String = "/TrafficPathTraced/station_phone" // station phone
    public static let NET_STATION_SEARCH: String = "/TrafficPathTraced/searchSubwayName" // station 검색
    public static let NET_STATION_LANE_SEARCH: String = "/TrafficPathTraced/searchSubwayLane" // station 노선 검색
    
    public static let NET_FAVORITE_REGISTER: String = "/TrafficPathTraced/create_fl" // 즐겨찾기 등록
    public static let NET_FAVORITE_READ: String = "/TrafficPathTraced/read_fl" // 즐겨찾기 읽기
    public static let NET_FAVORITE_DELETE: String = "/TrafficPathTraced/delete_fl" // 즐겨찾기 삭제
    public static let NET_FAVORITE_UPDATE: String = "/TrafficPathTraced/update_fl" // 즐겨찾기 수정
    public static let NET_FAVORITE_SAVE: String = "/TrafficPathTraced/save_fl" // 즐겨찾기 저장
    
    public static let NET_ODDATA_SAVE: String = "/TrafficPathTraced/collectoddata" // od 데이터 저장
    public static let NET_PATHDATA_SAVE: String = "/TrafficPathTraced/pathdata" // od의 세부 경로 데이터 저장
    public static let NET_TRANSFERDATA_SAVE: String = "/TrafficPathTraced/transferdata" // od의 세부 환승 데이터 저장
    
    public static let NET_TAXI_LIST: String = "/gada_api-0.0.1/taxi_list_by_division" // 구분 지역으로 콜택시 찾기
    
    // 서비스 이용약관
    public static let NET_TERMS_1:String = "https://jaewoo.kim/handycab/terms/"
    
    // 개인정보처리방침
    public static let NET_TERMS_2:String = "https://sites.google.com/view/handycabterm2"
        
    // 위치기반 서비스 이용약관
    public static let NET_TERMS_3:String = "https://sites.google.com/view/handycabterm3"

    // 법정공지 및 정보제공처
    public static let NET_TERMS_4:String = "https://sites.google.com/view/handycabterm4"
    
    public static let headers: HTTPHeaders = [
        "Content-Type": "application/json",
        "Accept-Charset": "charset=UTF-8",
        "Authorization": "Bearer "
    ]
    
}
