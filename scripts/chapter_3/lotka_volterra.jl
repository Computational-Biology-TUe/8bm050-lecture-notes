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

function lv!(du, u, p, t)
    x, y = u
    a, b, c, d = p
    du[1] = a * x - b * x * y
    du[2] = -d * y + c * x * y
end

# Initial conditions and parameters
u0 = [40.0, 9.0]
p = [0.1, 0.02, 0.01, 0.1]
tspan = (0.0, 200.0)

# Create the ODE problem
prob = ODEProblem(lv!, u0, tspan, p)

# Solve the ODE problem
save_times = 0:0.1:200
sol = Array(solve(prob, Tsit5(), saveat=save_times))

# Create the figure
figure_lv = let f = Figure(size=(14cm, 6.3cm), fonts=fonts)
    ax = Axis(f[1,1], xlabel=L"\textbf{Time}\text{ [days]}", ylabel=L"\textbf{Population}\text{ [individuals]}",
    xlabelfont=:bold, ylabelfont=:bold, xlabelsize=9pt, ylabelsize=9pt,
    xticklabelsize=8pt, yticklabelsize=8pt,
    topspinevisible=false, rightspinevisible=false, spinewidth=1pt)
    lines!(ax, save_times, sol[1,:], label="Rabbit", color=:grey, linewidth=1.5pt)
    lines!(ax, save_times, sol[2,:], label="Fox", color=:grey, linestyle=:dash, linewidth=1.5pt)
    Legend(f[1,2], ax, "Species", labelsize=8pt, titlesize=9pt, framevisible=false, titlehalign=:left, halign=:left)
    f
end

save("images/lotka_volterra.svg", figure_lv, px_per_unit=300/inch)

