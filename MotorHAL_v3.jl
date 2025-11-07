module MotorHAL_v3

using SerialPorts

# Open serial port
const sp = SerialPort("/dev/ttyACM0", 115200)
println("Opening motor port: /dev/ttyACM0")

# Send command helper
function send_cmd(cmd::String)
    write(sp, cmd * "\n")
    flush(sp)
end

# Set motor speed
function set_motor_hardware_speed(speed::Float64)
    cmd = "SPEED:$speed"
    send_cmd(cmd)
    println("Sent: $cmd")
end

# Read motor position
function read_motor_position(timeout::Float64 = 2.0)
    send_cmd("POS?")
    start_time = time()
    buffer = ""
    while true
        data = String(SerialPorts.readavailable(sp))
        if !isempty(data)
            buffer *= data
            println("📡 [DEBUG] Received: ", repr(buffer))
            if occursin('\n', buffer)
                line = strip(split(buffer, '\n')[end])
                clean_line = replace(line, r"POS:" => "")
                val = tryparse(Float64, clean_line)
                println("✅ Parsed position: ", val)
                return val
            end
        end
        if time() - start_time > timeout
            @warn "Timeout: no response from motor"
            return nothing
        end
        sleep(0.05)
    end
end

end # module MotorHAL_v3
