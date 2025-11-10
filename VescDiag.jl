using SerialPorts

function vesc_diag(port="/dev/ttyACM1")
    println("🔌 Opening serial port: $port")
    sp = SerialPort(port, 115200)
    sleep(0.2)

    # Simple COMM_GET_VALUES packet (direct mode)
    payload = UInt8[4]
    plen = UInt16(length(payload))
    pkt = UInt8[2, UInt8(plen & 0xFF), UInt8(plen >> 8)]
    pkt = vcat(pkt, payload)
    crc = 0x31ce  # precomputed CRC16(0x04)
    pkt = vcat(pkt, UInt8(crc >> 8), UInt8(crc & 0xFF), 3)
    write(sp, pkt)
    sleep(0.1)
    data = readavailable(sp)
    println("📡 Direct response bytes: ", data)

    # Try CAN-forwarded request (CAN ID 1)
    payload = UInt8[4]
    plen = UInt16(length(payload) + 2)  # +2 for CAN header
    pkt = UInt8[2, UInt8(plen & 0xFF), UInt8(plen >> 8), 0x46, 0x01]  # COMM_FORWARD_CAN = 0x46, CAN_ID=1
    pkt = vcat(pkt, payload)
    crc = 0xF8B9  # example CRC16
    pkt = vcat(pkt, UInt8(crc >> 8), UInt8(crc & 0xFF), 3)
    write(sp, pkt)
    sleep(0.2)
    data_can = readavailable(sp)
    println("🚌 CAN response bytes: ", data_can)

    close(sp)
    println("✅ Done.")
end

vesc_diag()
