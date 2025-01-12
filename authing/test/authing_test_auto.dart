import 'package:authing_sdk_odds/authing.dart';
import 'package:authing_sdk_odds/client.dart';
import 'package:authing_sdk_odds/oidc/auth_request.dart';
import 'package:authing_sdk_odds/oidc/oidc_client.dart';
import 'package:authing_sdk_odds/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// can run all case serially in one go

void main() async {
  // on mac, when running test, it will crash without this line
  SharedPreferences.setMockInitialValues({});

  String pool = "60caaf41da89f1954875cee1";
  String appid = "60caaf41df670b771fd08937";
  await Authing.init(pool, appid);

  test('register by email', () async {
    AuthResult result = await AuthClient.registerByEmail("1@1.com", "111111");
    expect(result.code, 200);
    expect(result.user?.email, "1@1.com");
    expect(result.user?.token != null, true);

    AuthResult result2 = await AuthClient.loginByAccount("1@1.com", "111111");
    expect(result2.code, 200);
    expect(result2.user?.email, "1@1.com");

    AuthResult result3 = await AuthClient.registerByEmail("1@1.com", "111111");
    expect(result3.code, 2026);

    AuthResult result4 = await AuthClient.registerByEmail("1", "111111");
    expect(result4.code, 2003);

    Result result5 = await AuthClient.deleteAccount();
    expect(result5.code, 200);

    AuthResult result6 = await AuthClient.loginByAccount("1@1.com", "111111");
    expect(result6.code, 2333);
  });

  test('register by username', () async {
    AuthResult result =
        await AuthClient.registerByUserName("test1024", "111111");
    expect(result.code, 200);
    expect(result.user?.username, "test1024");
    expect(result.user?.token != null, true);

    AuthResult result2 = await AuthClient.loginByAccount("test1024", "111111");
    expect(result2.code, 200);
    expect(result2.user?.username, "test1024");

    AuthResult result3 =
        await AuthClient.registerByUserName("test1024", "111111");
    expect(result3.code, 2026);

    Result result5 = await AuthClient.deleteAccount();
    expect(result5.code, 200);

    AuthResult result6 = await AuthClient.loginByAccount("1@1.com", "111111");
    expect(result6.code, 2333);
  });

  test('login by account', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user?.username, "ci");

    AuthResult result2 = await AuthClient.loginByAccount("ci", "111111xx");
    expect(result2.code, 2333);
  });

  test('get current user', () async {
    await AuthClient.logout();

    AuthResult result0 = await AuthClient.getCurrentUser();
    expect(result0.code, 2020);

    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user?.username, "ci");

    AuthResult result2 = await AuthClient.getCurrentUser();
    expect(result2.code, 200);
    expect(result2.user?.username, "ci");
  });

  test('logout', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user?.username, "ci");

    AuthResult result2 = await AuthClient.logout();
    expect(result2.code, 200);
    expect(AuthClient.currentUser, null);

    AuthResult result3 = await AuthClient.getCurrentUser();
    expect(result3.code, 2020);
  });

  test('getCustomData', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user?.username, "ci");

    AuthResult result2 =
        await AuthClient.getCustomData(AuthClient.currentUser!.id);
    expect(result2.code, 200);
    expect(AuthClient.currentUser?.customData[0]["key"], "org");
    expect(AuthClient.currentUser?.customData[0]["value"], "unit_test");
  });

  test('setCustomData', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user?.username, "ci");

    AuthResult result2 = await AuthClient.getCustomData(result.user!.id);
    expect(result2.code, 200);
    expect(AuthClient.currentUser?.customData[0]["key"], "org");
    expect(AuthClient.currentUser?.customData[0]["value"], "unit_test");

    AuthClient.currentUser?.customData[0]["value"] = "hello";
    AuthResult result3 =
        await AuthClient.setCustomData(AuthClient.currentUser!.customData);
    expect(result3.code, 200);
    expect(AuthClient.currentUser?.customData[0]["value"], "hello");

    AuthClient.currentUser?.customData[0]["value"] = "unit_test";
    await AuthClient.setCustomData(AuthClient.currentUser!.customData);
  });

  test('updateProfile', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user?.username, "ci");

    AuthResult result2 =
        await AuthClient.updateProfile({"username": "hey", "nickname": "musk"});
    expect(result2.code, 200);
    expect(result2.user?.username, "hey");
    expect(result2.user?.nickname, "musk");

    AuthResult result3 = await AuthClient.updateProfile({"username": "ci"});
    expect(result3.code, 200);
    expect(result3.user?.username, "ci");
  });

  test('updatePassword', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user?.username, "ci");

    AuthResult result1 = await AuthClient.updatePassword("222222", "123456");
    expect(result1.code, 1320011);

    AuthResult result2 = await AuthClient.updatePassword("222222", "111111");
    expect(result2.code, 200);

    AuthResult result3 = await AuthClient.loginByAccount("ci", "222222");
    expect(result3.code, 200);

    AuthResult result4 = await AuthClient.updatePassword("111111", "222222");
    expect(result4.code, 200);
  });

  test('getSecurityLevel', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user?.username, "ci");

    Result result1 = await AuthClient.getSecurityLevel();
    expect(result1.code, 200);
    expect(result1.data["score"], 70);
    expect(result1.data["passwordSecurityLevel"], 1);
  });

  test('listApplications', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user?.username, "ci");

    Result result1 = await AuthClient.listApplications();
    expect(result1.code, 200);
    expect(result1.data["totalCount"], 6);
  });

  test('listRoles', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user?.username, "ci");

    Result result1 = await AuthClient.listRoles();
    List list = result1.data["data"];
    expect(list.length, 2);
    expect(list[0]["code"], "admin");
    expect(list[1]["code"], "manager");

    result1 = await AuthClient.listRoles("60caaf414f9323f25f64b2f4");
    list = result1.data["data"];
    expect(list.length, 2);
    expect(list[0]["code"], "admin");
  });

  test('listAuthorizedResources', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user?.username, "ci");

    Map result1 = await AuthClient.listAuthorizedResources("default");
    expect(result1["totalCount"], 2);
    expect(result1["list"][0]["code"], "ci:*");
    expect(result1["list"][0]["type"], "DATA");
    expect(result1["list"][1]["code"], "super:*");
    expect(result1["list"][1]["type"], "API");

    result1 = await AuthClient.listAuthorizedResources("default", "DATA");
    expect(result1["totalCount"], 1);
    expect(result1["list"][0]["code"], "ci:*");
    expect(result1["list"][0]["type"], "DATA");

    AuthResult result2 = await AuthClient.loginByAccount("cinophone", "111111");
    expect(result2.code, 200);

    Map result3 = await AuthClient.listAuthorizedResources("default");
    expect(result3["totalCount"], 0);
  });

  test('computePasswordSecurityLevel', () async {
    int r = AuthClient.computePasswordSecurityLevel("123");
    expect(r, 0);

    r = AuthClient.computePasswordSecurityLevel("1234Abcd");
    expect(r, 1);

    r = AuthClient.computePasswordSecurityLevel("1234@Abcd");
    expect(r, 2);
  });

  test('listOrgs', () async {
    AuthResult result1 = await AuthClient.loginByAccount("ci", "111111");
    expect(result1.code, 200);
    expect(result1.user?.username, "ci");

    Result result = await AuthClient.listOrgs();
    expect(result.code, 200);
    List list = result.data["data"];
    expect(list.length, 2);
    expect(list[0][3]["name"], "JavaDevHR");
  });

  test('updateIdToken', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);

    result = await AuthClient.updateIdToken();
    expect(result.code, 200);

    AuthClient.currentUser = null;

    result = await AuthClient.updateIdToken();
    expect(result.code, 200);
  });

  test('mfaCheck', () async {
    Authing.init(pool, "61c173ada0e3aec651b1a1d1");

    AuthResult result1 = await AuthClient.loginByAccount("ci", "111111");
    expect(result1.code, 1636);

    bool r = await AuthClient.mfaCheck("13012345678", null);
    expect(r, true);

    r = await AuthClient.mfaCheck("abc@gmail.com", null);
    expect(r, true);
  });

  test('oidcLoginByAccount', () async {
    await Authing.init("60caaf41da89f1954875cee1", "60caaf41df670b771fd08937");

    var res = await OIDCClient.loginByAccount("test", "111111");

    expect(res.code, 200);
    expect(res.user?.accessToken != null, true);
    expect(res.user?.refreshToken != null, true);
  });

  test('oidcLoginByPhoneCode', () async {
    String phone = "+86xxx";

    await Authing.init("60caaf41da89f1954875cee1", "60caaf41df670b771fd08937");

    var res = await OIDCClient.loginByPhoneCode(phone, "1234");
    expect(res.code, 200);
    expect(res.user?.accessToken != null, true);
    expect(res.user?.refreshToken != null, true);
  });

  test('buildAuthorizeUrl', () async {
    var authRequest = AuthRequest();
    authRequest.scope = "";
    authRequest.createAuthRequest();
    var res = await OIDCClient.buildAuthorizeUrl(authRequest);
    expect(res.isNotEmpty, true);
  });

  test('getNewAccessTokenByRefreshToken', () async {
    await Authing.init("60caaf41da89f1954875cee1", "60caaf41df670b771fd08937");

    var result2 =
        await OIDCClient.getNewAccessTokenByRefreshToken("refreshToken");
    expect(result2.code, 200);
    expect(result2.user?.accessToken != null, true);
  });

  test('getUserInfoByAccessToken', () async {
    await Authing.init("60caaf41da89f1954875cee1", "60caaf41df670b771fd08937");

    var result2 = await OIDCClient.getUserInfoByAccessToken("accessToken");
    expect(result2.code, 200);
  });
}
