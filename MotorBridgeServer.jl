using Sockets
include("SimMotorBridge.jl")

const PORT = 9001
server = listen(PORT)
println("🚀 MotorBridgeServer started")
println("Waiting for Python client on port $PORT...")

client = accept(server)
println("✅ Python client connected.")

mb = SimMotorBridge()
global running = true
global last_time = time()
global last_pos = get_position(mb)
global last_vel = get_velocity(mb)

time_hist = Float64[]
pos_hist = Float64[]
vel_hist = Float64[]

function handle_command(cmd::String)
    cmd = lowercase(strip(cmd))
    if cmd == "enable"
        CmdEnable!(mb, true)
        println("🔹 Motor ENABLE command received")
    elseif cmd == "disable"
        CmdEnable!(mb, false)
        println("🔹 Motor DISABLE command received")
    elseif startswith(cmd, "speed")
        parts = split(cmd)
        if length(parts) == 2
            v = parse(Float64, parts[2])
            CmdSpeed!(mb, v)
            println("⚡ Motor SPEED command set to $v")
        else
            println("❌ Invalid speed command")
        end
    elseif cmd == "stop"
        global running = false
        println("🛑 Stop command received")
    else
        println("❌ Unknown command: $cmd")
    end
end

# --- Non-blocking readline ---
function try_readline(sock::TCPSocket)
    if !eof(sock) && bytesavailable(sock) > 0
        return readline(sock)
    else
        return nothing
    end
end

try
    println("📊 Starting telemetry loop...")
    while running
        # Read command if available
        cmd = try_readline(client)
        if cmd !== nothing
            handle_command(cmd)
        end

        # Update simulation
        global last_time, last_pos, last_vel
        dt = time() - last_time
        step!(mb, dt)
        last_pos = get_position(mb)
        last_vel = get_velocity(mb)
        last_time = time()

        # Send telemetry
        write(client, "T:$last_pos,$last_vel\n")
        flush(client)

        sleep(0.05)
    end
finally
    global running = false
    close(client)
    close(server)
    println("🛑 Server shut down")
end
