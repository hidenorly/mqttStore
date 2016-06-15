 ccchart.base('', 
    {config : {
        "type" : "line", //チャート種類
        "bg" : "#fff", //背景色
  }});

var humidityChart = {
    "config": {
          // title
        "title": "Humidity/Temperature Recent trend",
        "titleY": 30, //タイトルのtop位置
        "subTitle": "",
        "titleFont": "bold 24px meiryo", //タイトルフォント (太さ サイズ 種類)     
        "textColor" : "#000", //テキスト色

        // graph option
        "type": "line", //チャート種類（ラインチャート）
        "lineWidth" : "3", //ラインの太さ
        "onlyChart": "no", //チャートのみを表示
//        "useVal" : "yes", //値を表示
        "useShadow" : "no", //影

        // chart
        "width": 1200, //チャート(canvas)幅
        "height": 800, //チャート(canvas)高さ

//        "paddingTop": 80, //チャートの上パディング
        "paddingBottom": 160, //チャートの下パディング
//        "paddingLeft": 40, //チャートの左パディング
        "paddingRight": 300, //チャートの右パディング

        "bg": "#fff", //背景色
/*
        "bgGradient": { //背景色グラデーション
            "direction": "vertical", //上から下へ ("horizonal"で左から右へ)
            "from": " #606c88", //開始色
            "to": "#3f4c6b " //終了色
        },
*/
        // marker
        "useMarker": "css-ring",
        "markerWidth": 12,
        "borderWidth": 3, //マーカーの線太さ

        // grid
        "maxY": 100, //Yデータの最大値
        "minY": 0, //Yデータの最小値
        "xColor": "#666", //水平目盛り線の色
        "yColor": "#666", //垂直目盛り線の色
        "xScaleFont" : "100 16px 'meiryo'", //水平軸目盛フォント
        "yScaleFont" : "100 16px 'meiryo'", //垂直軸目盛フォント
        "xScaleColor": "#000", //水平軸目盛値色
        "yScaleColor": "#000", //垂直軸目盛値色
        "xScaleXOffset": "1", //水平軸目盛Xオフセット
        "xScaleRotate": -90, //水平軸目盛角度

        // grid
        "xLines": [{ //水平線
            "val": 0, //水平線の位置
            "color": "#000", //水平線色
            "width": 3 //水平線の太さ
        }],

        // data config
//      "colorSet": ["#ff0000", "#0000FF", "#00FF00"], //データ列の色
        "colorSet": ["#ff7f7f", "#ff7fbf", "#ff7fff", "#bf7fff",
                     "#7f7fff", "#7fbfff", "#7fffff", "#7fffbf",
                     "#7fff7f", "#bfff7f", "#ffff7f", "#ffbf7f"],

        "hanreiColor": "#000", //凡例色
        "hanreiFont" : "bold 16px 'meiryo'", //凡例フォント (太さ(指定なしで標準) サイズ 種類)
        "valFont" : "bold 16px 'meiryo'", //値フォント
    },

/*
    "data": [ //データ設定
        ["日付", "8月20日", "8月21日", "8月22日", "8月23日", "8月24日", "8月25日", "8月26日"], //X軸データ設定 （一番左が項目）
        ["データ1", -12, -34, -65, 36, 87, 35, 75], //Y軸データ設定 （一番左が項目）
        ["データ2", -43, -75, -26, 85, 36, 86, 14] //Y軸データ設定 （一番左が項目）
    ]
*/
};
//ccchart.init('humidityChart', humidityChart);
