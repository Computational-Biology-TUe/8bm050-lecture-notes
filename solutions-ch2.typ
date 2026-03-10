#import "@preview/whalogen:0.3.0": ce
#import "@preview/subpar:0.2.2"
#let chq = symbol(
  "⇌"
)

#show list: set list(indent: 18pt, marker: sym.triangle.filled.small.r)
#let ddt(it) = $ (upright(d)#it) / (upright(d)t) $
#let ib-indent = 0.4in

#counter("question").update(1)
#counter("subquestion").update(1)

#let question(body) = {
  counter("subquestion").update(1)
  grid(
    columns: (1cm, auto),
    gutter: 0.2cm,
    context [*#counter("question").display())*],
    [#body]
  )
    v(6pt)
    counter("question").step()
}

#let subquestion(body) = {
  grid(
    inset: (left: 0.4cm, bottom: 0cm, top: 0cm),
    columns: (1cm, auto),
    context [#counter("subquestion").display("a)")],
    [#body]
  )
    v(6pt)
    counter("subquestion").step()
}

= Exercise solutions
#v(20pt)
1.a $mat(
  0, 0, 0;
  1, 0, 1;
  0, 0, 0)$

1.b $mat(
  0, 1, 0;
  1, 0, 1;
  0, 0, 0)$

1.c $mat(
  0, 1, 0;
  1, 0, 1;
  0, 1, 0)$
#v(20pt)
2.a See image below. Edges without marking have weight 1.
#image("solutions/2a.png", width: 50%)

2.b Reaction 3 is split into two columns for the two directions of the reaction. The resulting matrix is:

$N = mat(
  -1, 0, 0, 0, -1;
  2, -1, 0, 0, 0;
  -1, 1, 0, 0, 0;
  0, -1, 0, 0, 0;
  0, 1, -3, 3, 0;
  0, 0, 1, -1, -1;
  0, 0, 0, 0, 1;)
$

2.c Three laws:

- $B + 2C + D = "constant"$
- $E + 3F - 3A - 4B - 5C = "constant"$
- $A+B+C+G = "constant"$

2.d One dynamic equilibrium between the forward and backward reactions of reaction 3.

3.a See image below. 
#image("solutions/3a.png", width: 50%)

3.b 2 linkage classes

3.c $delta = 0$. Network is not entirely weakly reversible (D+E cannot return to C), so no deficiency zero theorem.

4. This reaction network is fully reversible. All reactions are accompanied by their reverse reaction.

5.a This reaction network is weakly reversible. One linkage class is fully reversible ({A,B}), the other class is only weakly reversible.

5.b 
- $ddt(A) = -k_1 A + k_2 B - k_3 A C + k_4 D + k_6 B E$
- $ddt(B) = k_1 A - k_2 B + k_5 D - k_6 B E$
- $ddt(C) = -k_3 A C + k_4 D + k_6 B E$
- $ddt(D) = k_3 A C - k_4 D - k_5 D$
- $ddt(E) = k_5 D - k_6 B E$

5.c
- $k_1$: first-order
- $k_2$: first-order
- $k_3$: second-order
- $k_4$: first-order
- $k_5$: first-order
- $k_6$: second-order

5.d First order constants are in units of $"min"^(-1)$, second order constants are in units of $"mM"^(-1) "min"^(-1)$.

6. Set the ODE to zero and solve for the steady state to derive these formulas.

7.a All are $"min"^(-1)$.

7.b $"Production"(t=0) =  k_0 C_b$