// script to receive packages from the Olimex-EKG-EMG-Shield

const SerialPort = require('serialport') // -> npm install serialport
const ByteLengthParser = require('@serialport/parser-byte-length')
const fs = require('fs')
const os = require('os')

//var port = "COM3"   // -> windows
var port = "/dev/ttyACM0" // -> ubuntu
var baudrate = 57600
var samplingRate = 256
var buffer = []
var maxInputValue = 1023
var voltageRange = 3.3 // volt
var gain = 2848 // total gain of the Olimex Shield
var measurementTime = 60 // seconds
var measurementName = 'einthoven3.txt'

const serialport = new SerialPort(port, {baudRate: baudrate})
var packageCount = 0
var ecgOutputData = ''

const parser = serialport.pipe(new ByteLengthParser({length: 6}))
parser.on('data', handleData)

function byteArrayToLong(byteArray) {
    var value = 0
    for (var i = byteArray.length - 1; i >= 0; i--) {
        value = (value * 256) + byteArray[i]
    }
    return value
}

function convertToMilliVolt(value) {
    return (((voltageRange / (maxInputValue / value)) * 1000) / gain)
}

function writeToFile (data) {
    fs.writeFileSync(measurementName, data, (err) => {
        if (err) throw err
    })
    console.log('The file has been saved!')
    return
}

function handleData (data) {
    packageCount++
    console.log("Package Count: " + packageCount)
    var time = packageCount / samplingRate
    console.log("Time: " + time + " sec")
    //console.log(data)
    
    // values will be decimal
    var values = new Uint8Array(data);
    //console.log(values)

    values.forEach(value => {
        if(buffer.length === 0 && value === 165){ // sync0
            buffer.push(value)
        }else if(buffer.length === 1){  // sync1
            if(value === 90){
                buffer.push(value)
            }else{
                buffer = []
            }
        }else if (buffer.length > 1){
            if(buffer.length === 5){
                if(value === 1){    // switch states -> 1 package received
                    console.log(buffer)
                    // data[3] & data[4] -> Channel one
                    var val = byteArrayToLong([buffer[4], buffer[3]])
                    console.log("CH1 value: " + val)
                    ecgOutputData = ecgOutputData.concat(String(time) + ' ' + String(convertToMilliVolt(val)) + os.EOL)
                    buffer = []
                }else{
                    buffer = []
                }
            }else{
                buffer.push(value)
            }   
        }
    })

    if(time > measurementTime) {
        parser.removeAllListeners()
        writeToFile(ecgOutputData)
        process.exit(0)
    }
}