module VescPort

using SerialPorts

# 🔧 Change this to your detected port:
const VESC_PORT = "/dev/ttyACM1"

function open_port()
    println("Using VESC serial port: ", VESC_PORT)
    return SerialPort(VESC_PORT, 115200)
end

end # module
