using ModelingToolkit, DifferentialEquations, Plots

# Set a backend suitable for terminal usage
gr()  # GR backend

# 1️⃣ Independent variable
@parameters t
@variables ω(t)
@parameters J b k_t k_e V_s

# 2️⃣ Derivative operator
D = Differential(t)

# 3️⃣ System equation
eqs = [J*D(ω) + b*ω ~ k_t*(V_s - k_e*ω)]

# 4️⃣ Named ODE system
@named motor = ODESystem(eqs, t, [ω], [J, b, k_t, k_e, V_s])

# 5️⃣ Simplify system
motor_complete = structural_simplify(motor)

# 6️⃣ Initial conditions, parameters, and tspan
u0 = [ω => 0.0]
p  = [J => 0.01, b => 0.1, k_t => 0.2, k_e => 0.2, V_s => 12.0]
tspan = (0.0, 5.0)

# 7️⃣ Solve ODE
prob = ODEProblem(motor_complete, merge(Dict(u0), Dict(p)), tspan)
sol = solve(prob, Tsit5())

# 8️⃣ Plot
plt = plot(sol,
           xlabel="Time (s)",
           ylabel="Angular Velocity ω(t)",
           lw=2,
           legend=false,
           title="DC Motor Model")

# 9️⃣ Save plot to file
savefig(plt, "motor_response.png")
println("Plot saved as motor_response.png")
