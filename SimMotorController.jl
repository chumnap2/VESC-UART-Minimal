using Plots

# --- Simulated MotorController ---
mutable struct MotorController
    speed::Float64
    enabled::Bool
    position::Float64
    velocity::Float64
end

function MotorController()
    MotorController(0.0, false, 0.0, 0.0)
end

function update!(mc::MotorController, dt::Float64)
    if mc.enabled
        mc.velocity = mc.speed
        mc.position += mc.velocity * dt
    else
        mc.velocity = 0.0
    end
end

# --- Simulated MotorBridge ---
mutable struct MotorBridge
    controller::MotorController
end

function CmdSpeed!(mb::MotorBridge, speed)
    mb.controller.speed = speed
    println("✅ Motor speed set to $(speed) units/s")
end

function CmdEnable!(mb::MotorBridge, enable)
    mb.controller.enabled = enable
    println(enable ? "🟢 Motor ENABLED" : "🔴 Motor DISABLED")
end

function sendFeedback(mb::MotorBridge)
    return mb.controller.position, mb.controller.velocity
end

# --- Global Simulation State ---
const mc = MotorController()
const mb = MotorBridge(mc)
const dt = 0.1
const positions = Float64[]
const velocities = Float64[]
const times = Float64[]

# --- Interactive Commands ---
function step_motor(speed::Float64)
    CmdSpeed!(mb, speed)
    CmdEnable!(mb, true)
end

function stop_motor()
    CmdEnable!(mb, false)
end

function simulate!(tmax::Float64=10.0)
    println("🧩 Starting motor simulation for $(tmax) seconds...")
    for t in 0:dt:tmax
        update!(mc, dt)
        pos, vel = sendFeedback(mb)
        push!(positions, pos)
        push!(velocities, vel)
        push!(times, t)
        sleep(dt / 10)   # smooth playback speed
    end
    println("✅ Simulation finished.")
end

function plot_results()
    plot(times, positions, label="Position", xlabel="Time (s)", ylabel="Position", linewidth=2)
    plot!(times, velocities, label="Velocity", linewidth=2)
end
