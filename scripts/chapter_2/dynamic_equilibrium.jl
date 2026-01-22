using OrdinaryDiffEq, CairoMakie, LaTeXStrings

inch = 96
pt = 4/3
cm = inch / 2.54
pagewidth = 21cm

newsreader = Makie.to_font("Newsreader 36pt bold")

fonts = (;
    :bold => "Newsreader 36pt bold",
    :regular => "Newsreader 36pt regular",
)

# Define the system of ODEs
function dynamic_equilibrium!(du, u, p, t)
    a, b, c = u
    k1, k2, k3 = p
    du[1] = -k1*a + k3*c
    du[2] = k1*a - k2*b
    du[3] = k2*b - k3*c
end

# Initial conditions and parameters
u0 = [1.0, 0.2, 0.0]
p = [0.14, 0.22, 0.1]
tspan = (0.0, 50.0)

# Create the ODE problem
prob = ODEProblem(dynamic_equilibrium!, u0, tspan, p)

# Solve the ODE problem
save_times = 0:0.01:30
sol = solve(prob, Tsit5(), saveat=save_times)

figure_equilibrium = let f = Figure(size=(14cm, 6.3cm), fonts=fonts)

    ax = Axis(f[1,1], xlabel=L"\textbf{Time}\text{ [min]}", ylabel=L"\textbf{Concentration}
    \text{[mmol L}^{-1}\text{]}",
    xlabelfont=:bold, ylabelfont=:bold,xlabelsize=9pt, ylabelsize=9pt,xticklabelsize=8pt, yticklabelsize=8pt,topspinevisible=false,rightspinevisible=false,spinewidth=1pt,)
    lines!(ax, sol.t, sol[1,:], label="A", color=:black, linewidth=1.5pt)
    lines!(ax, sol.t, sol[2,:], label="B", color=:black, linestyle=:dash, linewidth=1.5pt)
    lines!(ax, sol.t, sol[3,:], label="C", color=:black, linestyle=:dot, linewidth=1.5pt)

    println(sol[1,end], sol[2,end], sol[3,end])

    ax_flux = Axis(f[1,2], xlabel=L"\textbf{Time}\text{ [min]}", ylabel=L"\textbf{Flux}\text{ [mmol L}^{-1}\text{ min}^{-1}\text{]}",
    xlabelfont=:bold, ylabelfont=:bold,xlabelsize=9pt, ylabelsize=9pt,xticklabelsize=8pt, yticklabelsize=8pt,topspinevisible=false,rightspinevisible=false,spinewidth=1pt,)
    v1 = p[1] * sol[1,:]
    v2 = p[2] * sol[2,:]
    v3 = p[3] * sol[3,:]
    lines!(ax_flux, sol.t, v1, label="v1 (A to B)", color=:black, linewidth=1.5pt)
    lines!(ax_flux, sol.t, v2, label="v2 (B to C)", color=:black, linestyle=:dash, linewidth=1.5pt)
    lines!(ax_flux, sol.t, v3, label="v3 (C to A)", color=:black, linestyle=:dot, linewidth=1.5pt)

    Legend(f[1,3], ax, "Species", labelsize=8pt, titlesize=9pt, framevisible=false, titlehalign=:left,halign=:left)
    text!(ax, 0.3, 0.6, text="Dynamic Equilibrium", font=:bold, color=:black, fontsize=8pt, space=:relative)
    text!(ax_flux, 0.3, 0.6, text="Nonzero flux", font=:bold, color=:black, fontsize=8pt, space=:relative)
    arrows2d!(ax_flux, [0.55], [0.57], [0.15], [-0.13], color=:black, label="Flux direction", space=:relative,
    shaftwidth=1pt, tipwidth=6pt, tiplength=7pt)

    for (label, layout) in zip(["A", "B"], [f[1,1], f[1,2]])
    Label(layout[1, 1, TopLeft()], label,
            fontsize = 12pt,
            font = :bold,
            padding = (0, 5, 5, 0),
            halign = :right)
    end


    f
end

save("images/dynamic_equilibrium.svg", figure_equilibrium, px_per_unit = 300/inch)