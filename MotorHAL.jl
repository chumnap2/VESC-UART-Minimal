module MotorHAL

using LibSerialPort  # or your preferred hardware library

# --- MotorController ---
mutable struct MotorController
    speed::Float64
    target_speed::Float64
    enabled::Bool
    position::Float64
    velocity::Float64
end

function MotorController()
    MotorController(0.0, 0.0, false, 0.0, 0.0)
end

# --- MotorBridge ---
mutable struct MotorBridge
    controller::MotorController
end

# --- Motor commands ---
function CmdSpeed!(mb::MotorBridge, speed)
    mb.controller.target_speed = speed
    println("✅ Target speed set to $(speed) units/s")
end

function CmdEnable!(mb::MotorBridge, enable)
    mb.controller.enabled = enable
    println(enable ? "🟢 Motor ENABLED" : "🔴 Motor DISABLED")
end

function sendFeedback(mb::MotorBridge)
    return mb.controller.position, mb.controller.velocity
end

# --- Update function with ramping ---
function update!(mc::MotorController, dt::Float64; ramp_rate=1.0)
    if mc.enabled
        if mc.speed < mc.target_speed
            mc.speed = min(mc.speed + ramp_rate*dt, mc.target_speed)
        elseif mc.speed > mc.target_speed
            mc.speed = max(mc.speed - ramp_rate*dt, mc.target_speed)
        end

        # Send speed to hardware
        set_motor_hardware_speed(mc.speed)

        # Read feedback from motor
        mc.position = read_motor_position()
        mc.velocity = read_motor_velocity()
    else
        mc.speed = 0.0
        set_motor_hardware_speed(0.0)
        mc.velocity = 0.0
    end
end

# --- HAL hardware placeholders ---
function set_motor_hardware_speed(speed::Float64)
    # implement your PWM/CAN/serial command here
end

function read_motor_position()
    return 0.0
end

function read_motor_velocity()
    return 0.0
end

end # module
