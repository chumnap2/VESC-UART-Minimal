using SerialPorts, Printf
include("VescPort.jl")
using .VescPort

sp = SerialPort(VescPort.PORT, 115200)   # safe serial port

function crc16(data::Vector{UInt8})
    crc = 0x0000
    for b in data
        crc = crc ⊻ (b << 8)
        for _ in 1:8
            crc = (crc << 1) ⊻ (0x1021 * ((crc & 0x10000) >> 16))
            crc &= 0xFFFF
        end
    end
    return crc
end

function build_rpm_packet(rpm::Int32)
    payload = UInt8[0x05]
    payload_bytes = reinterpret(UInt8, [rpm])
    payload = vcat(payload, reverse(payload_bytes))
    plen = UInt16(length(payload))
    packet = UInt8[2, UInt8(plen & 0xFF), UInt8(plen >> 8)]
    packet = vcat(packet, payload)
    crc = crc16(payload)
    packet = vcat(packet, UInt8(crc >> 8), UInt8(crc & 0xFF), 3)
    return packet
end

function send_rpm(sp::SerialPort, rpm::Integer)
    write(sp, build_rpm_packet(Int32(rpm)))
end

# Example main loop
try
    while true
        send_rpm(sp, 1000)
        sleep(0.1)
    end
finally
    send_rpm(sp, 0)
    close(sp)
end
