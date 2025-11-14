using CairoMakie

# --------------------------
# Motor model
# --------------------------
J = 0.01
b = 0.1
K = 0.05
R = 1.0

U = 12.0
ω0 = 0.0

tspan = collect(0:0.01:1.0)

function motor_omega(t)
    a = -(b/J)
    bterm = (K*U)/(J*R)
    return (ω0 - bterm/a) * exp(a*t) + bterm/a
end

ω_values = motor_omega.(tspan)

# --------------------------
# Figure
# --------------------------
fig = Figure(size = (800, 500))
ax = Axis(fig[1, 1], xlabel="t (s)", ylabel="ω(t)")

# Pre-create empty line
lineplot = lines!(ax, tspan, zero.(tspan))
lp = lineplot

# --------------------------
# Animation
# --------------------------
record(fig, "motor_response_anim.mp4", 1:length(tspan); framerate=30) do i
    xs = tspan[1:i]
    ys = ω_values[1:i]

    # Update line with *points*
    lp[1][] = Point2f.(xs, ys)
end
