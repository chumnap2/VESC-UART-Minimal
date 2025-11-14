#!/usr/bin/env julia
using ModelingToolkit, DifferentialEquations
using CairoMakie

# ----------------------------
# Symbolic model definition
# ----------------------------
@parameters t J b k_t k_e V_s
@variables ω(t)
D = Differential(t)

eqs = [J*D(ω) + b*ω ~ k_t*(V_s - k_e*ω)]
@named motor = ODESystem(eqs, t, [ω], [J, b, k_t, k_e, V_s])
motor_simplified = structural_simplify(motor)

# ----------------------------
# Parameter values and setup
# ----------------------------
J_val  = 0.01
b_val  = 0.1
k_t_val = 0.2
k_e_val = 0.2
voltages = [6.0, 12.0, 24.0]  # multiple supply voltages

u0 = [ω => 0.0]
tspan = (0.0, 5.0)

# ----------------------------
# Solve and collect results
# ----------------------------
sols = Dict()
for V in voltages
    p = [J => J_val, b => b_val, k_t => k_t_val, k_e => k_e_val, V_s => V]
    prob = ODEProblem(motor_simplified, merge(Dict(u0), Dict(p)), tspan)
    sols[V] = solve(prob, Tsit5())
end

# ----------------------------
# Plot with Makie
# ----------------------------
f = Figure(resolution = (800, 500))
ax = Axis(f[1, 1],
    title = "DC Motor Angular Velocity vs Time",
    xlabel = "Time (s)",
    ylabel = "ω(t) [rad/s]"
)

colors = [:blue, :green, :red]
for (i, V) in enumerate(voltages)
    sol = sols[V]
    lines!(ax, sol.t, sol[ω], color = colors[i], linewidth = 3, label = "Vₛ = $(V) V")
end

axislegend(ax, position = :rb)
save("motor_response_makie.png", f)
display(f)

println("✅ Plot saved as motor_response_makie.png")
