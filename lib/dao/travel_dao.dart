import 'dart:async';
import 'dart:convert';


import 'package:flutter_trip/model/travel_model.dart';
import 'package:http/http.dart' as http;

const TRAVEL_URL =
    'https://m.ctrip.com/restapi/soa2/16189/json/searchTripShootListForHomePageV2?_fxpcqlniredt=09031010211161114530&__gw_appid=99999999&__gw_ver=1.0&__gw_from=10650013707&__gw_platform=H5';

var Params = {
  "districtId": -1,
  "groupChannelCode": "RX-OMF",
  "type": null,
  "lat": -180,
  "lon": -180,
  "locatedDistrictId": 0,
  "pagePara": {
    "pageIndex": 1,
    "pageSize": 10,
    "sortType": 9,
    "sortDirection": 0
  },
  "imageCutType": 1,
  "head": {},
  "contentType": "json"
};

///旅拍类别接口
class TravelDao {
  static Future<TravelModel> fetch(
    String url,
    Map params,
    String groupChannelCode,
    int type,
    int pageIndex,
    int pageSize,
  ) async {
    Map paramsMap = params['pagePara'];
    paramsMap['pageIndex'] = pageIndex;
    paramsMap['pageSize'] = pageSize;
    params['groupChannelCode'] = groupChannelCode;
    params['type'] = type;

    var response = await http.post(url, body: jsonEncode(Params));

    if (response.statusCode == 200) {
      Utf8Decoder utf8decoder  = Utf8Decoder(); // fix 中文乱码
      var result = json.decode(utf8decoder.convert(response.bodyBytes));
      return TravelModel.fromJson(result);
    } else {
      throw Exception('Failed to load travel_page.json');
    }
  }
}
