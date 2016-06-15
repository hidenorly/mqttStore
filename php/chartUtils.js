function dataReduction(data, maxNum)
{
	if( data[0].length < maxNum ){
		return data;
	} else {
		var result = []
		for(var j=0, c=data.length; j<c; j++){
			var vals = []
			for(var i=0, num=data[j].length, step=num/maxNum; i<num; i=i+step){
				vals.push( data[j][Math.round(i)] )
			}
			result.push(vals);
		}
		return result;
	}
}


function setupChart(chartData, data, onCompletion)
{
	chartData["data"]=dataReduction(data, 30);
	if( onCompletion instanceof Function ) onCompletion();
}
