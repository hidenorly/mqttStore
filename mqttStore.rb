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
require 'thread'

# --- global
$g_criticalSection = Mutex.new
$g_eventFlag = ConditionVariable.new

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
	:outDir => ".",
	:cacheDir => "."
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

	opts.on("-t", "--topics=", Array, "Set subscribing topics a,b,c") do |topics|
		options[:topics] = topics
	end

	opts.on("-o", "--outDir=", "Set persist file output directory (default:#{options[:outDir]}) ") do |outDir|
		options[:outDir] = outDir
	end

	opts.on("-c", "--cacheDir=", "Set cache file output directory (default:#{options[:cacheDir]}) ") do |cacheDir|
		options[:cacheDir] = cacheDir
	end

	opts.on("", "--client_id=", "Set client ID (default:#{options[:client_id]}") do |client_id|
		options[:client_id] = client_id
	end
end.parse!

$g_options = convOptions(options)

client = connectMqtt()
client.subscribe(options[:topics])

a = Thread.new {
	aMes = {:topic=>"", :message=>""}
	while( isConnected() ) do
		$g_criticalSection.synchronize{
			$g_eventFlag.wait($g_criticalSection)
			aMes = $g_result.pop() if $g_result.size>0
		}
		puts "A THREAD:#{aMes[:topic]}: #{aMes[:message]}"
	end
}

while( isConnected() ) do
	client.get() do |topic, message|
		$g_criticalSection.synchronize{
			$g_result.push({:topic=>topic, :message=>message})
		}
		$g_eventFlag.broadcast()
	end
end

$g_eventFlag.broadcast()
a.join()
