function dataReduction(data, maxNum)
{
	var result = []
	for(var j=0, c=data.length; j<c; j++){
		var vals = []
		for(var i=0, num=data[j].length, step=Math.round(num/maxNum); i<num; i=i+step){
			vals.push( data[j][i] )
		}
		result.push(vals);
	}
	return result;
}


function setupChart(chartData, data, onCompletion)
{
	chartData["data"]=dataReduction(data, 30);
	if( onCompletion instanceof Function ) onCompletion();
}
