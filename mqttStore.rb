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

# --- utility
def getOldIndex(data, targetTime)
	found = false
	i = 0
	n = data.length
	while ( i < n ) do
		if data[i][:time] < targetTime then
			i=i+1
			found = true
		else
			if found then
				return i-1
			end
			return -1
		end
	end
	return -1
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
	:cacheDir => ".",
	:updateCycle => 5,
	:windowPeriod => 3600
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

	opts.on("-u", "--updateCycle=", "Set updateCycle [Sec] (default:#{options[:updateCycle]}") do |updateCycle|
		options[:updateCycle] = updateCycle.to_i
	end

	opts.on("-w", "--windowPeriod=", "Set windowPeriod [Sec] (default:#{options[:windowPeriod]}") do |windowPeriod|
		options[:windowPeriod] = windowPeriod.to_i
	end
end.parse!

$g_options = convOptions(options)

client = connectMqtt()
client.subscribe(options[:topics])

$g_updateCycle = options[:updateCycle]
$g_windowPeriod = options[:windowPeriod]

a = Thread.new {
	topicDataStore = {}
	lastTime = Time.now
	while( isConnected() ) do
		# to minimize blocking time on main thread
		data = []
		$g_criticalSection.synchronize{
			$g_eventFlag.wait($g_criticalSection)
			while( $g_result.size>0 ) do
				data << $g_result.pop()
			end
		}
		# store received data to sorted topic data
		data.each do |aMes|
#			puts "A THREAD:#{aMes[:time]} : #{aMes[:topic]} : #{aMes[:message]}"
			topicDataStore[ aMes[:topic] ] = Array.new if !topicDataStore.has_key?(aMes[:topic])
			last = topicDataStore[ aMes[:topic] ].last
			if last==nil || last[:time]<aMes[:time] then
				topicDataStore[ aMes[:topic] ].push( { :time=>aMes[:time], :value=>aMes[:message] } )
			end
		end
		# update data
		now = Time.now
		if (now-lastTime)>$g_updateCycle then
			lastTime = now
			targetTime = now - $g_windowPeriod
#			puts "updated #{lastTime} / #{targetTime}"
			topicDataStore.each do |topic, data|
				# trim data within window period
				index = getOldIndex(data, targetTime)
				if index!=-1 then
					# TODO : write data to file as append
					data.slice!(0,index)
				end
				puts data # output this trimed data to cache file
			end
		end
	end
}

while( isConnected() ) do
	client.get() do |topic, message|
		$g_criticalSection.synchronize{
			$g_result.push({:time=>Time.now, :topic=>topic, :message=>message})
		}
		$g_eventFlag.signal() #broadcast()
	end
end

$g_eventFlag.broadcast()
a.join()
