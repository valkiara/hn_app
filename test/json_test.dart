import 'package:flutter_test/flutter_test.dart';
import 'package:hn_app/src/article.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Parses topstores.json', () {
    const jsonString =
        '[23281634,23279160,23282209,23282784,23281994,23281564,23270334,23281568,23282754,23280378,23269661,23282207,23282607,23270269,23279837,23274668,23280947,23269697,23271298,23281542,23273247,23278754,23282278,23275053,23279731,23281902,23277594,23281601,23271029,23282023,23276456,23270052,23282716,23279299,23270133,23276259,23271572,23282035,23282661,23272992,23281870,23280674,23270232,23277081,23270985,23282555,23277960,23277706,23273452,23280277,23276786,23271281,23279327,23271053,23271009,23271624,23276261,23270193,23266917,23275080,23278106,23281024,23265518,23282495,23280070,23274540,23270581,23275308,23278536,23277109,23270207,23281668,23279015,23263382,23265000,23280734,23275315,23276789,23265752,23280504,23271178,23281926,23269636,23268911,23258301,23273758,23280372,23274094,23277609,23272442,23271084,23246170,23256458,23271973,23271604,23274032,23268388,23278806,23257303,23269660,23267177,23273177,23270429,23277161,23269351,23271649,23269562,23278157,23273543,23270970,23268191,23258546,23271732,23272054,23250831,23269405,23254871,23268420,23246221,23268636,23267937,23246672,23255732,23279399,23263752,23271872,23276513,23272950,23251754,23260846,23269460,23267827,23256782,23269396,23270100,23278895,23263918,23265208,23257912,23277950,23249572,23268307,23256901,23268888,23277699,23277935,23281954,23279908,23278405,23254587,23278958,23276521,23278310,23278387,23271096,23257543,23254045,23275707,23243580,23258870,23275602,23257195,23251129,23282122,23256661,23279614,23279708,23262514,23257870,23254861,23249628,23279478,23264850,23276702,23261464,23250379,23255642,23279050,23267834,23243646,23253067,23259612,23276511,23269670,23275204,23251319,23276393,23273574,23241934,23252859,23278372,23243248,23252448,23266674,23252631,23247196,23249964,23276303,23262873,23253841,23260877,23259695,23270075,23257526,23266918,23261029,23280610,23260056,23250885,23254283,23273097,23244778,23267206,23257495,23256050,23257602,23268521,23274460,23244812,23268279,23254497,23261815,23254432,23266209,23257102,23259427,23276370,23269835,23280190,23256589,23243299,23276117,23277574,23261394,23248010,23244641,23275293,23250289,23258858,23269887,23258111,23257075,23273288,23259159,23248980,23262615,23250234,23255812,23250700,23250513,23261574,23243330,23276417,23250051,23244891,23254301,23244709,23242557,23245552,23262962,23249748,23263256,23271154,23245724,23261657,23242699,23249457,23257790,23261198,23269333,23257645,23258425,23243204,23257843,23277340,23271912,23253338,23277282,23244703,23248779,23253056,23268671,23275393,23242518,23253282,23251742,23279909,23243420,23263808,23257145,23253160,23262763,23242881,23259119,23275082,23278312,23276055,23249824,23245125,23272991,23277536,23244695,23276357,23243728,23250314,23242290,23277077,23242296,23250767,23244864,23273203,23252152,23242679,23269610,23278421,23260557,23257856,23267285,23275734,23268581,23268030,23252924,23277260,23242549,23256784,23243693,23255863,23255853,23249520,23275362,23256469,23251035,23245135,23247228,23267559,23247304,23245431,23267949,23277341,23248256,23278766,23259539,23269192,23275503,23270805,23242281,23272635,23253334,23258823,23278508,23246734,23257280,23270541,23261025,23253977,23254397,23247310,23266845,23275775,23275665,23255591,23272602,23255963,23269658,23258643,23265489,23261007,23267992,23265547,23275280,23251743,23251865,23264252,23258277,23258497,23250849,23264521,23258169,23250383,23262523,23251154,23271227,23273939,23257370,23249171,23257135,23249949,23256907,23269754,23247648,23267449,23266030,23252595,23256298,23252421,23274519,23262532,23269194,23242828,23272143,23250840,23275952,23245571,23268849,23243338,23255283,23253955,23266349,23269386,23265111,23272222,23269138,23264068,23258619,23242822,23271179,23254320,23242901,23271769,23242813,23273340,23242787,23261137,23254879,23242594,23267336,23251211,23256426,23277942,23251660,23241480,23263934,23253605,23257105,23250370,23253230,23266171,23246908,23271109,23266583,23269861,23260100,23277116,23272811,23269110,23242439,23269014,23256028,23248103,23249172,23278836,23242254,23263676,23278908,23253232,23248830,23259827,23265693,23252112,23245117,23253854,23253816,23244613,23275049,23268263,23257658,23257636,23274724,23257253,23251909,23245916,23258186,23273374,23261246,23271108,23250291,23244823,23273786,23251158,23251594,23255838,23251399,23253824,23252809,23265803,23250066,23265626,23265290,23252555,23262785,23257446,23257411,23242879,23254906,23251065,23260928,23248167,23251831,23261594,23247130]';

    expect(parseTopStores(jsonString).first, 23281634);
  });

  test('Parses item.json', () {
    const jsonString =
        '{"by":"dhouston","descendants":71,"id":8863,"kids":[9224,8917,8952,8884,8887,8869,8958,8940,8908,9005,8873,9671,9067,9055,8865,8881,8872,8955,10403,8903,8928,9125,8998,8901,8902,8907,8894,8870,8878,8980,8934,8943,8876],"score":104,"time":1175714200,"title":"My YC app: Dropbox - Throw away your USB drive","type":"story","url":"http://www.getdropbox.com/u/2/screencast.html"}';

    expect(parseArticle(jsonString).by, 'dhouston');
  });

  test('Parses item.json over network', () async {
    final url = 'https://hacker-news.firebaseio.com/v0/item/121003.json';

    final res = await http.get(url);
    if (res.statusCode == 200) {
      expect(parseArticle(res.body).id, 121003);
    }
  });
}
