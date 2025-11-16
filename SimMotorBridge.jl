# SimMotorBridge.jl
mutable struct SimMotorBridge
    enabled::Bool
    speed::Float64
    pos::Float64
    vel::Float64
end

function SimMotorBridge()
    SimMotorBridge(false, 0.0, 0.0, 0.0)
end

# Commands
function CmdEnable!(mb::SimMotorBridge, en::Bool)
    mb.enabled = en
end

function CmdSpeed!(mb::SimMotorBridge, speed::Float64)
    mb.speed = speed
end

# Update simulation (call every step)
function step!(mb::SimMotorBridge, dt::Float64=0.1)
    if mb.enabled
        mb.vel = mb.speed
        mb.pos += mb.vel * dt
    else
        mb.vel = 0.0
    end
end

function get_position(mb::SimMotorBridge)
    return mb.pos
end

function get_velocity(mb::SimMotorBridge)
    return mb.vel
end
