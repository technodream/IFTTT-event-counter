PIRpin = 3
counter=0
port = 80
interval=120000

gpio.mode(5, gpio.OUTPUT)
gpio.mode(PIRpin,gpio.INT,gpio.FLOAT)

function pin1cb() --increment counter for every detection
     counter=counter+1
     tmr.delay(100) --rudimentary debounce
end


function sendData()
  
--t1=adc.read(0) -- reads value from Analog Input (max 1V)
print(counter) --debug

-- flash LED GPIO5 brifly to indicate "alive"
        gpio.write(5, gpio.HIGH)
             tmr.alarm(1, 100, 0, function()
                gpio.write(5, gpio.LOW)
             end)

if counter==0 then return end
		
-- conection to IFTTT channel
print("Sending data to IFTTT channel")
conn=net.createConnection(net.TCP, 0) 
conn:on("receive", function(conn, payload) print(payload) end)
conn:connect(80,'maker.ifttt.com') 

conn:on("connection", function(conn, payload) 
	print("Connected, sending event")
        conn:send("GET /trigger/PIRsensor/with/key/dlpJ9UBTMIvGd6lQ-T9QB_?value1="..counter.." HTTP/1.1\r\n")
        conn:send("Host: maker.ifttt.com\r\n")
        conn:send("Accept: */*\r\n")
        conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.)\r\n")
        conn:send("\r\n")
        
		-- zero counter after send
		counter=0 
		       
    end)

conn:on("sent",function(conn)
        print("Closing connection")
        conn:close()
    end)

conn:on("disconnection", function(conn)
        print("Got disconnection...")
    end)

end

--triggers counter from GPIO
gpio.trig(PIRpin, "both",pin1cb)
-- send data every X ms to IFTTT
tmr.alarm(0, interval, 1, function() sendData() end )
