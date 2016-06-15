#!/usr/bin/env ruby
 
# Copyright 2016 hidenorly
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'optparse'
require 'rubygems'
require 'mqtt'

# --- utility for mqtt
$g_mqttClient = nil
$g_options = {}
$g_result = []

def convOptions(options)
	result = {
		:host => options[:host],
		:port => options[:port]
	}
	result[:username] = options[:username] if options[:username]
	result[:password] = options[:password] if options[:password]
	result[:ssl] = options[:ssl] if options[:ssl]
	result[:client_id] = options[:client_id] if options[:client_id]

	return result
end

def connectMqtt
	if $g_mqttClient == nil then
		$g_mqttClient = MQTT::Client.connect($g_options)
	end
	return $g_mqttClient
end

def isConnected
	if $g_mqttClient == nil then
		connectMqtt()
	end
	return $g_mqttClient.connected?
end



#---- main --------------------------
options = {
	:host => "localhost",
	:port => "1883",
	:ssl => false,
	:username => nil,
	:password => nil,
	:client_id => nil,
	:topics => [],
	:repeatCycle => 0,
}

opt_parser = OptionParser.new do |opts|
	opts.banner = "Usage: usage (options)"

	opts.on("-h", "--host=", "set mqtt host (default:#{options[:host]})") do |host|
		options[:host] = host
	end

	opts.on("-p", "--port=", "set mqtt port (default:#{options[:port]})") do |port|
		options[:port] = port
	end

	opts.on("-s", "--ssl", "Enable SSL connection (default:#{options[:ssl]})") do |ssl|
		options[:ssl] = true
	end

	opts.on("-u", "--user=", "set username for the host") do |username|
		options[:username] = username
	end

	opts.on("-p", "--password=", "set password for the host") do |password|
		options[:password] = password
	end

	opts.on("-t", "--topics=", Array, "Set publishing topics/value a=hoge,b=hoge,c=hoge") do |topics|
		options[:topics] = topics
	end

	opts.on("", "--client_id=", "Set client ID (default:#{options[:client_id]})") do |client_id|
		options[:client_id] = client_id
	end

	opts.on("-r", "--repeatCycle=", "Set repeatCycle [Sec] (0:oneshot) (default:#{options[:repeatCycle]})") do |repeatCycle|
		options[:repeatCycle] = repeatCycle.to_i
	end
end.parse!

$g_options = convOptions(options)

client = connectMqtt()
client.subscribe(options[:topics])

$g_repeatCycle = options[:repeatCycle]

publishingData = []
options[:topics].each do |aTopic|
	aTopic = aTopic
	pos = aTopic.index("=")
	if nil!=pos then
		publishingData << {:topic=>aTopic.slice(0, pos).strip, :value=>aTopic.slice(pos+1).strip}
	end
end


while( isConnected() ) do
	publishingData.each do |aData|
		puts "#{aData[:topic]}:#{aData[:value]}"
		client.publish(aData[:topic], aData[:value], false, 0)
	end
	if 0==$g_repeatCycle then
		break
	else
		sleep($g_repeatCycle)
	end
end
