<!DOCTYPE html>
<html lang="ja">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta charset="utf-8" />
<title>mqtt Dashboard</title>
<link rel="stylesheet" href="mqtt-chart.css">
</head>
<body onLoad="onBodyLoad()">
<div id="background">
	<div id="container">
	  <canvas id="humidityChart"></canvas>
	</div>
	<script type="text/javascript" language="javascript" src="ccchart.js"></script>
	<script type="text/javascript" language="javascript" src="chartConfig.js"></script>
	<script type="text/javascript" language="javascript" src="chartUtils.js"></script>
</div>
<script>
	var humidityData = <?php
$humidity_json = file_get_contents(__DIR__ . '/data/cache-hidenorly-sensor-humidity.json');
if ($humidity_json === false) {
	echo "humidity is unable to load";
    throw new \RuntimeException('file not found.');
}
echo $humidity_json;
?>;

	var temperatureData = <?php
$temperature_json = file_get_contents(__DIR__ . '/data/cache-hidenorly-sensor-temperature.json');
if ($temperature_json === false) {
	echo "temperature is unable to load";
    throw new \RuntimeException('file not found.');
}
echo $temperature_json;
?>;

function doShowGraph()
{
	var combinedData = humidityData;
	combinedData.push( temperatureData[1] );

	setupChart(humidityChart, combinedData, function(){
		ccchart.init('humidityChart', humidityChart);
	});
}

function onBodyLoad()
{
	window.setTimeout( function(){
		doShowGraph();
	}, 200 );
}
</script>
</body>
</html>
