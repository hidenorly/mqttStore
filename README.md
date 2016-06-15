# mqttStore

## Dependecies

```
# gem install mqtt
```

## How to use

```
$ ./mqttStore.rb --help
Usage: usage (options)
    -h, --host=                      set mqtt host (default:localhost)
        --port=                      set mqtt port (default:1883)
    -s, --ssl                        Enable SSL connection (default:false)
        --user=                      set username for the host
    -p, --password=                  set password for the host
    -t, --topics=                    Set subscribing topics a,b,c
    -o, --outDir=                    Set persist file output directory (default:) 
    -c, --cacheDir=                  Set cache file output directory (default:.) 
        --client_id=
                                     Set client ID (default:)
    -u, --updateCycle=               Set updateCycle [Sec] (default:5)
    -w, --windowPeriod=              Set windowPeriod [Sec] (default:3600)
    -f, --format=                    Set output cache format json,csv(default:json)
```

### typical usage

```
$ ./mqttStore.rb -t /hidenorly/sensor/# -h 192.168.10.1 -u 5 -w 3600 -o .
```

The above means
* the MQTT host is 192.168.10.1
* subscribing all of node staring with "/hidenorly/sensor/"
* file update cycle is every 5 second
* the cache file's window period is 3600 sec (1 hour)
* enabling perist log under current folder. (```-o``` is needed)

Please note that
* The cache filename is cache_¥[topic¥].json (you can specify -f csv)
* The persist log filename is persist_¥[topic¥].csv and it is enabled if you specify -o


# mqtt_publisher.rb

This is sample implementation to publish something to MQTT server.
You can use this to test mqttStore.rb

```
$ ./mqtt_publisher.rb --help
Usage: usage (options)
    -h, --host=                      set mqtt host (default:localhost)
        --port=                      set mqtt port (default:1883)
    -s, --ssl                        Enable SSL connection (default:false)
    -u, --user=                      set username for the host
    -p, --password=                  set password for the host
    -t, --topics=                    Set publishing topics/value a=hoge,b=hoge,c=hoge
        --client_id=
                                     Set client ID (default:)
    -r, --repeatCycle=               Set repeatCycle [Sec] (0:oneshot) (default:0)
 ```

 You can periodically publish with ```-r``` for debugging.
 