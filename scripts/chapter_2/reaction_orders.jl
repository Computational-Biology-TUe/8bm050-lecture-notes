using CairoMakie, LaTeXStrings

inch = 96
pt = 4/3
cm = inch / 2.54
pagewidth = 21cm

newsreader = Makie.to_font("Newsreader 36pt bold")

fonts = (;
    :bold => "Newsreader 36pt bold",
    :regular => "Newsreader 36pt regular",
)

"""
Calculate the reaction rate based on concentration `c`, order of reaction `order`, and rate constant `k`.

Parameters:
- c: Concentration of the reactant (in mmol L^-1).
- order: Order of the reaction (default is 1).
- k: Rate constant (default is 1.0).

Returns:
- Reaction rate (in mmol L^-1 min^-1).
"""
function reaction_rate(c; order = 1, k = 1.0)

    return k * c^order
end

figure_reaction_orders = let f = Figure(size=(11cm, 6.3cm), fonts=fonts)

    ax = Axis(f[1,1], xlabel=L"\textbf{Concentration}\text{ [mmol L}^{-1}\text{]}", ylabel=L"\textbf{Reaction Rate}
    \text{[mmol L}^{-1}\text{ min}^{-1}\text{]}",
    xlabelfont=:bold, ylabelfont=:bold,xlabelsize=9pt, ylabelsize=9pt,xticklabelsize=8pt, yticklabelsize=8pt,topspinevisible=false,rightspinevisible=false,spinewidth=1pt,)
    
    # Plot for first-order reaction
    c_first_order = 0:0.01:2
    rate_first_order = reaction_rate.(c_first_order; order=0, k=0.1)
    lines!(ax, c_first_order, rate_first_order, label="Zeroth Order (k=0.1)", color=:grey, linewidth=1.5pt)

    # Plot for second-order reaction
    c_second_order = 0:0.01:2
    rate_second_order = reaction_rate.(c_second_order; order=1, k=0.1)
    lines!(ax, c_second_order, rate_second_order, label="First Order (k=0.1)", color=:grey, linestyle=:dash, linewidth=1.5pt)

    # Plot for zero-order reaction
    c_zero_order = 0:0.01:2
    rate_zero_order = reaction_rate.(c_zero_order; order=2, k=0.1)
    lines!(ax, c_zero_order, rate_zero_order, label="Second Order (k=0.1)", color=:grey, linestyle=:dot, linewidth=1.5pt)

    Legend(f[1,2], ax, "Reaction Orders", labelsize=8pt, titlesize=9pt, framevisible=false,
           titlehalign=:left, halign=:left)

    f
end

save("images/reaction_orders.svg", figure_reaction_orders, px_per_unit = 300/inch)