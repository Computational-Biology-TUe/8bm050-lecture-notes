using BifurcationKit, CairoMakie, LaTeXStrings

F(x, p) = @. p[1] + x^5/(1 + x^5) - x
prob = BifurcationProblem(F, [1.0], [0.3], 1; record_from_solution = (x,p; k...) -> x[1])
br = continuation(prob, PALC(), ContinuationPar(p_min= 0.2, p_max=0.7, dsmin=1e-5, dsmax=0.01, ds = 0.001), verbosity=3)
fieldnames(typeof(br))
bps = [p.param for p in br.specialpoint][1:end-1]
bpy = [p.x for p in br.specialpoint][1:end-1]
figure_bifurcation = let f = Figure(size=(10cm, 6cm), fonts=fonts)

    ax = Axis(f[1,1], xlabel=L"\textbf{Parameter}\text{ [p]}", ylabel=L"\textbf{Variable}\text{ [y]}",
    xlabelfont=:bold, ylabelfont=:bold,xlabelsize=9pt, ylabelsize=9pt,xticklabelsize=8pt, yticklabelsize=8pt,topspinevisible=false,rightspinevisible=false,spinewidth=1pt,)
    lines!(ax, br.param[br.x .<= bpy[1]], br.x[br.x .<= bpy[1]], color=:black, linewidth=1.0pt)
    lines!(ax, br.param[br.x .>= bpy[2]], br.x[br.x .>= bpy[2]], color=:black, linewidth=1.0pt, label="Stable branch")
    lines!(ax, br.param[br.x .>= bpy[1] .&& br.x .<= bpy[2]], br.x[br.x .>= bpy[1] .&& br.x .<= bpy[2]], color=:black, linewidth=1.0pt, linestyle=:dash, label="Unstable branch")
    scatter!(ax, bps, bpy, color=:red, markersize=8pt, label="Bifurcation points")

    Legend(f[1,2], ax, "Legend", labelsize=8pt, titlesize=9pt, framevisible=false,
           titlehalign=:left, halign=:left)

    f
end

save("images/bifurcation.svg", figure_bifurcation, px_per_unit = 300/inch)