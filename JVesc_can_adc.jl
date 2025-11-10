using SerialPorts, Printf

# --- CRC helper ---
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

# --- Packet builders ---
function build_rpm_packet(rpm::Int32)
    payload = UInt8[0x05]  # COMM_SET_RPM
    payload_bytes = reinterpret(UInt8, [rpm])
    payload = vcat(payload, reverse(payload_bytes))
    plen = UInt16(length(payload))
    packet = UInt8[2, UInt8(plen & 0xFF), UInt8(plen >> 8)]
    packet = vcat(packet, payload)
    crc = crc16(payload)
    packet = vcat(packet, UInt8(crc >> 8), UInt8(crc & 0xFF))
    push!(packet, 3)
    return packet
end

function build_can_forward_packet(can_id::UInt8, cmd::UInt8)
    payload = UInt8[cmd]
    plen = UInt16(length(payload))
    packet = UInt8[2, UInt8(plen & 0xFF), UInt8(plen >> 8)]
    packet = vcat(packet, payload)
    crc = crc16(payload)
    packet = vcat(packet, UInt8(crc >> 8), UInt8(crc & 0xFF), 3)
    return packet
end

# --- VESC commands ---
function send_rpm(sp::SerialPort, rpm::Integer)
    packet = build_rpm_packet(Int32(rpm))
    write(sp, packet)
end

function read_adc_values(sp::SerialPort)
    payload = UInt8[0x04]  # COMM_GET_VALUES
    plen = UInt16(length(payload))
    packet = UInt8[2, UInt8(plen & 0xFF), UInt8(plen >> 8)]
    packet = vcat(packet, payload)
    crc = crc16(payload)
    packet = vcat(packet, UInt8(crc >> 8), UInt8(crc & 0xFF), 3)
    write(sp, packet)
    sleep(0.05)
    return readavailable(sp)
end

function read_can_values(sp::SerialPort, can_id::UInt8)
    packet = build_can_forward_packet(can_id, 0x04)  # 0x04 = COMM_GET_VALUES
    write(sp, packet)
    sleep(0.05)
    return readavailable(sp)
end
#################################################
# --- Main loop with automatic port handling ---
function vesc_can_adc_loop(can_id::UInt8)
    try
        sp = SerialPort("/dev/ttyACM2", 115200)
        try
            while true
                # Example: spin motor at 1000 RPM
                send_rpm(sp, Int32(1000))

                # Read ADC values
                adc_buf = read_adc_values(sp)
                if !isempty(adc_buf)
                    @printf("ADC raw: %s\n", adc_buf)
                else
                    println("No ADC data yet")
                end

                # Read CAN values
                can_buf = read_can_values(sp, can_id)
                if !isempty(can_buf)
                    @printf("CAN[%d] raw: %s\n", can_id, can_buf)
                else
                    println("No data from CAN[$can_id]")
                end

                sleep(0.1)
            end
        finally
            send_rpm(sp, 0)  # stop motor on exit
            close(sp)
        end
    catch e
        @error "Failed to open VESC port" exception=e
    end
end

#############################
# --- Run the loop ---
# vesc_can_adc_loop(1)  # Use your CAN ID
