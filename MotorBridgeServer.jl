using Sockets
using PyCall

println("🚀 Starting Julia MotorBridgeServer...")

# Load Python VESC module
vesc_mod = pyimport("vescminimal_nov20")
vesc = vesc_mod.VESC("/dev/ttyACM1")

# Safe startup
vesc.set_duty_cycle(0.0)
println("✅ VESC object created and motor initialized at 0 duty")

HOST = ip"127.0.0.1"
PORT = 5555

server = listen(HOST, PORT)
println("✅ TCP MotorBridgeServer listening on $HOST:$PORT")

function handle_client(sock)
    println("✅ Client connected: ", sock)
    while isopen(sock)
        try
            line = readline(sock)
            cmd = strip(line)

            if cmd == ""
                continue
            end

            println("📥 Command received: $cmd")

            if cmd == "enable"
                println("⚡ Enable received (no VESC action required)")

            elseif startswith(cmd, "duty")
                parts = split(cmd)
                if length(parts) == 2
                    duty = parse(Float64, parts[2])
                    println("➡️ Setting duty to $duty")
                    pkt = vesc.set_duty_cycle(duty)
                    println("📦 Packet sent")
                else
                    println("❌ Invalid duty format")
                end

            elseif cmd == "stop"
                println("🔴 Stop command")
                vesc.set_duty_cycle(0.0)

            else
                println("❌ Unknown command: $cmd")
            end

        catch e
            println("❌ Client error: ", e)
            break
        end
    end
    close(sock)
    println("✅ Client disconnected")
end

while true
    client = accept(server)
    @async handle_client(client)
end
