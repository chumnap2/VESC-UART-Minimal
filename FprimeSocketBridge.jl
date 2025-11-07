using Sockets, JSON3

include("SimMotorController.jl")

# --- Simple TCP bridge server ---
function start_bridge_server(port::Int=9000)
    server = listen(port)
    println("🌐 F´ Simulation Bridge active on port $(port)...")
    println("Waiting for F´ connection...")

    client = accept(server)
    println("✅ F´ connected.")

    # Background task to send telemetry
    @async begin
        while true
            pos, vel = sendFeedback(mb)
            msg = JSON3.write(Dict("pos"=>pos, "vel"=>vel))
            write(client, msg * "\n")
            sleep(0.5)
        end
    end

    # Handle incoming commands
    for line in eachline(client)
        try
            data = JSON3.read(line)
            cmd = data["cmd"]
            if cmd == "ENABLE"
                CmdEnable!(mb, true)
            elseif cmd == "DISABLE"
                CmdEnable!(mb, false)
            elseif cmd == "SPEED"
                speed = data["value"]
                CmdSpeed!(mb, speed)
            end
        catch e
            @warn "Invalid command or JSON: $line" exception=(e, catch_backtrace())
        end
    end
end
