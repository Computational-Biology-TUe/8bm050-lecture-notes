#import "template.typ": template, bosman_colors, example_box, warning_box, help_box, info_box
#import "@preview/whalogen:0.3.0": ce
#import "@preview/subpar:0.2.2"
#let chq = symbol(
  "⇌"
)

#show: template.with(
  title: "Introduction to Modelling in Systems Biology",
  //subtitle: "",
  author: (
    name: "Max de Rooij",
    email: "m.d.rooij@tue.nl"
  ),
  date: datetime.today(),
  internal: "8BM050 - Systems Biology Models",
  copyright: [Version 1.0.2, 2025-2026
    
© 2025 Max de Rooij. All rights reserved.

This document and all its contents are licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License (CC BY-NC-SA 4.0). You may not use this document for commercial purposes. For more information, see https://creativecommons.org/licenses/by-nc-sa/4.0/.

The author has made every effort to ensure the accuracy of the information contained herein. However, the author makes no warranties or representations regarding the completeness, accuracy, or reliability of the content. If you observe any errors or inaccuracies, please contact the author or raise an issue on the GitHub repository.

* Acknowledgements *

Parts of these lecture notes, in particular the first chapter on dynamic models, have been based on the lecture notes on simulation of biochemical systems by prof. Huub ten Eikelder. 

* Version History *
- v0.2.0: Initial version of the lecture notes for the course 8BM050.
- v0.2.1: Added answers of exercises in chapters 2 and 3.
- v0.2.2: Added chapter 6 on whole-body models.
- v1.0.0: Full revision of the lecture notes for academic year 2025-2026
- v1.0.1: Added short chapter on Sensitivity Analysis.
- v1.0.2: Small corrections.
],

  department: "Department of Biomedical Engineering",
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

= Introduction to Systems Biology

#set align(center)
#quote(block: true, attribution: [Jack Sparrow (Pirates of the Caribbean)])[
  #text(size: 13pt)[_"The problem is not the problem. The problem is your attitude about the problem."_]
]
#v(2em)
#set align(left)

Scientists create models to help understand, study, and predict the world around them. However, ask a scientist what a model is, and you will receive a variety of answers, depending on the field of study. While the use of models is ubiquitous in science, the types of models used vary widely between disciplines. Before we dive into the specifics of the types of models discussed in these lecture notes, however, we need to clarify #emph[why] to model anything in the first place.

The British statistician George Box famously wrote: _"All models are wrong"_. @box_science_1976 Capturing that models are simplifications of reality, the common aphorism is often extended with _"Some are useful"_#footnote[Contrarily to what is commonly stated, the full phrase "All models are wrong. Some are useful." was not originally written down by George Box. Only the first part of this aphorism is directly phrased from his 1976 paper 'Science and Statistics'.], highlighting that models are designed to be useful for a specific purpose. You must understand that before you can start creating a model, you must first understand the purpose you are making the model for. The goal of your model will often determine the type of model, the level of detail, and the assumptions you make, in order to achieve that goal. 

Similarly, when talking about the quality of a model, we then cannot simply state that a model is good or bad, or base our judgement on the accuracy with which the model corresponds to reality. In discussing a model, we must #emph[always] consider the purpose of the model, whether the model is of use to that purpose, and whether the assumptions or approximations made in the model are valid #emph[for that purpose]. 

Let me illustrate this with an example. Imagine you have a ball ($B$) that is thrown into the air. If you want to model the trajectory of $B$, we can use a simple model that describes the position ($x_B (t)$) and velocity ($v_B (t)$) of the ball as a function of time:

$ 
(upright(d)x_B (t))/(upright(d)t) = v(t) \
(upright(d)v_B (t))/(upright(d)t) = -g
$<model-velocity-of-a-ball>

Where $x_B (0) = 0$ and $v_B (0) = v_0$, and $g$ is the gravitational acceleration. This model is useful for predicting the trajectory of the ball, but it does not take into account factors such as air resitance or the spin of the ball, and the model only takes into account the vertical motion of the ball. If you want to model the trajectory of the ball in more detail, you could add additional equations to account for these factors, but this would make the model more complex. 

On the other hand, this model is extremely unuseful for determining the mass of the ball. For that, you can use a much simpler model, assuming the ball is a sphere with a known outer radius $R$, inner radius $r$, and made from a material with a known density $rho$ and filled with air with a known density $rho_"air"$.

$ M_B = 4/3 pi (R^3 - r^3) rho + 4/3 pi r^3 rho_"air" $<model-mass-of-a-ball>

Both the former and the latter model are illustrated in @models-of-a-ball. This somewhat obvious example illustrates that there is no such thing as a single model of an object or system, and that you only truly know what you are modelling when you know the purpose of your model. As both models serve different purposes, the quality of both models is difficult to compare.

#figure(
  image("images/models_of_a_ball.svg"),
  caption: [Illustrations of two different models of a ball, each serving a different purpose. *A* illustrates a ball being thrown into the air with a velocity $v_0$. The first model (@model-velocity-of-a-ball) in the text can be used to predict the trajectory of the ball. *B* shows the inner ($r$) and outer ($R$) radii of a ball, which can be used in combination with the second model (@model-mass-of-a-ball) in the text to calculate the mass of the ball.],
)<models-of-a-ball>

In these lecture notes, we will focus on the modelling of biological systems. When we are talking about a model, we mean a mathematical model, often implemented in a computer. These computer models are also called _in silico_ models, named after the element 'Silicon' (Si), which is an important component of semiconductors in computer chips.#footnote[The term _in silico_ is a natural extension of the classical terms _in vitro_ (lit. "in glass"), which represents experiments performed in a lab, outside a living organism, or _in vivo_ (lit. "in the living"), usually referring to an experiment performed on a living organism.]

Even within computer models, we can make distinctions between types of models. A strong distinction often made is the difference between data-driven, and principles-driven models. In data-driven models, we typically start from a large set of measurements, combined with the desired outcome, such as a prediction, and we let the computer come up with a model that can connect the two. In principles-driven models, we start from existing knowledge of a specific process, and convert this knowledge into rigid mathematical formulations. In the latter, a model is a structured version of a collection of previous knowledge, that we use systematically to obtain new information. Both techniques can be combined, as well, were parameters, or even parts of whole models are distilled from measurements directly, while other parts of the model are fixed based on literature knowledge. The techniques involved in that are beyond the scope of these lecture notes, however.

The mathematical framework for each model can vary depending on the level of detail we wish to include, the amount of information we possess, and the questions we wish to answer using the model. In these lecture notes, models composed of differential equations are discussed, which can be used to describe processes that change over time.

== Studying Biological Processes as Interconnected Systems
Many ancient cultures have sought to understand the world around us by defining the most basic components that make up everything. In ancient Greece, the philosopher Empedocles determined all matter to be composed of four primal elements: earth, air, fire, and water.  @Stroker1968 An illustration of these four elements and their combinations is shown in @four-elements.


#figure(
  image("images/Leibniz_four_elements.jpg", width: 50%),
  caption: [Leibniz representation of the universe by combining the four elements of Empedocles according to Aristotle. Gottfried Wilhelm von Leibniz, Public domain, via Wikimedia Commons.]
)<four-elements>

Later, Aristotle added a fifth element, _Aether_, as a permanent and heavenly substance. These five elements are seen in other cultures, such as Hinduism @Gopal1990 and Chinese culture @Carroll2012. This idea of reducing the world around us into fundamental components had also transferred to medicine, where Hippocrates systemized the study of four humours _blood_, _yellow bile_, _black bile_, and _phlegm_, which can be linked to air, fire, earth and water respectively. In this study, health was described as the notion of a _balance_ in the amounts of these four humours and subsequently diseases were caused by an imbalance. This practice of humoral medicine was common until the 19#super[th] century. @Jackson2001

=== Properties of complex systems
While many advances were made in modern medicine, for the greater part of the 20#super[th] century, understanding of biology and medicine was dominated by the so-called _reductionist_ view. The central idea was that by detailed examination of each component in the system, we would gain an understanding of the system as a whole. While the obtained knowledge from reductionist research is useful in studying biological systems from a biochemical perspective, reducing these to the sum of their parts has disadvantages that relate to some key properties in complex regulatory systems.

The first of these is _emergence_. Complex systems regularly display properties related to the combined interaction of the components. These properties cannot be directly related to the components alone. This is often observed in chemistry, as knowledge about the interaction between atoms is not enough to understand the interaction between molecules, as they display emergent properties in specific configurations, which we need to understand as well. #footnote[For a recent example of emergent behavior, read the paper 'Emergence of collective oscillations in massive human crowds'@gu_emergence_2025, in which the authors describe and model emergent oscillatory dynamic behavior in large crowds.]

A second property is _redundancy_. The inherent robustness of biological systems to perturbations is what keeps us alive. Biological systems are robust because of a large redundancy in their components. This means that different components can compensate together in situations when a component is lacking. 

The third and last key property is _modularity_. As also seen in various other courses on biology, our body can be studied on multiple levels, as it is composed of various organ systems, that are each made up of organs. Each organ in our body is built from forms of tissue, which is made up of cells. This strongly hierarchical property requires us to study processes on multiple levels. @Aderem2005

For an illustration of all three properties, see @properties-of-complex-systems. In this figure, we see that the whole system displays properties that cannot be directly related to the individual components (emergence), that multiple components can compensate for each other in case one component is lacking (redundancy), and that the system can be studied on multiple levels, such as organs, tissues, and cells (modularity).

#figure(
  image("images/complex_system_properties.svg"),
  caption: [Three properties of complex systems. From left to right: *Emergence*, where the whole system displays properties that cannot be directly related to the individual components. *Redundancy*, where multiple components can compensate for each other in case one component is lacking. *Modularity*, where the system can be studied on multiple levels, such as organs, tissues, and cells.],
)<properties-of-complex-systems>


=== Studying complex systems
A common way to gain understanding about these systems as a whole is through combination of experimental 'wet lab' research (_in vitro_ and _in vivo_ experiments), and _in silico_ modelling. The latter of which is an important component in systems biology. This field is largely concerned with the study of interacting biological components, not by merely investigating the components individually, but by examining the living system as a whole. A common example to illustrate the utility of the approach taken in systems biology can be seen in @blind-men-elephant. In this figure, six men are each investigating a part of the whole system (elephant), while only by studying the system as a whole, the correct solution can be found. 

#figure(
  image("images/6-blind-men-hans-1024x6541.jpg", width: 100%),
  caption: [Six blind men investigating parts of the elephant. Each of the men has a different hypothesis of what the elephant could be, based on them feeling a specific part of the elephant. However, only by investigating all the specific parts, they can conclude that there is an elephant standing before them.],
) <blind-men-elephant>

This practice can be applied to study mechanisms that keep us alive, such as homeostatic systems, or cellular communication networks, and to identify causes of disease and the effect of possible treatments. @Voit2022 In these lecture notes, we aim to provide an introduction to integrating biological knowledge and findings from wet lab research into models, analyzing these models, and identifying basic properties of these systems that are otherwise difficult or impossible to study in practical experiments alone. In this way, we hope to create an understanding of the utility and importance of models as a tool to aid engineering research. @vanRiel2020

== Mathematical Foundations

=== Ordinary Differential Equations
When building models of processes that happen over time, #emph[ordinary differential equations] are well-suited, because these equations intuitively allow for dynamic production and consumption terms. Your first encounter with differential equations may have been an undergraduate calculus course, where the main goals of these equations were to solve them. For example, the differential equation

$ (upright(d) y) / (upright(d) t) = -a y(t) $<first-order-linear-ODE>

can be solved to yield the solution $y(t) = y(0) e^(-a t)$, where $y(0)$ is the initial value of $y$ at time $t=0$. This solution describes an exponential decay of the variable $y$ over time, with a rate constant $a$.

Besides solving differential equations, it may be even more important in this course to understand the meaning of the terms in the differential equations. 

An intuitive way of looking at a differential equation for a molecule $X$ can be:
$ underbrace((upright(d)X )/ (upright(d)t), "rate of change of X at time t") = upright("Production")(X)-"Consumption"(X) $

This equation states that the rate of change of the molecule $X$ at time $t$ is equal to the production of $X$ minus the consumption of $X$. The production and consumption terms can be functions of time, or of other variables, such as the concentration of other molecules. In these lecture notes, more will be included about modelling concentrations of molecules in later chapters. 

Another interesting aspect of differential equations is that we can use them to find the value of a variable when is does not change anymore. This is called a _steady-state_ or _equilibrium_. In the example above, we can find the steady-state by setting the rate of change to zero:

$ 0 = upright("Production")(X)-"Consumption"(X) $

This means that the production of $X$ is equal to the consumption of $X$, and the concentration of $X$ will not change anymore. This is an important concept in systems biology, as many biological processes are regulated to maintain a steady-state. More concretely, we can find the steady-state of @first-order-linear-ODE by setting $(upright(d)y) / (upright(d)t) = 0$, which yields the steady-state solution $y(t) = 0$, which means that as $y$ approaches zero, the rate of change of $y$ also approaches zero, and $y$ will not change anymore.

=== Linear Algebra 
Linear algebra is a branch of mathematics that deals with vectors, matrices, and linear transformations. It is a powerful tool for solving systems of linear equations, which are equations that can be written in the form: 
$ bold(A) bold(x) = bold(b) $

Where $bold(A)$ is a matrix, $bold(x)$ is a vector of variables, and $bold(b)$ is a vector of constants. In systems biology, linear algebra is often used to analyze and model biological systems, such as metabolic networks, gene regulatory networks, and signal transduction pathways.

We will assume that you are familiar with the basic operations of linear algebra. If you are not familiar with these concepts, we recommend that you review them before proceeding with these lecture notes.

==== The left and right null space
In these lecture notes, we will often refer to the _left null space_ and _right null space_ of a matrix. The left null space of a matrix $bold(A)$ is the set of all vectors $bold(y)$ such that:
$ bold(y)^T bold(A) = bold(0)^T $

Where $bold(0)$ is the zero vector. The left null space is also called the _kernel_ of the transpose of the matrix $bold(A)$. The dimension of the left null space is called the _left nullity_ of the matrix $bold(A)$.

The right null space of a matrix $bold(A)$ is the set of all vectors $bold(x)$ such that:
$ bold(A) bold(x) = bold(0) $
Where $bold(0)$ is the zero vector. The right null space is also called the _kernel_ of the matrix $bold(A)$. The dimension of the right null space is called the _right nullity_ of the matrix $bold(A)$.

==== Matrix rank
The rank of a matrix $bold(A)$ is the dimension of the column space of the matrix. The column space is the set of all linear combinations of the columns of the matrix. The rank of a matrix is also equal to the dimension of the row space of the matrix, which is the set of all linear combinations of the rows of the matrix. The rank of a matrix is an important concept in linear algebra, as it provides information about the linear independence of the columns and rows of the matrix. A matrix with full rank has linearly independent columns and rows, while a matrix with less than full rank has linearly dependent columns and rows. 

We can find the rank of a matrix by using row reduction to bring the matrix to its row echelon form, and counting the number of non-zero rows. Alternatively, we can use the singular value decomposition (SVD) of the matrix to find its rank. The rank of a matrix is also related to the nullity of the matrix, as the rank-nullity theorem states that:
$ "rank"(bold(A)) + "nullity"(bold(A)) = n $

Where $n$ is the number of columns of the matrix $bold(A)$.

=== Taylor Series for Function Approximation
In these lecture notes, we also assume that you are familiar with the Taylor series, which is a way to approximate a function by a polynomial. The Taylor series of a function $f(x)$ around a point $a$ is given by:

$ f(x) approx f(a) + (x-a) / 1! dot (upright(d) )/(upright(d) t)(f(a)) + (x-a)^2 / 2! dot (upright(d)^2 )/(upright(d) t^2)(f(a)) + dots + (x-a)^n / n! dot (upright(d)^n )/(upright(d) t^n)(f(a)) $

You can see, that filling in $x = a$ for this function will yield $f(a)$ exactly. The Taylor series is in principle an infinite series, but in practice, the series is truncated to a finite number of terms, which is called the _order_ of the Taylor series. The higher the order, the more accurate the approximation will be.

If the function we are approximating is a polynomial, the Taylor series will give the exact polynomial, as long as the order of the Taylor series is equal to or higher than the degree of the polynomial. For example, the Taylor series of the function $f(x) = x^2$ around the point $a = 0$ is given by:

$ f(x) approx 0 + x / 1! dot (upright(d) f)/(upright(d) t)(0) + x^2 / 2! dot (upright(d)^2 f)/(upright(d) t^2)(0) = 0 + 2 dot 0 + (2x^2)/(2) = x^2 $

#example_box(
  body: [In case the function is not a polynomial, the Taylor series will only approximate the function around the point $a$, and the approximation will become less accurate as we move further away from $a$. For example, the Taylor series of the function $f(x) = e^x$ around the point $a = 0$ can be calculated. 

  We first need to calculate the derivatives of $f(x)$ at the point $a = 0$. For $f(x) = e^x$, all derivatives are equal to $e^0 = 1$. Therefore, the Taylor series of $f(x) = e^x$ around the point $a = 0$ is given by:

  $ f(x) approx 1 + x + (x^2)/(2!) + dots + (x^n)/(n!) $

  We can actually write this as an infinite sum:

  $ e^x = sum_(n=0)^infinity (x^n) / (n!) $

  If we now want an approximation of $e^x$ at a point $x = 1$, which will give us a value that is close to $e$, we can truncate the series to a finite number of terms. For example, if we truncate the series to the first three terms, we get:
  $ e^1 approx 1 + 1 + (1^2)/(2!) + (1^3)/(3!) = 1 + 1 + 0.5 + 0.1667 = 2.6667 $ 

  When we add an extra term, we get a more accurate approximation:

  $ e^1 approx 1 + 1 + (1^2)/(2!) + (1^3)/(3!) + (1^4)/(4!) = 2.6667 + 0.0417 = 2.7083 $
  ],
  title: "Example",
)

= Biochemical Reactions

#set align(center)
#quote(block: true, attribution: [The Cheshire Cat (Alice in Wonderland)])[
  #text(size: 13pt)[_"If you don't know where you want to go, then it doesn't matter which path you take."_]
]
#v(2em)
#set align(left)

As we are studying systems #emph[biology], the models that we create and use are mainly based on the (bio)chemical reactions that occur in our bodies. In order to make a model of these processes, it is important to understand the foundations of how these chemical reactions can be represented mathematically. In this chapter, we will introduce and explain the simplest kinetic theory that is used to model chemical reactions. We will also discuss the limitations and assumptions of this theory, which are important to know, as assumptions are inevitable in modelling, but posing the wrong assumptions may result in your model becoming invalid. 

== Graph Representation of Biochemical Reactions
In modelling of metabolic pathways, graphs are often used to represent the large metabolic networks in various organisms. They have been extensively used to study the structural properties of metabolic regulation. A graph in mathematics is a collection of _nodes_ (also called vertices) and _edges_ (also called links) connecting pairs of nodes. Graphs are widely used to represent networks, such as social networks, transport systems, and biological processes. 

A graph $G = (V,E)$ consists of:
- A set $V$ of nodes
- A set $E subset.eq V times V$ of edges, which represent relationships between nodes.#footnote[This notation means that the set $E$ is a subset (symbol $subset.eq$) of the cartesian product (symbol $times$) of the set $V$ with itself. The cartesian product means that this new set contains all ordered pairs $(v_i, v_j)$ where $v_i in V$ and $v_j in V$.]

In graph theory, graphs can be either _directed_, where each edge has an orientation from one node to another, or _undirected_, where an edge represents a connection between two nodes without any directionality. In addition, a graph can be _weighted_, where edges carry numerical weights, or _unweighted_. 

In systems biology and chemical kinetics, a biochemical reaction network is a set of chemical species and reactions among these species. To model this network using a graph, we can choose from different representations. One common and particularly useful representation is a _bipartite_ graph. This is a special type of graph where we have two sets of nodes, which we shall name $S$ for species, and $R$ for reactions, in this case. This graph is bipartite when edges in this graph _only_ connect nodes from different sets. This means that all nodes that connect to a node from set $S$, will be in set $R$ (i.e. species are only connected to reactions and vice versa).

Furthermore, this graph that we build is a _directed_ graph, as a reaction contains substrates that are consumed, and products that are produced. Observe the following chemical reactions:
$
#ce("S1 + S2 ->[R1] S3") \
#ce("S3 ->[R2] S4")
$<reactions-example>

We can construct a reaction graph from these reactions by creating nodes for each species ($S_1 dash S_4$) and each reaction ($R_1, R_2$), and identify the substrates and products of each reaction:

- $S_1$ and $S_2$ are substrates of $R_1$, so we draw an arrow from $S_1$ to $R_1$, and from $S_2$ to $R_1$. 
- $S_3$ is a product of $R_1$, so we draw an arrow from $R_1$ to $S_3$.
- $S_3$ is a substrate of $R_2$, so we draw an arrow from $S_3$ to $R_2$.
- $S_4$ is a product of $R_2$, so we draw an arrow from $R_2$ to $R_4$.

Combining these four steps into the reaction graph will give you something similar to @reaction-network-example, which also clearly shows how this graph is bipartite. We only have connections between species and reactions, and not between two species or two reactions. In other terms, we can say that the node sets $S$ and $R$ are _disjoint_. Furthermore, note that this is a _directed_ graph, as the edges also represent a direction. Either, a species is consumed, indicated by an arrow going from a species to a reaction, or a species is produced, which is noted by an arrow going from a reaction to a species. Besides this representation, there exist other graph representations that are used for different purposes. This specific representation is called the _species-reaction graph_. 

#figure(
  image("images/reaction-graph.svg", width: 30%),
  caption: [An example of a species-reaction graph, of the reaction network, which is a bipartite graph of the reactions in @reactions-example. The reaction nodes are colored gray and the species nodes are colored white. Observe that there are no connections between any two species nodes, or any two reaction nodes, making this graph bipartite.]
)<reaction-network-example>

This species-reaction graph is often very useful to help us in visualizing the connections between species and reactions in a complicated regulatory network. An example of such a complicated set of reactions is the _glycolysis_ pathway, which is an important metabolic pathway where glucose is converted into pyruvate. The pathway consists of a set of 10 chemical reactions. We can write these reactions as follows:

1. #ce("Glucose + ATP -> G 6P + ADP")
2. #ce("G 6P -> F 6P")
3. #ce("F 6P + ATP -> F 1\,6BP + ADP")
4. #ce("F 1\,6BP -> DHAP + GAP")
5. #ce("DHAP -> GAP")
6. #ce("GAP + NAD^+ -> 1\,3BPG + NADH")
7. #ce("1\,3BPG + ADP -> 3PG + ATP")
8. #ce("3PG -> 2PG")
9. #ce("2PG -> PEP + H2O")
10. #ce("PEP + ADP -> Pyruvate + ATP")

Where reactions 6 to 10 occur twice, as two entities of 3-P-Glyceraldehyde (GAP) are produced from one fructose-1,6-biphosphate (F1,6BP). In this instance, also note that we only consider the _forward_ pathway. In practice, most of these reactions can also occur in reverse. The full graph of the forward path of glycolysis is shown in @reaction-network-glycolysis.


#figure(
  image("images/Glycolysis-graph.svg", width: 60%),
  caption: [The species-reaction graph of the forward path of glycolysis. Reactions are numbered as mentioned in the main text. ]
)<reaction-network-glycolysis>

You may see that this representation is not very efficient when you want to investigate large complex networks, such as occur frequently in biology. Luckily, we can turn to an alternative method of representing these networks to ensure we can use them, even if they become extremely large and complex.

=== Matrix Representation of a Species-Reaction Graph
As mentioned in the definition of a graph in the previous section, an edge is an ordered pair $(v_i, v_j)$ between nodes $v_i$ and $v_j$. To efficiently write down all these ordered pairs, we can construct a matrix of size $|V| times |V|$, where entry $(i,j)$ depicts whether the pair $(v_i, v_j)$ is an edge in the graph. In an undirected graph, this matrix will be symmetric, as in these graphs, if $(v_i, v_j)$ exists, $(v_j, v_i)$ will also exist in this graph. In a directed graph, we will denote entry $(i,j)$ as an edge from $v_i$ towards $v_j$. 

#info_box(
  body: [For a directed graph, there exists no formal convention about whether the entry $(i,j)$ in the adjacency matrix depicts an edge from $v_i$ to $v_j$ or an edge from $v_j$ to $v_i$. In these lecture notes, and in the course, we will select the former convention for consistency.]
)

#pagebreak()

Let's make this a bit more concrete by looking at the graph in @reaction-network-example. We have a total of 6 nodes, giving us a $6 times 6$ matrix representation. We have added the reaction and species indicators for clarity here.

$ bold(M) = mat(augment: #(hline: 1, vline: 1, stroke: (dash: "dashed")),
"-", S_1, S_2, S_3, S_4, R_1, R_2;
S_1, 0, 0, 0, 0, 1, 0;
S_2, 0, 0, 0, 0, 1, 0;
S_3, 0, 0, 0, 0, 0, 1;
S_4, 0, 0, 0, 0, 0, 0;
R_1, 0, 0, 1, 0, 0, 0;
R_2, 0, 0, 0, 1, 0, 0;) $<mat-m-nostoich>

This matrix representation of connections between nodes is called the _Adjacency Matrix_, as it represents which nodes are adjacent to each other. 

== Stoichiometry
A common and useful property that is assigned to edges in biochemical network graphs is stoichiometry. In this way, the amount of molecules consumed and produced is included as information within the graph. Using this resulting directed graph with stoichiometric edge properties, we can construct the stoichiometric matrix. Up till now, we have not considered stoichiometric coefficients in biochemical reactions. However, say we have the reactions:

$
#ce("2S1 <=>[R1][R2] S2") \
#ce("S2 ->[R3] S3")
$<reactions-stoich>

We now — for example — have a dimerization of species $S_1$ into $S_2$, and a subsequent conversion of $S_2$ into $S_3$. Furthermore, $S_2$ can also split back into two $S_1$. We can also represent this as an adjacency matrix, where we include the stoichiometric coefficients:

$ bold(M) = mat(augment: #(hline: 1, vline: 1, stroke: (dash: "dashed")),
"-", S_1, S_2, S_3, R_1, R_2, R_3;
S_1, 0, 0, 0, 2, 0, 0;
S_2, 0, 0, 0, 0, 1, 1;
S_3, 0, 0, 0, 0, 0, 0;
R_1, 0, 1, 0, 0, 0, 0;
R_2, 2, 0, 0, 0, 0, 0;
R_3, 0, 0, 1, 0, 0, 0;) $<mat-m-stoich>

In summary, we have now obtained three ways of visualizing chemical reaction networks:
1. Using chemical reaction notation
2. By drawing reaction network graphs
3. By writing out the adjacency matrix $bold(M)$

Each of these three will be used throughout the lecture notes. Sometimes, one of them may be more useful but you should remember that they each amount to the same underlying concept. We will now consider another matrix; the _Stoichiometry matrix_. It is important to prevent confusion with the _Adjacency matrix_, as both contain stoichiometric coefficients. However, the stoichiometry matrix is not necessarily square. In fact, it is _only_ square if the number of reactions in a system is equal to the number of unique species in a system. 

To construct the stoichiometry matrix systematically, we first need to consider the adjacency matrix. We have constructed the adjacency matrices before in a specific way to simplify construction of the stoichiometric matrix. Observe from @mat-m-nostoich and @mat-m-stoich that we have started labelling our rows and columns with species, and finished with reactions. As this is a bipartite graph, the upper left and lower right blocks are all zero, as species are not directly connected to each other, and reactions are not directly connected to each other. In this way of constructing $bold(M)$, the lower left block represents the _Product matrix_ or $bold(B)$, and the upper right block represents the _Substrate matrix_, or $bold(A)$.

$ bold(B) = mat(augment: #(hline: 1, vline: 1, stroke: (dash: "dashed")),
"-", S_1, S_2, S_3;
R_1, 0, 1, 0;
R_2, 2, 0, 0;
R_3, 0, 0, 1;) $<mat-b>

$ bold(A) = mat(augment: #(hline: 1, vline: 1, stroke: (dash: "dashed")),
"-", R_1, R_2, R_3;
S_1, 2, 0, 0;
S_2, 0, 1, 1;
S_3, 0, 0, 0;) $<mat-a>

As clearly can be seen, @mat-a for example shows that $S_2$ is consumed by reactions $R_2$ and $R_3$, and @mat-b shows that reaction $R_2$ produces 2 of $S_1$. The stoichiometry matrix $bold(N)$ is then constructed from $bold(A)$ and $bold(B)$ using:

$ bold(N) = (bold(B)^T-bold(A)) $

Or equivalently; the matrix transpose of the _production_ minus the _consumption_. In this case:

$ bold(N) = mat(augment: #(hline: 1, vline: 1, stroke: (dash: "dashed")),
"-", S_1, S_2, S_3;
R_1, 0, 1, 0;
R_2, 2, 0, 0;
R_3, 0, 0, 1;)^T - mat(augment: #(hline: 1, vline: 1, stroke: (dash: "dashed")),
"-", R_1, R_2, R_3;
S_1, 2, 0, 0;
S_2, 0, 1, 1;
S_3, 0, 0, 0;) = mat(augment: #(hline: 1, vline: 1, stroke: (dash: "dashed")),
"-", R_1, R_2, R_3;
S_1, -2, 2, 0;
S_2, 1, -1, -1;
S_3, 0, 0, 1;) $

This stoichiometry matrix tells us in which reaction each species is produced and consumed. This is a useful construct, as we can now also describe the rate of change of each species using this stoichiometric matrix.

Given that the _rates_ of each reaction are collected in a vector $bold(v)$, we can describe the rate of change of each species as:

$ (upright(d)bold(x)(t))/(upright(d)t) = bold(N) dot bold(v)(t) $<reactionrate>

How to construct and define this vector $bold(v)(t)$ will be treated later in these lecture notes. For now, it is important to know that this rate vector describes _how fast_ each reaction is occurring. Using these definitions, we can now analyze our biochemical networks for useful features. 

== Conservation Laws
Biochemical reaction networks describe the interactions between chemical species such as metabolites, proteins, and enzymes. Before we turn to actually modelling these systems over time, we will first consider conservation laws within these networks. While dynamic models are often complex, they are often governed by fundamental physical and biological constraints.

Conservation laws express the principle that certain quantities remain unchanged over time. In the context of biochemical systems, these laws often correspond to the conservation of mass, atoms, or specific molecular groups (e.g., total amount of a cofactor or enzyme). Recognizing and utilizing conservation laws not only enhances our understanding of biological systems but also plays a critical role in further analysis of the models that we will be building. 

A _conservation law_ is a constraint on the system that ensures a particular linear combination of species concentrations remains constant over time, regardless of the dynamics of the system.

Mathematically, we can say that we have a vector of concentrations of species at a point in time $t$, that we label as $bold(x)(t)$. Then, a conservation law typically has the form:

$ bold(c)^T bold(x)(t) = "constant" forall t >= 0 $<conservationlaw>

Where $bold(c)$ is a constant vector. We can also say that a linear combination of entries in $bold(x)(t)$ as defined by $bold(c)$ is _invariant_ under the dynamics of this system.#footnote[The symbol $forall$ means "for all"]

Now, we want to find these conservation laws. As per @conservationlaw, a constant quantity means that its _derivative_ is zero, so we can write out the derivative of $bold(c)^T bold(x)(t)$:

$ upright(d) / (upright(d)t) (bold(c)^T bold(x)(t)) = bold(c)^T (upright(d)bold(x)(t))/(upright(d)t) = 0 $

As $bold(c)^T$ does not depend on time. From @reactionrate, we can replace the derivative of $bold(x)(t)$:

$ bold(c)^T (upright(d)bold(x)(t))/(upright(d)t) = bold(c)^T bold(N) dot bold(v)(t) = 0 $

A trivial solution to this equation is if the reaction rates $bold(v)(t)$ are all zero. However, this is usually not the case, and while $bold(N)$ is typically nonzero, the other solution is that $bold(c)^T bold(N) = 0$. This actually gives us a very useful result.

In order to find a conservation law, we need to find a vector $bold(c)$ such that $bold(c)^T bold(N) = 0$. From linear algebra, we know the solution to this equation lies in the _left nullspace_ of $bold(N)$. Consequently, each _independent_ row of the left nullspace of $bold(N)$ defines a conservation law for a chemical reaction system.

This may be a bit on the technical side, so let's have a nice simple example to illustrate this.

#pagebreak()

#example_box(
  body: [
    Consider the reversible reaction:

    $ #ce("A + B <=> C") $

    We can define the stoichiometry matrix $bold(N)$:

    $ bold(N) = mat(
      -1, 1;
      -1, 1;
      1, -1;) $
    
    We can solve $bold(N)^T bold(c) = 0$ to find the nullspace. We get:

    $ mat(
     -1,-1,1;
     1,1,-1;) dot mat(c_1;c_2;c_3) = mat(0;0) $

     Which reveals the only constraint: $c_1 + c_2 = c_3$.

     The solution therefore is:
     $ mat(c_1; c_2; c_1 + c_2) = c_1 mat(1;0;1) + c_2 mat(0;1;1) $

     Which is spanned by the vectors $mat(1;0;1)$ and $mat(0;1;1)$, defining two independent conservation laws from @conservationlaw:

     1. $[A] + [C] = "constant"$
     2. $[B] + [C] = "constant"$

     Which represent the conservation of mass in the original chemical reaction. When $A$ goes down, $C$ has to go up (law 1), and when $C$ goes up, then $B$ goes down (law 2).  
  ]
)

So now, independent of the rate vector, which will be extensively discussed later, we are able to derive conservation laws for complex biochemical reaction systems. In practice, we will also be able to derive the nullspace of $bold(N)$ using computational tools from Python, or Matlab. 

== Dynamic Equilibrium States
In the previous section, we analyzed conservation laws by examining the left nullspace of the stoichiometric matrix $bold(N)$. This allowed us to identify quantities that remain constant over time due to the structure of the reaction network. In this way, we can identify mass balances or conserved moieties in a complex network of chemical reactions. 

Now, we shift our focus to the _right nullspace_ of $bold(N)$, which is found by setting $bold(N) bold(v) = 0$. Instead of structurally conserved properties, this space encodes possible steady-state flux distributions. In simple terms, this will help us find patterns in reaction rates that result in no net change in species concentrations. These flux patterns represent how a network can operate while remaining in a dynamic steady state. 

To clarify this, our goal is now to find a vector $bold(v)$, which is the distribution of _fluxes_, or flow of species from one to another, where we have no net change in species concentrations. We call these steady-states dynamic, as species will change into each other, but the concentration of each species does not change. In literature, you may also find that the notation $"ker"(bold(N))$ is used to represent the right nullspace of $bold(N)$.

#example_box(
  body: [
    Consider the following linear irreversible chain of reactions:

    $ #ce("A->[v1]B->[v2]C") $

    We have a stoichiometric matrix:

    $ bold(N) = mat(
      -1, 0;
      1, -1;
      0, 1;) $

    This network has 3 species: $A$, $B$, and $C$, and two reactions. These reactions occur with rates determined by a rate vector $v = (v_1,v_2)^T$. Then, we will have according to @reactionrate, the following formula for our rate of change of each species:

    $ (upright(d)bold(x)(t))/(upright(d)t) = bold(N) dot bold(v)(t) = mat(
      -1, 0;
      1, -1;
      0, 1;) mat(
      v_1;
      v_2;) = mat(
      -v_1;
      v_1 - v_2;
      v_2) $

    Then setting $bold(N) dot bold(v)(t)=0$ gives:
    $ -v_1 = 0 \
    v_1 = v_2 = 0 $

    So the only solution is the vector $bold(v) = arrow(0)$, so no _nonzero_ steady state flux exists in this system. This means that the system cannot maintain an internal flux without input or output connections. This highlights that pathways typically require either cycles or external coupling.
  ],
  breakable: true
)

We see that the system in the example cannot sustain itself, without any external inputs. This is what usually happens in linear pathways, where there are no cyclic dependencies between species. 

We can also see what happens if we have a cycle. For this, we will slightly modify the system from the example:

$ #ce("A->[v1]B->[v2]C->[v3]A") $<cycle-system>
This is a cycle, of which we can define $bold(N)$:

$ bold(N) = mat(
  -1, 0, 1;
  1, -1, 0;
  0, 1, -1;) $<stoich-mat-cycle>

Using our right nullspace formula, we get:

    $ (upright(d)bold(x)(t))/(upright(d)t) = bold(N) dot bold(v)(t) = mat(
      -1, 0, 1;
      1, -1, 0;
      0, 1, -1;) mat(
      v_1;
      v_2;
      v_3;) = mat(
      -v_1+v_3;
      v_1 - v_2;
      v_2-v_3;) = arrow(0) $<solve-dynamic-equilibrium-cycle>
    
This gives us a simple result of $v_1 = v_2 = v_3$, meaning that the three states will be in a dynamic equilibrium where all rates are equally large. 

Of course, in these simple examples, we can often also derive these properties from just inspecting the equations. However, this approach does not scale very well and will quickly become a daunting task when faced with massive biological networks. Instead, approaching these properties systematically using linear algebra makes them scalable, and allows us to use the computer to find properties quickly in large systems of biochemical reactions.
#figure(
  image("images/dynamic_equilibrium.svg", width: 80%),
  caption: [Simulation of the system in @cycle-system, showing the occurrence of a dynamic equilibrium where the concentrations of each species remain unchanged under nonzero reaction flux. *A*: Concentration-time profiles showing the dynamic equilibrium state at the end. *B*: Flux-time profile showing all reaction fluxes are equal when the dynamic equilibrium is reached, as found in @solve-dynamic-equilibrium-cycle.]
)<dynamic-equilibrium>

It is also very important to notice that while the reaction rates are equivalent, they are _not necessarily zero_, which means that in a dynamic equilibrium, reactions do occur, but their reaction rates are such that the _concentrations_ of each state do not change, hence the term 'equilibrium'. This is well-illustrated in @dynamic-equilibrium, where you can see that the species in the system remain constant, while the fluxes are equal, but nonzero. 

== Fundamental Chemical Reaction Network Theory
In this final section on chemical reaction networks, we will take a small look into chemical reaction network theory (CRNT). This branch of mathematical chemistry focuses on analysis of chemical reaction networks to derive specific shared properties between networks. For a complete overview of this topic, please consult the book 'Foundations of Chemical Reaction Network Theory' by Martin Feinberg @feinberg_foundations_2019. In this section, we will only discuss some foundational topics.

=== Complexes and Connectivity
In the networks that we have encountered before, we defined species nodes, and reaction nodes. In CRNT, we have another graph that we can define, but this requires some additional definition. Given a set of chemical species $cal(S) = {X_1, X_2,dots,X_n}$, we can define a _complex_ as any linear combination of species with nonnegative integer coefficients, appearing as either a reactant or product in some reaction. Examples of complexes are $A + B$ and $2B + C$. The set of all distinct complexes is denoted as $cal(C)$ and the number of complexes in a system is denoted as $|cal(C)|$.

The previously defined graph of a reaction network is called the _species-reaction graph_, where each species and each reaction have their own nodes. Right now, we will add the _reaction graph_ as a possible way of viewing a reaction network. A reaction graph contains complexes as nodes, and uses directed edges as reactions that connect the nodes. For example, for the system shown in @reaction-network-example, we can construct the reaction graph as shown in @reaction-graph-crnt.

#figure(
  image("images/reaction-graph-crnt.svg", width: 30%),
  caption: [Reaction graph of the system in @reaction-network-example. The species $S_1$ and $S_2$ form a complex together, while $S_3$ and $S_4$ are separate complexes. The reactions are indicated by the edges in this graph.]
)<reaction-graph-crnt>

Another definition that we need is the notion of _connectedness_. In an undirected graph, two nodes are connected if there exists a path between them, possibly through other nodes. In a directed graph, we can make the distinction between _weak_, _unilateral_, and _strong_ connectivity:
- Two nodes are weakly connected, if there exists a path between them if we would ignore directionality in the edges,
- they are unilaterally connected, if there exists a path between two nodes in one direction, and
- they are strongly connected, if there exists a path between two nodes in both directions.

Examples of these types of connectedness can be seen in @connectedness. While we can say about two nodes whether they are connected, we can also describe entire graphs in this way. This is done in a similar fashion to describing two nodes. For example, an entire graph is strongly connected if and only if all pairs of nodes in this graph are strongly connected. 

Usually, not the entire graph is strongly connected, but we may also split the graph into components by connectivity. We will use this connectivity property to define linkage classes in the next subsection.

#figure(
  image("images/connectedness.svg", width: 80%),
  caption: [Different types of connectedness in directed graphs. *A*: Nodes I and III are weakly connected. *B*: Nodes I and III are unilaterally connected. *C*: Nodes I and III are strongly connected.]
)<connectedness>

=== Linkage Classes
In a chemical reaction graph, a linkage class is a single _weakly connected component_. Thus, if two nodes in the graph are weakly connected, they are in the same linkage class. While the species-reaction graphs in the previous parts are almost always entirely weakly connected, the reaction graphs may not be, because of the use of complexes instead of individual species. We will define the number of linkage classes as $cal(l)$.

=== Deficiency
Now that we now about complexes and linkage classes, we can compute the deficiency of a reaction network. Given a reaction graph, the deficiency of the network, labeled $delta$ is given by:
$ delta = |cal(C)| - cal(l) - "rank"(bold(N)) $

In this equation, the rank of the stoichiometric matrix is given by the number of linearly independent columns in the stoichiometric matrix. Intuitively, the deficiency of a chemical reaction network measures the "extra" structural complexity of the network that is not already captured merely by counting the subnetworks (linkage classes) or dynamical degrees of freedom (rank of $bold(N)$). The deficiency especially quantifies the steady-states of a network.

An example of a network with deficiency zero is

$ #ce("A <=> B") $

- We have two complexes, $A$ and $B$, so $|cal(C)| = 2$
- We have 1 linkage class, since both complexes are connected
- The stoichiometric matrix is $bold(N) = mat(-1, 1;1, -1)$, which has rank $1$, as the two columns are not independent.#footnote[The two columns are not independent here, because the second column is a linear transformation of the first. This can be seen quickly as $c_2 = -c_1$.] 

We can then compute $delta = 2 - 1 - 1 = 0$. 

=== Reversibility
Besides connectivity in reaction networks, a related property is _reversibility_. A chemical reaction network is said to be reversible if an edge between two complexes in one direction, implies that there is also an edge between those complexes in the reverse direction. While many reactions in biological networks are reversible individually, not all of them are. Full reversibility is therefore not all that common in the analysis of metabolic networks. 

In addition to complete reversibility, we can also label a network as _weakly reversible_. A network is weakly reversible if the existence of a single path from one complex $i$ to a complex $j$, also implies that there is a path back from complex $j$ to complex $i$, but not necessarily in the same reaction.

This is a weaker definition because in complete reversibility, all edges are bidirectional, while in weak reversibility, not all edges need to be bidirectional, as there need only exist paths in both directions. It also follows from this definition that any completely reversible network is also always weakly reversible. 

In @connectedness, only network C is weakly reversible, as in network A, there is no path from I to II, or from I to III, and in network B, there is no path from III to II., and from III to I. We can slightly modify network B, though, to make it weakly reversible. In @weakly-reversible, we can see that the addition of a single edge from III to I, makes this network weakly reversible, because we can reach any node, independent from where we start. None of the networks in @connectedness and @weakly-reversible are completely reversible, as that would require bidirectional arrows between each pair of nodes.

#figure(
  image("images/weakly-reversible.svg", width: 25%),
  caption: [A modification of network B in @connectedness that makes this network weakly reversible, but not completely reversible. As there exists a path between every pair of nodes, we can say that this network is weakly reversible.]
)<weakly-reversible>

=== The Deficiency Zero Theorem
We now have enough information to dive into the _deficiency zero theorem_. This theorem is an important result from chemical reaction network theory, together with the _deficiency one theorem_. However, the latter is slightly more complicated, and we will therefore not deal with that one here. 

The deficiency zero theorem states that:
#quote[If a chemical reaction network is both weakly reversible, and has a deficiency of zero, any mass-action system derived from this network is complex balanced.]

The term _complex balanced_ refers to several properties of the system. First of all, a complex balanced steady-state means that the total rate of reactions going out of a complex equals the total rate of reactions coming in to it.

Furthermore, if a network is complex balanced, all steady states of this reaction network are complex balanced, the system has at least one steady state for each combination of reactants that is possible within the limits of conservation of mass, and all initial values will converge to this steady state. Next to that, if a system in such a steady state is perturbed, the system will return back to this steady state. 

This is a powerful result, because for some systems, we can now prove the existence of a steady-state, just from the _structure_ of the chemical reaction network, without even knowing any of the rates and the concentrations of the molecules in the system.

== Mass-Action Kinetics
While we now have looked at networks without regarding the actual values of the reaction rates, we now will turn to a common method of deriving the reaction rates, which is necessary if we want to simulate the reaction networks. As already discussed earlier, the differential equation for a system of reactions is given by:

$ (upright(d)bold(x)(t))/(upright(d)t) = bold(N) dot bold(v)(t) $

Which depicts that the rate of change of a species at time $t$ is proportional to the stoichiometry and the reaction rate $bold(v)(t)$. However, to simulate this system, we need to have a proper description of this reaction rate vector. The full derivation is way beyond the scope of these lecture notes, and may be covered in a more advanced thermodynamics course.

The basis for a reaction rate lies in an observed log-linear relationship between reaction rate and inverse temperature. So, in a reaction with the same initial concentrations and molecules, the natural logarithm of the reaction rate was proportional to the inverse teperature $1/T$. This resulted in the Arrhenius equation @laidler_development_1984 for the reaction rate constant, called $k$:

$ ln(k) = ln(A)- E_a / (R T) $<arrhenius>

Of course, this does not take into account the concentrations of substrate, which also influence the total reaction rate $bold(v)$. In mass-action kinetics, the total reaction rate is proportional to the product of each unique substrate, raised to the power of its stoichiometric coefficient. This result comes from the probability of molecular collision occuring within a volume being proportional to this quantity.

In case we have a reaction:

$ sum_i nu_(i j)S_i arrow.long "products" $<reaction>

The probability of collision of reaction $j$ ($P_j$) within a volume obeys the behavior:

$ P_j prop product_i c_i^(nu_(i j)) $

Therefore, the mass-action rate law is given by

$ bold(v)_j = k_j product_i c_i^(nu_(i j)) $<mass-action>

Or in words: for a reaction $j$, with rate constant $k_j$, the reaction rate is equal to the rate constant multiplied by all substrate concentrations, exponentiated to their stoichiometric coefficients ($nu_(i j)$).#footnote[The full derivation of mass action kinetics is way beyond the scope of these lecture notes. However, the formula can be made somewhat intuitive by viewing the second part as quantifying the rate of correct collisions happening for the reaction to be able to occur, while the rate constant quantifies both the temperature dependence of the collisions happening (i.e. a higher temperature results in faster movement of molecules and thus more collisions), as well as correcting for the fact that not all collisions have sufficient energy to make the reaction happen. ] Using this information, we can now also define _dynamic_ behavior of chemical reactions, assuming mass action kinetics. 

Take for example the system in @cycle-system. In this system, we have three reaction rates: $v_1$, $v_2$, and $v_3$, for the conversion of A to B, B to C, and C to A, respectively. According to mass action kinetics, the rates have the values:

$ v_1 = k_1 [A] \ v_2 = k_2 [B] \ v_3 = k_3 [C] $<rates-cycle-system>

Using these rates, the stoichiometric matrix of the system (@stoich-mat-cycle) and the rate equation (@reactionrate), we can build the dynamic model of the system:

$ upright(d) / (upright(d)t) mat([A]; [B]; [C]) = bold(N) dot bold(v) = mat(
  -1, 0, 1;
  1, -1, 0;
  0, 1, -1;) dot vec(k_1 [A], k_2 [B], k_3 [C] ) = mat(k_3 [C] - k_1 [A]; k_1 [A] - k_2 [B]; k_2 [B] - k_3 [C]) $

For some parameters $k_1$, $k_2$, and $k_3$, we can now simulate the system, which is also what was done in @dynamic-equilibrium. In the example below, we illustrate the derivation of the reaction rates for several reactions.

#example_box(body: [
  1. For the reaction $ A limits(-->)^k B $ we get the reaction rate $v = k[A]$
 
  2. For the reaction $ A + B limits(-->)^k C $ we get the reaction rate $v = k[A][B]$

  3. For the reaction $ emptyset limits(-->)^k A $ we get the reaction rate $v = k$, as we have no substrates.
  
  4. For the reaction $ #ce("2A -> B") $ we get the reaction rate $v = k[A]^2$]
)<example-reaction-rates>

The #emph[order] of a reaction can be determined by how many species have to be multiplied. For example, the first reaction from the example above is a #emph[first order] reaction, and third reaction from that example is a #emph[zeroth order] reaction. The second and fourth reactions are #emph[second order] reactions because in the second reaction we multiply $A$ and $B$, and in the fourth we multiply $A$ and $A$. @reaction-orders shows the reaction rates for different reaction orders, with a rate constant of $k = 0.1$. We see that lower order reactions typically have higher reaction rates for substrate concentrations below 1, while higher order reactions have higher reaction rates above substrate concentrations of 1. 

#figure(
  image("images/reaction_orders.svg", width: 50%),
  caption: [Reaction rates for different reaction orders with $k=0.1$, for variable substrate concentrations.]
)<reaction-orders>

Finally, we need to discuss the units of the rate constants in the reactions. As the molecules usually have units of concentration, such as $["mmol L"^(-1)]$, so the time derivatives have units of concentration per unit time, such as $["mmol L"^(-1) " min"^(-1)]$. To find the units of the rate constants, we need to make sure that the units on both sides of the differential equation are the same. For example, assume $A$ has the unit of $["mmol L"^(-1)]$ and time is in $"min"$. Then, in the simple differential equation:
$ ddt(A) = -k_A A $
we can find the unit of $k_A$ by setting
$ ["mmol L"^(-1) " min"^(-1)] hat(=) [?] dot ["mmol L"^(-1)] $

So we find out that $k_A$ has the unit of $["min"^(-1)]$. However, this unit can change depending on the reaction order. Later on, we may also encounter other parameters with different units. In the second order reaction

$ #ce("2B ->[k] A ->[k0] ") $

We have for $A$: 

$ ddt(A) = k [B]^2 - k_0 [A] $

Here, $k$ has the unit $["L mmol"^(-1)" min"^(-1)]$, while $k_0$ has the unit $["min"^(-1)]$.

#pagebreak()

== Assumptions of Mass-Action Kinetics
Mass-action kinetics is of course also a model of reality, which is subject to specific assumptions. The main assumption that mass-action kinetics makes is that our reaction occurs in a homogeneous, well-mixed system. This means that we assume that within the volume the reaction occurs in, our concentration is the same everywhere, and the probability of two particles interacting is the same, regardless of the type of particle. 

First of all, in extremely low concentrations, the assumption of a homogeneous distribution of reactants may not hold. In these situations, we need to take into account the randomness of chemical reactions occurring, which can be done using more advanced methods. If we keep the assumption of well-mixedness, we can resort to so-called "stochastic" simulations, popularized for chemical kinetics by Daniel Gillespie. @gillespie_stochastic_2007 These simulations rely on absolute numbers of particles, instead of concentrations, and make use of randomness to account for the uncertainty in these situations. The details of stochastic simulation are beyond the scope of these lecture notes, but interested readers may consult the introduction by Erban, Chapman and Maini @erban_practical_2007 for an accessible introduction to the Gillespie algorithm for stochastic modelling of chemical reactions. 

In cases where mixing is non-homogeneous, we also need an additional model component. To obtain realistic models of chemical reactions in these systems, we need to take into account the spatial distribution of particles, which can be done using "reaction-diffusion equations". @schoneberg_simulation_2014 As with the stochastic simulations, the details of these equations are beyond the scope of these lecture notes.

While these two phenomena occur frequently in biological systems, the mass-action assumptions can often still result in relatively realistic models that can tell us more about the function of biological regulation. Furthermore, in specific cases, mass action kinetics may be modified slightly to match the knowledge of the underlying system. Techniques and examples of modifications of mass-action kinetics will be discussed in more detail in @modelling-bio-systems. By using these techniques, we can keep models simple while still providing an accurate description of the biological system of interest. 

#pagebreak()

== Steady-States
Now that we can formulate differential equations for chemical reactions, we can also derive additional interesting properties from these differential equations. When we have a dynamic model defined by:
$ 
ddt(x) = f(x)
$

The steady state is given by $f(x) = 0$, which means that the value of $x$ does not change over time anymore. Consider the system defined in @stoich-mat-cycle. We have previously found out that in case $v_1 = v_2 = v_3$, we have a steady-state with nonzero fluxes (see @solve-dynamic-equilibrium-cycle). Using mass-action kinetics, we have defined these rates in @rates-cycle-system. In steady-state, defining steady-state concentrations $A_s$, $B_s$, and $C_s$, we now know that:

$ k_1 A_s = k_2 B_s = k_3 C_s $

Using conservation of mass, we have $A + B + C = T_0$, and we can derive $A_s$, $B_s$ and $C_s$ to be:

$ A_s = T_0 dot (k_2 k_3) / (k_1 k_3 + k_2 k_3 + k_1 k_2) $<steadystate-a>

$ B_s = (k_1) / (k_2) A_s $<steadystate-b>

$ C_s = T_0 - A_s - B_s $<steadystate-c>

Some more complex systems may also allow for #emph[multiple] steady-states. A system with two steady-states is also called #emph[bistable]. In biological systems, this property of bistability is important in understanding specific disease mechanisms. An example of a differential equation that shows bistable behavior is

$ ddt(y) = p + y^5 / (1 + y^5) - y $

#figure(image("images/bifurcation.svg", width: 60%), caption: [The steady-states in a bistable system. For $p < 0.48$ and $p > 0.56$, we have only one steady state, characterized by the lower and upper stable branches, respectively. For $p$ in between these values, we have two possibilities for our steady state. Going from one to two steady-states is called a bifurcation.])<fig-bistable>

The steady states of this system depending on parameter value $p$ are shown in @fig-bistable. The point where the steady-state splits based on initial condition is called a #emph[bifurcation point], as over there, the steady-state splits into two possibilities based on the initial condition. In @fig-bistable, we have two bifurcation points, as between $p approx 0.48$ and $p approx 0.56$, we have two possible steady states that $y$ may take, while below and above these values, there is only one steady state. 

== Exercises

#question[For the graphs in @connectedness, write down the adjacency matrix.]

#question[Given is the following reaction system.]

$
    &#ce("A + C -> 2B") \
    &#ce("D + B -> C + E")  \
    &#ce("3E <=> F") \
    &#ce("A + F -> G") \
$

#subquestion[Draw the species-reaction graph of the following reaction system. Indicate stoichiometric coefficients at each edge.]

#subquestion[Derive the stoichiometric matrix of the system.]

#subquestion[Derive the conservation laws for the system.]

#subquestion[Does the system allow for any dynamic equilibrium states? Explain your answer.]

#question[Given is the system below:]
$
    &#ce("A + B <=> C") \
    &#ce("C -> D + E")  \
    &#ce("D + E <=> F") \
    &#ce("2A <=> B + G") \
    &#ce("B + G <=> H") \
    &#ce("H -> 2A") \
$

#subquestion[Draw the reaction graph (using complexes) of the system.]
#subquestion[How many linkage classes does the system have?]
#subquestion[Compute the deficiency of the reaction network. Comment on the reversibility of the reaction network. Does it satisfy the conditions for the deficiency zero theorem?]

#pagebreak()

#question[Comment on the reversibility of the reaction network below.]

$
    &#ce("A <=> B") \
    &#ce("A + C <=> D")  \
    &#ce("D <=> B + E") \
    &#ce("B + E <=> A + C") \
$

#question[Given is the following reaction system, including rate parameters.]

$
    &#ce("A <=>[k1][k2] B") \
    &#ce("A + C <=>[k3][k4] D")  \
    &#ce("D ->[k5] B + E") \
    &#ce("B + E ->[k6] A + C") \
$

#subquestion[Comment on the reversibility of this system.]
#subquestion[Derive the differential equations for the reaction network. Use mass-action kinetics.]
#subquestion[Give the order of each of the reactions.]
#subquestion[Molecules are in $"mmol L"^(-1)$ and time is in $"min"$. Give the units of each rate constant.]

#question[For the system in @stoich-mat-cycle, the formulae for the steady-state values for A, B, and C were given in @steadystate-a, @steadystate-b, and @steadystate-c, respectively. Give the derivation of these equations for this system.]

*Exam level question*

#question[A mass-action kinetics model for c-peptide in humans is given by]
$ ddt(C^"pl" (t)) &= -(k_0 + k_2)C^"pl" (t) + k_1 C^"int" (t) + "Production"(t)\
ddt(C^"int" (t)) &= k_2 C^"pl" (t) - k_1 C^"int" (t) $

At $t = 0$, $C^"pl" (t = 0) = C_b$ and both equations are in steady state.

#subquestion[Concentrations are in $["mmol L"^(-1)]$ and time is in $"min"$. Derive the units for the rate parameters $k_0, k_1, k_2$.]

#subquestion[Express $"Production"(t = 0)$ using only model parameters ($k_0, k_1, k_2$) and $C_b$.]

= From Biology to Equations

#set align(center)
#quote(block: true, attribution: [Remi (Ratatouille)])[
  #text(size: 13pt)[_"The only thing predictable about life is its unpredictability."_]
]
#v(2em)
#set align(left)

== Translating Biological Processes into Mathematical Equations
In the previous section, we mainly looked at biochemical reactions, and while the processes in the human body are in principle chemical reactions, modelling every reaction in a process will quickly lead to unworkably large models. Therefore, modelled processes are often groups of chemical reactions that occur rapidly in sequence, and are therefore lumped together and modelled as a single equation. In other situations, the goal of the model may simply not warrant a detailed reaction-level view of a specific process, and the inclusion of a generic production or consumption term suffices.

In order to build these models ourselves, and to understand other models, we need to have an understanding of how biological processes are translated in general into mathematical models, and how these equations represent specific properties of a process. The first step into going from a biological system to a set of equations, it to decide on the scope and use of the model. In particular, we need to know:

- What is the system of phenomenon of interest?
- What is the purpose of the model?
- What level of detail is appropriate for this phenomenon and purpose?

Suppose we wish to model the insulin secretion in response to glucose in the pancreas, we could model the entire pancreas and all of the hormones it secretes, or we could focus more on the individual $beta$-cells and model the internal signalling pathway, or we could only model the glucose-stimulated insulin release as a single input-output process. If the purpose of the model is to understand $beta$-cell damage in type 2 diabetes and its effect on insulin release, we may need to model the detailed cellular signaling pathway of glucose inside the $beta$-cell, but if our goal is to predict insulin release from a glucose input, a simple input-output model may be more appropriate. 

== Key Model Components
After we've decided on a system, purpose, and level of detail, we need to identify the key components in our model, which we can mathematically break down as:
- *State variables*: modelled quantities that change over time, such as concentrations
- *Parameters*: fixed values that define system behavior, such as the rate constants
- *Inputs*: external influences that determine model behavior, such as medicine administration
- *Outputs*: measurable outcomes, such as blood insulin level. It is important to note that these outputs can also be one or more state variables, but this is not strictly the case.

A very simple model of glucose-stimulated insulin secretion can be formulated as:

$ ddt(I(t)) = k_G dot G(t) - k_I dot I(t) $

With state variable $I(t)$, parameters $k_G$ and $k_I$, input $G(t)$ and output $I(t)$. While $G(t)$ changes over time, it is not strictly a state variable, because there is no equation for it. Therefore, we define this as an input. 

It is also important to note that while this equation uses mass-action kinetics, the glucose is not strictly _converted_ into insulin, as we know from biology. In biological models, mass-action kinetics is more often used as a technique to model processes, than to represent chemical reactions directly. 

Another simple system that illustrates this concept is the so-called _Predator-Prey_ or _Lotka-Volterra_ model. The model is a simplification of population sizes of a predator (e.g. a fox) and a prey (e.g. a rabbit). The equations are simple:

$ ddt(R(t)) &= a R(t) - b R(t) F(t) \
ddt(F(t)) &= c R(t) F(t) - d F(t) $<lv-eq>

Where $R(t)$ represents the number of rabbits at time $t$, and $F(t)$ the number of foxes at time $t$. The parameters $a$-$d$ govern the interactions between these species. $a$ defines the net birth rate of rabbits. As can be seen from the model, more rabbits also means more rabbits being born, as the total birth is $a R(t)$. Parameter $b$ defines the rate of rabbits being eaten by foxes, which in total depends on the availability of rabbits, and the amount of foxes in the population. In principle, rabbits may also die without being eaten by foxes, but that term would then be for example a parameter $a_2$ times the amount of rabbits $R(t)$, so if we say that the birth rate equals $a_1 R(t)$ and the death rate equals $a_2 R(t)$, we get a net birth rate of $(a_1 - a_2) R(t)$. In this model, it is assumed that the birth rate is higher than the basal death rate for rabbits, so this is combined in a positive parameter $a$. 

Similarly, for foxes, their survival depends on rabbits, so their birth rate equals $d_1 F(t) + c R(t) F(t)$, while their death rate equals $d_2 F(t)$. In foxes, the assumption is made that the basal birth rate $d_1$ is lower than the death rate, so we get a negative term $d F(t)$ that combines them, which is compensated if enough rabbits are present to feed the foxes.  

#figure(
  image("images/lotka_volterra.svg"),
  caption: [Model simulation of the lotka-volterra model in @lv-eq. The oscillations of the predator and prey populations are clearly visible in the figure.]
)<lv-model>

Another well-known model is the so-called oral glucose minimal model. @Bergman2021 The model aims to describe in simple terms the plasma glucose levels in a human after an oral glucose tolerance test. This test involves the consumption of 75g of glucose dissolved in water, and is used predominantly in research settings, or to diagnose gestational diabetes. The model consists of two equations:


$ ddt(G(t)) &= - [S_G + X(t)] dot G(t) + S_G dot G_b + "Ra"(t) \
ddt(X(t)) &= - p_2 dot X(t) + p_3 dot [I(t) - I_b] $<ogmm-eq>

The model contains two state variables: $G(t)$, which is plasa glucose, anda $X(t)$ which is labelled "insulin-action", and accounts for a delay in insulin increase and subsequent glucose uptake by the tissues. 

The model has five parameters: $S_G$, $p_2$, $p_3$, $G_b$, and $I_b$. Of those parameters, $G_b$ and $I_b$ are the steady-state or fasting concentrations of glucose and insulin in the blood plasma, which can be calculated from data. The parameter $S_G$ accounts for glucose level control independent of insulin, such as gluconeogenesis and insulin-independent glucose usage by the brain. In the model, this parameter makes sure that with insulin in its steady-state value, the model makes sure glucose is also returned to steady-state. For insulin action, $p_2$ controls the rate of decay of insulin action, and $p_3$ controls the relationship between plasma insulin levels and how active insulin signalling occurs. 

The model contains two inputs: $"Ra"(t)$, which is a function that can describe the rate of glucose appearance after a meal, and the insulin levels in the blood $I(t)$. Specifically, note that the model does not describe terms for insulin production. 

If we look at type 2 diabetes, a typical parameter that may be decreased in this model is parameter $p_3$, as a reduced insulin sensitivity of the tissues means that more insulin will be needed to elicit a similar insulin action. Equivalently, a strongly increased $p_2$ may also show similar behavior as this will cause a rapid dampening of insulin action after its initial peak. 

= Computer Simulations of Differential Equation Models

#set align(center)
#quote(block: true, attribution: [The Chinese Emperor (Mulan)])[
  #text(size: 13pt)[_"The flower that blooms in adversity is the most rare and beautiful of all."_]
]
#v(2em)
#set align(left)

As soon as we have defined the model for our biochemical system using differential equations, we typically also want to calculate the system behavior over time. In specific cases, it is possible to obtain a solution of your differential equation analytically, but in most models, this is typically not possible. For these models, we turn to so-called numerical methods to obtain the solution to differential equations. 

In this course, numerical methods are treated only very briefly, with a focus on application in Python. While many methods exist, we will only look at the most basic numerical method for solving differential equations. 

== Formulating the Initial Value Problem
To be able to get the solution, we have some settings that we need to specify beforehand, so the numerical method can be used. For solving a differential equation, we will need the _initial conditions_ of all the state variables. Another term often encountered in this field is _Initial Value Problem_ or IVP, which reflect the main idea behind numerical solutions to differential equations. Namely, given a set of initial values, calculate the next value in time. Besides the initial values, we need to specify at what value of time to stop computing the next value in time, because otherwise our numerical method will go on indefinitely. 

== Forward Euler Method
Now that we have obtained the initial values and the time at which the numerical solution should end, we can start solving the differential equation. Remember, from a previous part of these lecture notes, that a differential equation with known parameters $p$, typically looks like this:
$ (upright(d) y (t))/(upright(d) t) = f (y, t, p) $

So, if we know the value of $y(t)$ for a specific value $t$, we can directly compute the numerical value of the derivative of $y$ at this same value $t$. As stated before, we have the initial value of $y$. Let's for now assume that we start solving at $t=0$, which means that we have the value for $y(t=0)$, and we can compute the value of the derivative, which is
$ (upright(d) y (t=0))/(upright(d) t) = f(y(t=0), 0, p) $. 

The question now is: how can we use this information about the derivative to compute the next value for $y$ in time, say at a time $Delta t$?

What you may remember from your calculus course, is that we can _approximate_ any function $f(x)$ around a value $x=a$, by using a Taylor polynomial. The Taylor polynomial for such a function looks like:

$ f(x) approx f(a) + (x-a) / 1! dot (upright(d) )/(upright(d) t)(f(a)) + (x-a)^2 / 2! dot (upright(d)^2 )/(upright(d) t^2)(f(a)) + dots + (x-a)^n / n! dot (upright(d)^n )/(upright(d) t^n)(f(a)) $

If we cut this off after the first derivative, we get:

$ f(x) approx f(a) + (x-a) / 1! dot (upright(d) )/(upright(d) t)(f(a))  + cal(O)(2) $

We can use this to get an approximation of the value of our differential equation at $t = Delta t$. We can fill this equation in by using $f(x) = y(Delta t)$, and using $a = 0$, and we get:

$ y(t = Delta t) approx y(t = 0) + Delta t dot (upright(d) )/(upright(d) t)(y(t=0))  + cal(O)(2) $

As we know the value for this derivative is given by the original differential equation, we can _approximate_ the value for $y(t = Delta t)$ by:

$ y(t = Delta t) approx y(t = 0) + Delta t dot f(y(t = 0), 0, p) $

However, we are not done yet. As we now have a numerical value for $y (t = Delta t)$, we can compute its derivative using the differential equation, and compute the next time step $y (t = 2 Delta t)$ using the same principles. What we then get is Euler's method. We can make the equation a bit easier to understand as follows:

$ underbrace(y(t + Delta t), "New value of "y "at time "t+Delta t) = overbrace(y(t), "Current value of "y "at time "t) + underbrace(Delta t, "time step") dot overbrace((upright(d) )/(upright(d) t)(y(t)),"Derivative of "y" at time "t ) $<eq-euler>

== Numerical Error
As you may remember from calculus, the approximation given by Taylor polynomials becomes better for values that lie close to the original value. This means that the error of Euler's method for one time step becomes smaller, as the time step gets closer to zero. However, for longer simulations, this also means that we need to take more steps to eventually get to the final time value that we have specified. We can see the effect of increasing the $Delta t$ value very clearly in @euler-timestep, where we see that for a small time step such as $10^(-3)$, the solution found by Euler's method is very close to the exact solution. For a larger time step of $0.5$, we see that it already deviates quite a bit from the exact solution, especially around the curve between $t = 1$ and $t = 4$. However, increasing the time step even further to $1.5$, we see that the found numerical solution oscillates around to exact solution, which results in a very large error. 

#figure(
  image("images/euler.png", width: 60%),
  caption: [Running Euler's method with different $Delta t$ values. This figure shows that increasing the $Delta t$, also increases the error made by Euler's method.]
) <euler-timestep>

To improve the numerical solution of differential equations, people have devised methods that give improved estimations with larger time steps, so we can finish simulations faster. Additionally, even more advanced methods use _adaptive time steps_, which means that the time steps are calculated based on the size and the rate of change of the derivative. Another way of improving the forward Euler method, is to not only take into account the previous value of $y$, but also the value before that, or other values of $y$. Methods that use multiple values of $y$ to calculate the next value are called #emph[multistep] methods. The details of these methods are beyond the scope of these lecture notes, but in Python, you will make use of these more advanced methods. 

== Exercises 

#question[In this exercise, you will use Python to implement your own version of the forward Euler method to solve differential equations numerically.]

For testing, we will use the following differential equation:
$ ddt(y(t)) = -2 y(t) + 1 $

The analytical solution of this differential equation with initial condition $y(t=0) = 0$ is:
$ y(t) = 0.5 (1 - exp(-2 t)) $

#set enum(numbering: "a)", indent: 16pt)
#subquestion[Implement a python function `ode` that takes as input the current value of $y$, and returns the derivative of $y$ according to the differential equation above.]
#subquestion[Implement a python function `euler_step` that takes as input the current value of $y$, the time step $Delta t$, and the function `ode`, and returns the next value of $y$ using the forward Euler method as in @eq-euler.]
#subquestion[Implement a python function `euler_solve` that takes as input the initial value of $y$, the final time $t_f$, the time step $Delta t$, and the function `ode`, and returns the numerical solution of $y$ from $t=0$ to $t=t_f$ using the forward Euler method.]
#subquestion[Find an appropriate time step $Delta t$ such that the numerical solution at $t=5$ is within $1%$ of the analytical solution. Plot the numerical and analytical solution for this time step.]

#question[Generalize your implementation of the forward Euler method to take in an ode function of the form `ode(y, t, p)`, where `y` and `p` are `numpy` arrays, and `t` is a scalar. Test your implementation on the following system of differential equations:]

$ ddt(y_1(t)) &= -k_1 y_1(t) + k_2 y_2(t) \
ddt(y_2(t)) &= k_1 y_1(t) - k_2 y_2(t) $

With initial conditions $y_1(t=0) = 1$, $y_2(t=0) = 0$, and parameters $k_1 = 0.5$, $k_2 = 0.3$. Plot the results of your simulation.

#question[In this exercise, you will implement a simple adaptive time step method based on the forward Euler method.]

The simple adaptive time step method works as follows:
1. Start with an initial time step $Delta t$.
2. Compute the next value of $y$ using the forward Euler method with time step $Delta t$.
3. Compute the next value of $y$ again, but this time using two steps of size $(Delta t) / 2$.
4. Compare the two results. 
  - If the difference is larger than $10^(-2) dot y$, reduce $Delta t$ by half and repeat from step 2. 
  - If the difference is smaller than $10^(-9) dot y$, increase $Delta t$ for the next step by doubling it.
  - Otherwise, keep $Delta t$ the same for the next step.
5. Continue until the final time $t_f$ is reached.

Implement this method in Python, and test it on the differential equation from the previous exercise. Plot the numerical solution along with the analytical solution, and also plot the time step $Delta t$ used at each time point.

= Biological Model Components<modelling-bio-systems>

#set align(center)
#quote(block: true, attribution: [Chef Gusteau (Ratatouille)])[
  #text(size: 13pt)[_"You must be imaginative, strong-hearted. You must try things that may not work, and you must not let anyone define your limits because of where you come from."_]
]
#v(2em)
#set align(left)

In this section, we will talk about ways to introduce suppressive of stimulatory signals into a model, and illustrate some differences with earlier biochemical models. We will then zoom out of individual signals and inspect models as a whole.

== Linear Stimulation

The first kind of signalling that we can model is linear stimulation. Observe the reaction
$ A + X limits(-->)^(k_1) B + X $ 
For this reaction, we can see that there is no net consumption of $X$, and we can use mass action kinetics to describe the conversion of $A$ and $B$, which is mediated by $X$ in this case:

$ 
&(upright(d)[A]) / (upright(d)t) = -k[A][X] \
&(upright(d)[B]) / (upright(d)t) = k[A][X] \
&(upright(d)[X]) / (upright(d)t) = 0 \
$

We can see from the equations that in presence of $X$, molecule $A$ is converted into molecule $B$, which is a form of positive interaction. In this form, we assume that the more of $X$ we have, the quicker $A$ is converted into $B$, without a limit. However, when $X$ is not present, we see no conversion. We can also see this in @linear-stimulation-1, which shows that with increasing value of our stimulatory agent $[X]$, the rate of conversion of $A$ into $B$ increases, but without $X$, we see no conversion happening. 

Another way to write this conversion is to define the rate of the reaction as a function of $[X]$, which we can write as:
$ A limits(-->)^(K([X])) B $<eq-signal-fun>

with

$ K([X]) = k[X] $

#figure(image("images/linear_stimulation.png", width: 70%), caption: [Simulation of a linear stimulation model where $A$ is converted into $B$ using a stimulatory agent $X$. The colors indicate the concentrations of this stimulatory agent.])<linear-stimulation-1>

A method to extend this model is to add the possibility for $A$ to spontaneously convert into $B$ without the interaction with $X$. We can do this by adding the reaction:
$ A limits(-->)^(k_"sp") B $ 
Combining both into a system of differential equations will result in:
$
&(upright(d)[A]) / (upright(d)t) = -lr()(k[X] + k_"sp")[A] \
&(upright(d)[B]) / (upright(d)t) = lr()(k[X] + k_"sp")[A] \
&(upright(d)[X]) / (upright(d)t) = 0 \
$

In this model, we can see that the rate of conversion from $A$ to $B$ is subject to a basal rate $k_"sp"$ and increases linearly with the concentration of $X$. 

Similarly to the first example, the chemical reaction here can also be written as in @eq-signal-fun, but with $k([X])$ defined as:

$ K([X]) = k[X] + k_"sp" $

== Linear Suppression<linsup>

Besides stimulation, we can also model suppression in a similar way. The simplest form of suppression can be achieved by using the formulation as in @eq-signal-fun, and defining the rate as:

$ K([X]) = 1 / (k[X] + k_"sp") $

In this way, as soon as $[X]$ increases, the overall rate decreases. We also need the extra term in the denominator, because otherwise, the reaction rate would go to infinity as soon as $[X]$ approached a value of $0$.

However, we can also be a bit more creative in modelling suppression, but we will need some more tools to do so. Another way to model suppression is that we have a reaction where an active form of molecule $A$ is converted into molecule $B$:
$ A_"act" limits(-->)^k B $
Additionally, we introduce a suppressive agent $Y$, which blocks this conversion. This can be modelled by a reaction, mediated by $Y$, that converts our active form of $A$ into an inactive form:
$ A_"act" + Y limits(-->)^(k_i) A_"inact" + Y $
We now still miss one key component in this model. We want this suppression to be reversible, meaning that as soon as $Y$ disappears, we need the conversion of $A$ into $B$ to occur again. Therefore, we can add a reaction where $A_"inact"}$ converts into $A_"act"}$:
$ A_"inact" limits(-->)^(k_a) A_"act" $
Combining these three reactions into a system of differential equations can once again be done using mass-action kinetics:
$
&(upright(d)[A_"act"]) / (upright(d)t) &=& -lr()(k+k_i [Y])[A_"act"] + k_a [A_"inact"] \
&(upright(d)[A_"inact"]) / (upright(d)t) &=& k_i [Y] [A_"act"] - k_a [A_"inact"] \
&(upright(d)[B]) / (upright(d)t) &=& k[A_"act"] \ 
&(upright(d)[Y]) / (upright(d)t) &=& 0 
$<linsup-eq>

Observe that we have added an additional equation that specifies that the concentration of $A$ equals the sum of active and inactive substrate. A simulation of this system for different values of our suppressant $Y$ can be seen in @linear-suppression. If we increase the level of suppressant, we see that the proportion of $A$ being converted into $B$ decreases. 

#figure(image("images/linear_suppression.png",width: 100%), caption: [Simulation of a linear suppression model with suppressant $Y$. The colors indicate the concentration of this suppressant.])<linear-suppression>

== Enzyme Kinetics

A special case of stimulation or suppression can be seen in enzyme catalysis. In your biochemistry course, you will have seen Michaelis-Menten kinetics. For completeness, the derivation of this type of kinetic model is given here, but the most important consideration is that you realize the assumption it makes and what the kinetic equation looks like, so you can recognize it in future models. We will first start with the derivation of the kinetic law using a stimulatory enzyme.

An enzymatic reaction can be summarized as:
$ E + S limits(<-->)^(k_1)_(k_(-1)) C limits(-->)^(k_2) E + P $

In this reaction, an enzyme $E$ and a substrate $S$ form a complex $C$, which can also fall back apart. However, if the catalysis succeeds, the enzyme is released and a product $P$ is formed. Using mass-action kinetics from the previous sections, we can create a differential equation model for this system:

$ 
&ddt([S]) &=& k_(-1)[C] - k_1 [E][S] \
&ddt([E]) &=& (k_(-1)+k_2)[C] - k_1[E][S] \
&ddt([C]) &=& k_1[E][S] - (k_(-1)+k_2)[C] \
&ddt([P]) &=& k_2[C] 
$

The main assumption for Michaelis-Menten kinetics, is that the total conversion from substrate into product is mainly determined by the formation of the complex $C$. The consequence of this assumption, is that the amount of complex in the system rapidly reaches an equilibrium, which results mathematically into the relationship:
$ ddt([C]) = 0 $

Using this assumption, we can write:
$ k_1[E][S] = k_(-1)+k_2[C] $<michmentresult>

Furthermore, the second assumption is that the total amount of enzyme in the system doesn't change. The total amount of enzyme can then be formulated as the sum of the amount of free enzyme $[E]$ and the amount of complex $[C]$. We can call this concentration $E_0$:
$ E_0 = [E] + [C] $

Replacing $[E]$ in @michmentresult with $E_0 - [C]$ gives us:
$ k_1E_0[S] = (k_(-1)+k_2 + k_1[S])[C] $

From which we can derive the following formula for $[C]$:
$ [C] = (k_1E_0[S]) / (k_(-1)+k_2 + k_1[S]) $

Dividing both numerator and denominator by $k_1$ and defining $K_M = (k_(-1)+k_2) / (k_1)$ we get:
$ [C] = (E_0 [S]) / (K_M + [S]) $

Filling this in into the function for the product formation, and defining 
$ V_"max" = k_2E_0 $<v-max-eq>
we get:
$ ddt([P]) = V_"max" [S] / (K_M + [S]) $<michmentequation>

The rate in @michmentequation is what we define as Michaelis-Menten kinetics. The behavior of this type of kinetics can be observed in @michaelis-menten-a, which shows the reaction rate as a function of the substrate concentration for different values of $K_M$. You can see that for increasing substrate concentration, the reaction rate approaches $V_"max"$. In @michaelis-menten-b you can see the product concentration over time from a simulation of the Michaelis-Menten conversion. This conversion is also compared to the linear mass-action conversion in this figure. The effect of $K_M$ is also clearly visible in both figures. 

#subpar.grid(
  figure(image("images/michaelis_menten_rates.png", width: 60%), caption: ""), <michaelis-menten-a>,
  figure(image("images/michaelis_menten_ode.png", width: 60%), caption: ""), <michaelis-menten-b>,
  columns: (1fr, 1fr),
  caption: [Simulation of Michaelis-Menten kinetics for various values of $K_M$. *(a)* The reaction rate according to Michaelis-Menten kinetics as a function of the substrate concentration, compared to the value of $V_"max"$. *(b)* Simulation of product formation according to Michaelis-Menten kinetics.],
  label: <michaelis-menten>,
)

== Advanced Enzyme Kinetics: Reversible Inhibition
Sometimes, an enzymatic reaction can occur in presence of an inhibitor $I$. As discussed in earlier courses, reversible inhibition can take three forms. We have competitive inhibition, non-competitive inhibition and uncompetitive inhibition (see also @fig-inhibition). These three forms also have distinct kinetic rates that we can derive. Their derivations are beyond the scope of these lecture notes, but their resulting equations can be readily explained from the mechanisms of each type of inhibition.

#figure(image("images/inhibition.png"), caption: [Forms of reversible inhibition. With competitive inhibition, the inhibitor binds to the active site of the substrate, preventing the formation of an active complex. In non-competitive inhibition, the inhibitor binds to an allosteric site, reducing or blocking the catalytic activity of the enzyme. In uncompetitive inhibition, the inhibitor can only bind to an allosteric site of the enzyme-substrate complex.])<fig-inhibition>

=== Competitive Inhibition
Competitive inhibition can be represented in chemical reactions as
$
E + S &limits(<-->)_(k_(-1))^(k_1) C limits(-->)^(k_2) P \
E + I &limits(<-->)^(k_i)_(k_(-i)) C_I
$
Where we have a normal complex $C$ and a substrate-inhibitor complex $C_I$. The rate law for competitive inhibition with an inhibitor $I$ is given by:
$
v = (V_"max" [S]) / (K_M^"app" + [S])
$
With $ K_M^"app" = K_M lr()(1 + [I] / K_i) $

The result of this competitive inhibition on the reaction rates can be seen from the equation. As we increase the inhibitor concentration $[I]$, we see that apparent Michaelis-Menten constant ($K_M^"app"$) increases, meaning that we will need more substrate to reach our $V_"max"$, (also see @michaelis-menten) but we will still be able to reach this maximum reaction rate. This effect can be explained as the presence of this inhibitor decreases the enzyme affinity for the substrate. Many drugs act as competitive inhibitors, as they are designed to resemble the substrate and therefore bind to or block the active site of specific enzymes. 

=== Non-competitive Inhibition
The second type of inhibition is non-competitive inhibition, which can be formulated as 
$
E + S &limits(chq)_(k_(-1))^(k_1) C_S limits(->)^(k_2) E + P \
E + I + S &limits(chq)^(k_i)_(k_(-i)) C_I + S limits(chq)^(k_("i2"))_(k_(-"i2")) C_"IS" limits(chq)^(k_("i3"))_(k_(-"i3")) C_S + I

$

This reaction system shows that our inhibitor can bind and unbind from every step of the catalytic process. For a non-competitive inhibitor, we will see that instead of increasing $K_M$, we decrease $V_"max"$ with the rate law:

$
v = (V_"max"^"app" [S]) / (K_M + [S])
$
With 
$ V_"max"^"app" = (V_"max") / (1 + [I] / K_i) $

As the binding of a non-competitive inhibitor reduces the activity of the enzyme without changing the enzyme's affinity for the substrate, the $V_"max"$ is decreased. Examples of non-competitive inhibition include the binding of Glucose-6-Phosphate to hexokinase in the brain, slowing the rate of cerebral glucose uptake. 

=== Uncompetitive Inhibition
The final type of inhibition is called uncompetitive inhibition, which changes both $V_"max"$ and $K_M$. We can formulate this inhibition as:
$
&E + S &limits(chq)^(k_1)_(k_(-1))& C_S limits(->)^(k_2) E + P \
&C_S + I &limits(chq)^(k_i)_(k_(-i))& C_"IS"
$

We can see that the inhibitor can only bind to the enzyme-substrate complex. This type of inhibition is very rare, but does occur. The rate law for this type of inhibition is given by:
$
v = (V_"max"^"app"[S]) / (K_M^"app" + [S])
$
With 
$ V_"max"^"app" = (V_"max") / (1 + [I] / K_i) $
and
$ K_M^"app" = K_M  / (1 + [I] / K_i) $

Contrarily to competitive inhibition, the $K_M$ decreases with increasing inhibitor concentration, while $V_"max"$ decreases, similarly to non-competitive inhibition. One of the main features of this type of inhibition is that its effect is largest at high substrate concentrations. 

=== Cooperative Binding: Hill Kinetics
The production rate of the product $P$ described by Michaelis–Menten kinetics, is a hyperbolic function of the substrate concentration $[S]$. However, in many cases, measuring the reaction rate as function of the substrate concentration leads to different behavior. One reason may be cooperative binding of the substrate to the enzyme. Cooperative binding means that the binding of one substrate molecule has influence on the binding of subsequent substrate molecules to the enzyme (possibly, with several active sites). The cooperativity is positive if the binding of a first substrate molecule increases the affinity of other active sites of the enzyme for substrate molecules, and negative if this binding decreases the affinity of other active sites. The effective rate of a reaction with such a cooperative effects is often described by an equation similar to the Michaelis-Menten rate equation:

$ ddt([P]) = V_"max" [S]^n / ((K_M)^n + [S]^n) $<hill-equation>

The difference is that we have introduced an additional term $n$, in the exponent of every term in the fraction. This type of kinetics is called #emph[Hill kinetics], and @hill-equation is called the #emph[Hill equation]. 

For $n=1$, this equation is equal to the Michaelis-Menten kinetics. This value $n$ is linked to the cooperativity of the reaction. A value of $n$ in between 0 and 1 indicates a negative cooperativity, while a value for $n > 1$ indicates positive cooperativity.

#subpar.grid(
  figure(image("images/hill_rates.png", width: 55%), caption: ""), <hill-a>,
  figure(image("images/hill_ode.png", width: 55%), caption: ""), <hill-b>,
  columns: (1fr, 1fr),
  caption: [Simulation of Hill kinetics for various values of $n$. *(a)* The reaction rate according to Hill kinetics as a function of the substrate concentration, compared to the value of $V_"max"$. *(b)* Simulation of product formation according to Hill kinetics.],
  label: <hill>,
)

==== Modelling Gene Regulation
For gene transcription, regulation often occurs through transcription factors. In many cases, the binding of these transcription factors to DNA occurs cooperatively, and can therefore be modelled using Hill kinetics. However, besides stimulating transcription, transcriptional regulation also occurs in an #emph[inhibitory] fashion. The inhibitory version of the Hill equation is given by

$ ddt([P]) = V_"max" (K_M)^n / ((K_M)^n + [S]^n) $

From this equation, we can see that an increase in binding of substrate reduces the formation of product, or in this case, transcription of genes. In gene regulatory networks, often many combinations of transcription factors play a role, which results in a combination of many transcription factors and therefore results in very large models. For these types of networks, #emph[boolean] models are often used, which are simulated much more quickly. The downside of these models is that the gradual change in stimulation or inhibition is difficult to capture using boolean logic models. 

Another option is to transform these boolean models into a continuous model, as described in @wittmann_transforming_2009. In this technique, stimulatory and inhibitory hill functions are combined according to logic rules. However, further discussion of this topic is beyond the scope of these lecture notes.


== Feedback Loops
Combining these regulatory mechanisms that are present in models of biological systems often leads to feedback loops appearing. A feedback loop is a specific regulatory pattern that dictates how components of a system interact over time. They are an important component of many biological systems and are required for a system to return to its original state after an external influence, or cause repetitive behavior to occur. 

We can identify positive and negative feedback loops. A positive feedback loop occurs when the endpoint of a series of reactions promotes the starting point of this same series, causing the complete set of reactions to become increasingly active over time. When the endpoint blocks the starting point of this series, we call this negative feedback, which is necessary for a system to return to its original state. 

Combinations of positive and negative dictate our bodily processes, and a disturbance in the balance of these loops can lead to diseases. Examples include stress-related diseases or diabetes. When analyzing a biological system, it often helps to outline the positive and negative feedback loops in the system to get an understanding of the interacting processes.

// TODO: Illustration?

== Modelling Example: The Cell Cycle
In this part, we'll be looking at an example model, explaining the components using the modelling tools we have explored up to this point. The following model is a heavily simplified model of the cell cycle published in 1991 by Goldbeter @Goldbeter1991. In this model, cyclin ($bold(C)$) is modelled to induce the production of a cyclin kinase $(bold(M))$, which in turn activates the production of a cyclin protease $(bold(X))$. This protease then stimulates the degradation of the original cyclin. An illustration of the model and its interactions is given in @fig-goldbeter. 

#figure(image("images/goldbeter.png", width: 50%), caption: [Illustration of the components and their interactions in the Goldbeter model \cite{Goldbeter1991} of the cell cycle. The figure shows interactions between cyclin (C), cyclin kinase (M) and cyclin protease (X). Arrows indicate positive interactions and bars indicate suppressions. Parameter names are given for all interactions.])<fig-goldbeter>

The model is mathematically formulated as:

$
&ddt(bold(C)) &=& v_i - v_d bold(X) bold(C) / (K_d + bold(C)) - k_d bold(C) \ 
&ddt(bold(M)) &=& V_1 bold(C) / (K_c + bold(C)) (1 - bold(M)) / (K_1 + 1 - bold(M)) - V_2 bold(M) / (K_2 + bold(M)) \
&ddt(bold(X)) &=& V_3 bold(M) (1 - bold(X)) / (K_3 + 1 - bold(X)) - V_4 bold(X) / (K_4 + bold(X))
$

We can see that the model contains six examples of Michaelis-Menten kinetics. The equations for cyclin kinase and cyclin protease ($bold(M)$ and $bold(X)$) are structurally similar. We will first look at cyclin ($bold(C)$). The base of this equation is the constant production and removal term, according to mass action kinetics, and based upon the chemical formulation:
$ ->^(v_i) C ->^(k_d) $

We then see that the additional term represents a catalytic consumption of cyclin by cyclin protease, yielding an unmodelled product. As the enzyme concentration ($bold(X)$) varies throughout the simulation, the previously constant term $V_"max"$ is replaced by $v_d bold(X)$, using the original definition of $V_"max"$ (see @v-max-eq).

Cyclin kinase ($bold(M)$) production is then stimulated by cyclin using a Michaelis-Menten factor in the first term of the second reaction. The term after this factor represents Michaelis-Menten kinetics of a cyclin kinase progenitor, where the total concentration of cyclin kinase and its progenitor is normalized to the constant value of 1. We can then describe the progenitor concentration as $1-bold(M)$. The second term describes the consumption of cyclin kinase by an unmodelled enzyme with constant concentration using Michaelis-Menten kinetics. 

The equations of cyclin protease ($bold(X)$) have the same structure as cyclin kinase, where its production is stimulated by cyclin kinase, and is consumed using Michaelis-Menten kinetics, driven by an unmodeled enzyme with constant concentration.

#figure(image("images/goldbeter_ode.png", width: 50%), caption: [Simulation of the Goldbeter model. We can clearly see the oscillatory behavior that the model produces.])<goldbeter-ode>

When simulating this model, we find that it shows oscillations in all three state variables (see @goldbeter-ode). This behavior is a result of the negative feedback loops present in the system. The system is kept running through the parameters $v_i$ and $k_d$, which provide a constant production and consumption of $bold(C)$. Then $bold(C)$ stimulates $bold(M)$, which is suppressed by $bold(M)$. Then, $bold(M)$ stimulates $bold(X)$, which is suppressed by $bold(X)$. Finally, $bold(X)$ suppresses $bold(C)$ by stimulating an additional consumption term, allowing for a restart of the cycle. 

== Setpoints, and Perturbations

Besides the simulation, we may often be interested in other model properties that we can calculate. An important property of dynamic models is the steady state. When we have a dynamic model defined by:
$ 
ddt(x) = f(x)
$

The steady state is given by $f(x) = 0$, which means that our state variable does not change over time anymore. We can, for example, compute the steady-state for the model from @linsup-eq.

#example_box(body: [
  The system represents a linear suppression model with the equations:
  $
&(upright(d)[A_"act"]) / (upright(d)t) &=& -lr()(k+k_i [Y])[A_"act"] + k_a [A_"inact"] \
&(upright(d)[A_"inact"]) / (upright(d)t) &=& k_i [Y] [A_"act"] - k_a [A_"inact"] \
&(upright(d)[B]) / (upright(d)t) &=& k[A_"act"] \ 
&(upright(d)[Y]) / (upright(d)t) &=& 0 
$

    From our first analysis, we see that $Y$ is \emph{always} in steady state, as its derivative is set to zero. To compute the steady-state for the entire system, we find that $B$ is only in steady-state whenever $[A_"act"]$ is zero. Using this fact, we can express the steady state of $A_"act"$ as
    $ ddt([A_"act"]) = underbrace(-lr()(k + k_i [Y]) [A_"act"], = 0text(", since ") [A_"act"] = 0) + k_a [A_"act"] = k_a [A_"inact"] = 0 $
    From this we conclude that in steady-state $[A_"inact"] = 0$ as well. Filling this in, we also see that no further conditions are necessary to make sure $[A_"inact"]$ is also in steady state. 
]
)

A related property of a system is called a setpoint. In control systems, a setpoint is the target value of a specific variable in the entire dynamic system. Setpoints are often used when modeling biological systems that typically return to a specific steady state, such as glucose, which typically has a fasting value of around 5 mmol/L. In modeling, we then use a setpoint to force the system into steady state as soon as this is the case. An example can be seen in a simple glucose model.

#example_box(body: [
  The Bergman glucose minimal model @Bergman2021 can be formulated as:
  $ 
  &ddt(G) &=& -k_1 G X - k_3 lr() (G - G_b) + "Ra"(t) \ 
  &ddt(X) &=& -X + k_2 (I(t) - I_b)
  $
    This model describes the basic regulation of glucose by insulin. The components of insulin ($I(t)$) and glucose input ($"Ra"(t)$) are described as external inputs to the model, so they must be known to describe the whole system.
    
    When investigating this system, we see that the following conditions need to be met for the system to be in steady state:

      - $X = 0$
      - $I(t) = I_b$
      - $G = G_b$
      - $"Ra"(t) = 0$

    The model contains two setpoints; we have $I_b$, which is the setpoint of the insulin concentration, and $G_b$, which is the setpoint of the glucose concentration.
] 
)

In some model applications, we also want to provide external inputs. In the above example, we have $"Ra"(t)$ representing the external glucose input. This external input is what we call a #emph[perturbation]. In some cases, perturbations can help us understand how models change from their normal steady state to an alternative steady state. To investigate these properties, we need simulations of model behavior, trying out various perturbation sizes and durations. 

== Measurements
To build a model, we often don't rely solely on knowledge of a specific system. Additionally, measurements from experiments can be used to create or validate a model. In this section, we will introduce various types of experiments and measurements that can be used in conjunction with building or using a computer model. 

Fundamental reaction information can be measured by recreating the situation _in vitro_ and measuring the reaction rates for different values of substrate, as well as possibly varying the environment. However, some processes cannot easily be translated from _in vitro_ experiments to _in vivo_ processes. Furthermore, some conditions may be very difficult to simulate in a test tube, such as obesity or liver disease. To perform measurements of biological systems, model organisms can be used to recreate _in vivo_ conditions. For modelling metabolic systems, mouse models are frequently used, but measurements of humans in clinical trials are also common.

The specific type of measurements that can be used also influence the way models are structured. In many _in vivo_ conditions, the state variables are often difficult to measure directly, and require additional processes to get an (indirect) measurement, such as fluorescence. These additional processes then also need to be taken into account in the model that is built. In other cases, we may be limited by the amount of detailed measurements we can do, which directly limits the amount of detail we can put in our model. 

A special type of measurements is done using #emph[tracers]. These are molecules that have a radioactive or stable isotope attached to them, that can be measured afterwards. An example of the use of stable isotope tracers is the large Dalla-Man meal simulation model @DallaMan2007, which enabled the measurement of specific subprocesses of glucose metabolism.

== Parameter Estimation
When we have measurements, we also need to couple them to model parameters. If we have _in vitro_ kinetic measurements, we can directly derive the kinetic parameters, for example using a Lineweaver-Burk plot for Michaelis-Menten kinetics. However, a common way to obtain the model parameters from measurements of the state variables is through parameter estimation. This procedure is beyond the scope of these lecture notes, but the general idea is that you use mathematical optimization techniques, as also used in machine learning, to select parameter values that minimize the difference between the observed state variables and the simulated state variables from the model.

== Exercises 

#question[Given is the following system of ordinary differential equations]

$
&frac(upright(d)[a], upright(d)t) &=& k_(a,0) - [a] lr()(k_(a,1) + k_(a,2)[c]) \
&frac(upright(d)[b], upright(d)t) &=& k_(a,1)[a] +  k_(a,2)[a][c] - k_(b,0)[b]\
&frac(upright(d)[c], upright(d)t) &=& k_(b,0)[b] - k_(c,0)[c]
$

#set enum(numbering: "a)", indent: 16pt)
#subquestion[Explain why $c$ acts as a stimulatory agent.]
#subquestion[Express the steady-state concentrations of $a$, $b$, and $c$ using the parameters of this system.]
#subquestion[Change the model equations such that $c$ is a suppressive agent.]
#subquestion[Express the steady-state concentrations of $a$, $b$, and $c$ using the parameters of the suppressive system.]


#question[Given the following description of a dynamic model]

We have two species, labelled $X$ and $Y$. Species $X$ is produced constantly at a rate $k_x$. Species $Y$ is a dimer of species $X$, which forms breaks apart spontaneously. The basal formation rate $k_f$ is equal to the rate of breaking apart $k_b$. This dimer can also break apart differently at rate $k_(b,2)$, forming molecules
$A$ and $B$, which are removed from the system at rates $k_a$ and $k_b$ respectively.

#set enum(numbering: "a)", indent: 16pt)
#subquestion[Write down the differential equations of the system described in this piece of text.]

A third molecule $Z$ acts as a suppressant of the process of breaking apart, by binding to the dimer $Y$ with a rate $k_z$, which results in a more stable molecular complex. $Z$ can also unbind from $Y$, for which the basal rate is only 25% of the binding rate.
$Z$ is not produced or broken down otherwise.

#set enum(numbering: "a)", indent: 16pt, start: 2)
#subquestion[Adapt the differential equations to accomodate this description.]

#question[Antidiuretic Hormone (ADH)]

Antidiuretic hormone (ADH), also called vasopressin, is a hormone that regulates water balance in the body. It acts on the kidneys to reduce the amount of water excreted in the urine. ADH acts by binding to a transmembrane receptor
that activates a cascade resulting in the membrane trafficking of aquaporin channels, allowing for the resorption of water in the kidneys. A model by Fröhlich et al. @frohlich_systems_2010 describes the trafficking of aquaporin channels. The model equations are as follows:

$
ddt(["PKA"]) &= -k_3 dot ["PKA"] dot ["cAMP"] + k_4 dot ["PKA"_a] \
ddt(["PKA"_a]) &= k_3 dot ["PKA"] dot ["cAMP"] - k_4 dot ["PKA"_a] \ 
ddt(["cAMP"]) &= k_1 dot ["ADH"] - k_2 dot ["cAMP"] dot ["PKA"_a] - k_3 dot ["PKA"] dot ["cAMP"] \
& + k_4 dot ["PKA"_a] - k_7 dot ["cAMP"] \
ddt(["AQP"]) &= -k_5 dot ["AQP"] dot ["PKA"_a] + k_6 dot ["AQP"_m] - k_8 dot ["AQP"] \
ddt(["AQP"_m]) &= k_5 dot ["AQP"] dot ["PKA"_a] - k_6 dot ["AQP"_m] + k_8 dot ["AQP"] \
ddt(["ADH"]) &= -k_9 dot ["ADH"]^2
$

#set enum(numbering: "a)", indent: 16pt, start:1)
#subquestion[Based on this model, explain how ADH stimulates the movement of aquaporin channels to the membrane.]
#subquestion[Cyclic AMP ($["cAMP"]$) is involved in negative feedback loop. Explain this.]
#subquestion[In absence of AHD, the aquaporin trafficking is in steady-state. Express $k_8$ using $k_6$ and the steady-state concentrations of membrane and cytosol AQP.]


#question[Michaelis-Menten Kinetics]
#set enum(numbering: "a)", indent: 16pt, start:1)
#subquestion[Explain in words the meaning of the michaelis menten constant $K_M$.]
#subquestion[In some models, enzymatic reactions can be approximated by linear kinetics. Under what circumstance is this appropriate?]

#question[Reversible Inhibition]

For each type of inhibition, explain the change in apparent $K_M$ and $V_"max"$ based on the mechanism of inhibition.
 
= Whole-Body Models

#set align(center)
#quote(block: true, attribution: [Buzz Lightyear (Toy Story)])[
  #text(size: 13pt)[_"To infinity and beyond!"_]
]
#v(2em)
#set align(left)

In this book chapter, we will explore the application of modelling with differential equations on the scale of the whole human body. With this, we mean the interaction of several organs and organ systems on a macro scale. A large application of these whole-body models lies in pharmacology, where simplified models of humans are used to describe the absorption, distribution, metabolism, and excretion (ADME) of drugs. However, the content here in this chapter is applicable to modelling as a whole. 

Before we dive into actual building of models, however, we will first discuss some more fundamental concepts to complete our dynamic modelling toolbox. The first of these concepts is the concept of compartmental models, which are widely used in the study of pharmacokinetics to describe drug concentrations after administration. In short, pharmacokinetics studies what the body does to drugs, while pharmacodynamics focuses on what drugs do to the body. We will be discussing pharmacokinetics, as the components involved in modeling these systems resembles how we approached biological system modeling. A different field of study, is pharmacodynamics, where the drug effects on measurable quantities are modelled, such as the effect of a drug on the heart rate, or body temperature. 

These pharmacokinetic models are very useful, as when administering or prescribing drugs, the main goal is that they are effective, which means that the amount of drug inside someone's system should reach a level where it #emph[can] be effective. However, it cannot exceed the concentration required to achieve toxicity. Additionally, we may want to minimize the dosage initially, so we will be able to increase it without coming too close to a toxic dose. To be able to produce solutions to these problems, models can be made of the behavior of drugs inside the body. In this section, we will also explore modelling concepts that are necessary for building and understanding these models.

== Compartmental Models
In modelling, a compartment is a separate body containing a specific species in the system. To describe the distribution of drugs after administration, compartments are used in pharmacokinetics. A compartmental model is also often used in epidemiology, for example to describe disease spread over a population. @Brauer2008 Within a compartment, we assume that we have an instant homogeneous distribution of substrate. The quantity of substrate ($c_i$) within a compartment $i$, can be described according to:
$ ddt(c_i) = "input"(bold(c), t) - "output"(bold(c), t) $<compartment>

Where $bold(c)$ is the vector of all concentrations in all compartments in the system. As opposed to earlier models, observe that in this case, the differential equation describes substrate #emph[quantity] instead of substrate #emph[concentration]. To convert the differential equation to substrate concentration, we will need to divide the quantity by the #emph[volume of distribution] ($V_d$) of the substrate in the compartment. This is not an actual volume but it is the amount of blood that would be required if the drug was evenly distributed over the body at the concentration of the collected sample. As we assume this volume is kept constant, we can freely divide $q_i$ by $V_d$ within @compartment.

=== One-Compartment Model
The one-compartment model is the simplest compartmental model. As the name implies, it contains a single volume which contains the species or drug of interest. The one-compartment model is effective in describing intravenously administered species and remain in specific organs that have a high blood perfusion. This compartment typically combines the heart, liver, kidneys and the blood plasma into one #emph[central compartment], as seen in @one-compartment-model. 

#figure(image("images/one-compartment-model.png", width: 40%), caption: [One-compartment model with a central compartment containing the drug, and a single elimination term.])<one-compartment-model>

For an IV bolus administration of a dose $D$ at $t = 0$, the one-compartment model equation is given as:
$ ddt(c(t)) = - k_c c(t) $
Where $c(0) = D / V_d$.

Note that we divide the dose by the compartment volume $V_d$, or volume of distribution, to obtain the initial concentration.

We can solve this differential equation easily by writing
$ integral (upright(d)c) / c = -k_c dot integral upright(d)t $ 
Which results in
$ ln(c(t)) = ln(D/V_d) - k_c t \ 
 => c(t) = D/V_d e^(-k_c dot t) $

 An important characteristic is the elimination half-life, which is defined as the time it takes for the species amount to become half of its initial concentration. As $V_d$ is constant, half the concentration means half the amount of drug delivered, so we can derive a formula for this using
 $ c(t_(1 slash 2)) &= D/V_d e^(-k_c dot t_(1 slash 2)) = D/(2 V_d) \
 &=> k_c dot t_(1 slash 2) = ln(2) \
 &=> t_(1 slash 2) = ln(2)/k_c $

To test whether a species concentration after IV bolus injection can be modelled using a one-compartment model, we can plot the log-concentration value over time and inspect whether it has a linear slope. If the points at the low and high concentration values deviate from a linear slope, this may be reason to suspect that more compartments are necessary. However, this can also occur when the measuring equipment has a lower accuracy in specific low or high concentrations, or when the measurement device nears its limit of detection, which is the lowest concentration that the test can measure.

=== Two-Compartment Model
One of the most commonly used compartmental models is the two-compartment model. As the name indicates, this model contains two volumes where the species can reside in. As in the one-compartment model, this model contains the central compartment, but it also contains a #emph[peripheral compartment]. While the compartments in this model have no direct physiological meaning, a reasonable assumption is to think of the central compartment as the highly-perfused tissues, where the administered substance spreads rapidly, while the peripheral compartment represents the tissues with a lower perfusion rate, such as the bone or the adipose tissue. 

#figure(image("images/two-compartment-model.png", width: 40%), caption: [Two-compartment model with a central and a peripheral compartment containing the drug, which have exchange terms and the central compartment has an elimination term.])<two-compartment-model>

For an IV-bolus, the ODE system of the two-compartment model is
$ 
&ddt(c_1(t)) = -(k_0 + k_1) c_1(t) + k_2 c_2(t) \ 
&ddt(c_2(t)) = k_1 c_1(t) - k_2 c_2(t)
$

The solution of this model is more difficult, and requires the Laplace transform, which is beyond the scope of these lecture notes. Nevertheless, the solution for the central compartment is given by

$ c_1(t) = C_1 e^(-alpha t) + C_2 e^(-beta t) $

The constants $C_1$, $C_2$, $alpha$ and $beta$ are not in the original model equations, but can be calculated from them. $alpha$ and $beta$ are known as the #emph[macro]-rate constants. The four constants are related to the original model parameters as
$ 
alpha + beta = k_0 + k_1 + k_2 \
alpha dot beta = k_2 dot k_0 \
C_1 = (D_0/V_d (alpha - k_2)) / (alpha - beta) \
C_2 = (D_0/V_d (k_2 - beta)) / (alpha - beta)
$
Where $D_0$ is the initial bolus IV dose and $V_d$ is the distribution volume of the central compartment. 

From the equations, one can see that the clearance essentially has two phases. We have the fast-phase, which is controlled by $C_1$ and $alpha$, and the slow phase, controlled by $C_2$ and $beta$. Each of these phases also has their own half-life, which are named the distribution and elimination half-life respectively:

$ t_(1 slash 2, alpha) = ln(2)/alpha \
t_(1 slash 2, beta) = ln(2)/beta $

For drugs adhering to two-compartmental kinetics, the reported half-life is often only one value, which corresponds to the slowest of the two. 

=== Multi-Compartment Models
When talking about more than two compartments, we typically refer to a model as a multi-compartment model. An example of a commonly used multi-compartment model is the physiologically-based pharmacokinetic (PBPK) model. These models typically also consider blood flow and perfusion of various organs and tissues in a very detailed way. Because of their detail, they can 
be used to perform detailed modelling experiments. Other examples multi-compartment models are the Eindhoven Diabetes Education Simulator (EDES) @maas_physiology-based_2015, the Sips model of lipoprotein distributions @sips_computational_2014, and the Mixed Meal Model @odonovan_quantifying_2022, which also includes triglyceride and free fatty acid kinetics. In @4cpbpk, you can see a schematic example of 
a large PBPK model with some example compartments. This model contains seven compartments in total: five tissue compartments, and two plasma compartments. 

Additionally, various routes of administration are shown in this figure. In a later section of this chapter, we will dive into modelling these different routes of administration.
#figure(image("images/4-comp-pbpk.png", width: 50%), caption: [A seven-compartment PBPK model, showing various routes of administration, such as through inhalation, IV, or oral.])<4cpbpk>

=== Transport Between Compartments
When using compartment models, it is often a good idea to think about modelling transport between these compartments. Different molecules are transported differently accross membranes in the body, and this affects 
the way we need to model the transport between compartments. In the simplest case, we have free diffusion over a membrane, where the transport rates are equal in both directions. Simple diffusion is therefore easily modelled, knowing that the inward
rate can be written as:

$ ddt(c_"out") = P (c_"out" - c_"in") $

Where $P$ is the permeability of the membrane, and $c_"in"$ and $c_"out"$ are the concentrations on either side of the membrane. The outward rate can be written as:

$ ddt(c_"in") = P (c_"in" - c_"out") $

Note that when the concentrations are equal (i.e. $c_"in" = c_"out"$), the transport rate is zero. This does not mean that there is no transport, but rather that 
the net transport is zero, so the transport out of the compartment is equal to the transport into the compartment.

In many cases, the transport is not as simple as free diffusion. In many cases, transport is carried out by a transporter, which has a specific capacity for transport. This can be modelled using Michaelis-Menten kinetics. In the case of 
bidirectional transport with equal rates, the equation can be written as:

$ ddt(c_"in") = V_"max" (c_"out" / (K_M + c_"out") - c_"in" / (K_M + c_"in")) $

Where $V_"max"$ is the maximum transport rate, and $K_M$ is the Michaelis-Menten constant. However, typically, transport only occurs in one direction. For example, in the case of glucose, conversion to glucose-6-phosphate is
performed immediately after transport, so the glucose concentration in the cell ($c_"in"$) is typically zero. In this case, the equation can be simplified to:

$ ddt(c_"in") = V_"max" c_"out" / (K_M + c_"out") $

In some cases, we can even ignore the Michaelis-Menten constant, and model facilitated diffusion either using mass action kinetics, or even as a simple constant rate. In case the concentrations are always around the value of $K_M$, the Michaelis-Menten constant, and do typically
not strongly exceed this value, the Michaelis-Menten equation can be simplified to:

$ ddt(c_"in") = V_"max" c_"out" / K_M $ 

When the concentration of the substrate in all cases is much larger than the Michaelis-Menten constant, the Michaelis-Menten equation can be simplified to:

$ ddt(c_"in") = V_"max" $

These assumptions are often made in modelling to reduce the number of parameters in the model, and to make the model more easily interpretable.

In the case of active transport, we can move against the concentration gradient, which requires energy, such as ATP. This can be modelled using a term that is proportional to the concentration of ATP.

$ ddt(c_"in") = f(["ATP"]) dot c_"out" $

An exact model of active transport is often more complex, as it requires a detailed understanding of the transport mechanism.


=== Compartments as Delays
In some models, compartments can be used to represent delays in the system. This is particularly useful when modeling processes that have a time lag between the input and the observable output. For example, in pharmacokinetics, the absorption of a drug into the bloodstream after oral administration can be delayed due to the time it takes for the drug to dissolve and pass through the gastrointestinal tract.

To model this delay, we can use a series of compartments that the drug must pass through sequentially before reaching the central compartment. Each compartment represents a stage in the delay process, and the drug moves from one compartment to the next at a certain rate. This approach is known as the compartmental delay model.

Consider a simple example where a drug is administered orally and must pass through two compartments (representing the stomach and intestines) before reaching the bloodstream. The model can be described by the following differential equations:

$
&ddt(c_1(t)) = -k_1 c_1(t) \ 
&ddt(c_2(t)) = k_1 c_1(t) - k_2 c_2(t) \ 
&ddt(c_3(t)) = k_2 c_2(t) - k_3 c_3(t)
$

Here, $c_1(t)$ represents the concentration of the drug in the stomach, $c_2(t)$ represents the concentration in the intestines, and $c_3(t)$ represents the concentration in the bloodstream. The rate constants $k_1$, $k_2$, and $k_3$ determine the rate at which the drug moves between compartments.

By using compartments as delays, we can more accurately model the time-dependent behavior of drug absorption and distribution in the body. This approach can also be applied to other biological processes where delays are present, such as hormone release and signal transduction pathways.

It is important to remember that these compartments do not always have a strict physiological origin. While in PBPK models, compartments can be easily related to specific tissues, delay compartments may have no direct physiological meaning at all. For example, in a hormone release pathway, there can be
a delay between the external stimulus and the hormone release. While no compartments are involved, it could be beneficial to model this temporal lag using an additional compartment.
== Modelling Methods of Administration

When modeling the administration of substances, such as drugs or food, we need to consider the different routes through which these substances enter the body. Each route of administration has unique characteristics that affect the absorption, distribution, metabolism, and excretion of the substance. Below, we provide examples of how to model different routes of administration using differential equations.

=== Intravenous (IV) Administration

Intravenous administration involves directly injecting the substance into the bloodstream. This route ensures immediate availability of the substance in the central compartment (blood plasma). The differential equation for an IV bolus administration is straightforward:

$ ddt(c(t)) = - k_e c(t) $

Where:
- $c(t)$ is the concentration of the substance in the central compartment at time $t$.
- $k_e$ is the elimination rate constant.

=== Oral Administration

Oral administration involves ingesting the substance, which then passes through the gastrointestinal tract before being absorbed into the bloodstream. The process can be modeled using multiple compartments to represent the stomach, intestines, and central compartment. The differential equations for oral administration are:

$
&ddt(c_s(t)) = - k_a c_s(t) \ 
&ddt(c_i(t)) = k_a c_s(t) - k_b c_i(t) \ 
&ddt(c_c(t)) = k_b c_i(t) - k_e c_c(t)
$

Where:
- $c_s(t)$ is the concentration of the substance in the stomach at time $t$.
- $c_i(t)$ is the concentration of the substance in the intestines at time $t$.
- $c_c(t)$ is the concentration of the substance in the central compartment at time $t$.
- $k_a$ is the absorption rate constant from the stomach to the intestines.
- $k_b$ is the absorption rate constant from the intestines to the central compartment.
- $k_e$ is the elimination rate constant.

=== Subcutaneous Administration

Subcutaneous administration involves injecting the substance into the tissue beneath the skin, from where it is absorbed into the bloodstream. The differential equations for subcutaneous administration are:

$
&ddt(c_s(t)) = - k_a c_s(t) \ 
&ddt(c_c(t)) = k_a c_s(t) - k_e c_c(t)
$

Where:
- $c_s(t)$ is the concentration of the substance in the subcutaneous tissue at time $t$.
- $c_c(t)$ is the concentration of the substance in the central compartment at time $t$.
- $k_a$ is the absorption rate constant from the subcutaneous tissue to the central compartment.
- $k_e$ is the elimination rate constant.

=== Modelling Food Intake

While the previous methods of administration were all quite straightforward, more complicated equations exist for different methods of administration.
Typically, the level of detail and the goal of the model are important for determining how to model the administration. An example is
the administration of food. For example, in @odonovan_quantifying_2022, the oral administration of glucose is modelled by a gut compartment
with the following equation:

$ ddt(M_"gut"(t)) = -k_"gut" M_"gut"(t) + "Ra"(t) $

With:

$ "Ra"(t) = sigma dot k_1^sigma dot t^(sigma-1) dot exp(-k_1 t)^sigma dot D_"meal" $

Where this $"Ra"(t)$ function describes the appearance of a glucose dose in the gut compartment over time. We can 
visualize this function in @meal-appearance and see that it describes some sort of delayed appearance, depending on the value of $sigma$.

#figure(image("images/ra.png", width: 50%), caption: [The appearance of a glucose dose in the gut compartment over time, using the equation from the Mixed Meal Model, with different values for $sigma$.])<meal-appearance>

== Modelling repeated doses
A final important aspect of modelling drug administration is the modelling of repeated doses. When a drug is administered multiple times, the concentration of the drug in the body can accumulate over time, leading to different effects compared to a single dose. Therefore,
when studying perturbation of a system, it is important to consider the effect of repeated doses, as this can have a significant impact on the overall behavior of the system. In a clinical setting, this is also important as we want to administer a drug in a way that it reaches its therapeutic concentration in the body, which is often achieved by repeated dosing.

== Building models with Word Equations
We now have the tools to start building models of real systems ourselves. Typically, the first step in building a model is to formulate the 
goal of the model. This can be a simple question, such as "How does the concentration of a drug change over time after administration?" or a more complex question, such as "How does the concentration of a drug change over time in a patient with liver disease?".
The goal of the model ultimately also determines the level of detail that is necessary. For example, if we are only interested in the concentration of a drug in the blood, a simple one-compartment model may suffice. However, if we are interested in the distribution of the drug in different tissues, 
a more complex multi-compartment model may be required.

Furthermore, we may be interested in the effects of a disease, such as diabetes, on specific organ-level processes in the body. To model these effects, we need to consider the interactions between different organs and tissues, as well as the effects of the disease on specific physiological processes.

When we are satisfied with the formulation of a goal, and a level of detail, we then need to dive into the literature, to find the relevant biological information about the processes
we need to model. This information can include studies that investigate the effects of specific drugs, or other perturbations, on the body, the knowledge about
disease pathways, and the physiological processes that are relevant to the model. We can also look in the literature for values for the parameters that are necessary to build the model.

From literature, we can then start building so-called "word equations". These are equations that describe the processes that we want to model in words. 
For example, we can write down that a drug is absorbed from the gut into the bloodstream, that it is metabolized in the liver, and that it is excreted by the kidneys. These word equations can then be translated into mathematical equations, which we can then use to simulate the behavior of the system.

The use of word equations can best be illustrated with an example. In this case, the goal of the model is to accurately describe the response of 
healthy individuals, and individuals suffering from diabetes mellitus type 2 to an ingested solution of glucose. We are particularly interested in the differences between 
these two groups. 

First of all, we will need an equation for glucose. From literature, we know that the glucose in the blood is regulated by the liver, responsible for both production of glucose and storage of glucose, the pancreas, which produces insulin and glucagon, two hormones that regulate glucose levels, and the kidneys, which start
to excrete glucose as soon as the concentration in the blood exceeds a certain threshold. We also know that glucose is absorbed by tissues in both an insulin-dependent and insulin-independent manner. Typically, the brain requires a constant supply of glucose, while muscle and adipose tissue can take up glucose in an insulin-dependent manner.

We can summarize this knowledge in a word equation, which we can then translate into mathematical equations.

$ ddt("glucose") = & "liver"(t) + "gut"(t) - "insulin-dependent uptake"(t) \
& - "insulin-independent uptake"(t) - "kidney"(t) $

This word equation can then be translated into mathematical equations, which we can use to simulate the behavior of the system. For example, for the liver, we can take
the following equation, as used by Maas et al. @maas_physiology-based_2015:

$ "liver"(t) = "EGP"_b - k_I I_"d" (t) - k_3(G_"pl" (t) - G_0) $

We have:
- $"EGP"_b$, the basal endogenous glucose production rate.
- $k_I$, the insulin-dependent rate for reduction in glucose production.
- $I_"d"  (t)$, delay compartment of insulin, used to simplify the long cascade of reactions.
- $k_3$, glucose dependent rate for reduction in glucose production.
- $G_"pl" (t)$, the plasma glucose concentration.
- $G_0$, the setpoint for glucose concentration.

This equation describes the glucose production in the liver, which is regulated by the plasma glucose concentration and the insulin concentration. At $t = 0$, we 
have $I_"d"  (t) = 0$ and $G_"pl" (t) = G_0$, which means that the liver produces glucose at the basal rate in case insulin and glucose are at their fasting levels. We can see that many of the 
aspects of modelling are present in this equation. We have a delay compartment, which represents the time it takes for insulin to reach the liver, we have a setpoint, which is the fasting glucose concentration, and we have a 
mass-action rate that is dependent on the glucose concentration.


= Sensitivity Analysis

#set align(center)
#quote(block: true, attribution: [Eeyore (Winnie the Pooh)])[
  #text(size: 13pt)[_"A little consideration, a little thought for others, makes all the difference."_]
]
#v(2em)
#set align(left)

We often want to know how a model changes when we perform different perturbations to it. A systematic way to study this, is through sensitivity analysis. In sensitivity analysis, we study how the output of a model changes when we change the input parameters. This can be done in two ways: local sensitivity analysis and global sensitivity analysis.

Local sensitivity analysis studies how the output of a model changes when we change a single parameter around a specific _local_ point in parameter space. This is typically done by calculating the partial derivative of the output with respect to the parameter of interest. This can be done either analytically or numerically. Local sensitivity analysis is useful for understanding how a model behaves around a specific set of parameters, but it does not provide full information about the overall behavior of the model.

Usually, this model output is a specific variable of interest, such as the concentration of a drug at a specific time point, or the maximum concentration of a drug in the body. Such a variable is also called an #emph[observable]. For example, in the following model:

$ ddt(c(t)) = - k_c c(t) $

We may be interested in the change of the curve $c(t)$ over time, when we change the parameter $k_c$. Usually, we then define a reference value for the parameter, such as $k_c = 0.1$, and then simulate the model for this parameter value to obtain a reference output.

We can label this reference output as $c_"ref" (t)$. We can then change the parameter $k_c$ by a small amount, such as $delta k_c = 0.01$, and simulate the model again to obtain a new output, which we can label as $c_"new" (t)$. The local sensitivity of the output with respect to the parameter can then be calculated as:

$ S = (sum_t^T (c_"new" (t) - c_"ref" (t))^2) / (delta k_c) $

Here, the numerator represents the sum of squared differences between the new output and the reference output over all time points, and the denominator represents the change in the parameter. This gives us a measure of how sensitive the output is to changes in the parameter. 

A visual way of performing sensitivity analysis is to change specific paramters by a certain percentage, such as 10%, and then plot the output of the model for the reference parameter value and the perturbed parameter value. This can give us a visual representation of how the output changes when we change the parameter.

== Global Sensitivity
The methods before are all examples of local sensitivity analysis. However, in many cases, we are interested in the overall behavior of the model over a wide range of parameter values. Global sensitivity analysis will not be discussed in these lecture notes, but it is good to be aware that local sensitivity analysis is not always sufficient to understand the behavior of a model. In global sensitivity analysis, we study how the output of a model changes when we change multiple parameters simultaneously over a wide range of values. Global sensitivity analysis is useful for understanding the overall behavior of a model, but it can be computationally expensive and time-consuming for very large models.

// == Automatic Differentiation of ODE Models

// == Global Sensitivity Analysis

// = Parameter Estimation

// == Finding a Model that Fits the Data

// == Maximum Likelihood Estimation

// == Model Sloppyness

// == Parameter Identifiability

// == MLE with non-Normal Error Models

// == Maximum a Posteriori Estimation

// = Bayesian Parameter Estimation

// == Creating Samplers with Monte Carlo Simulations

// == Markov Chains

// == Metropolis-Hastings Sampling

// == Gibbs Sampling

// == The NUTS Algorithm

// = Hierarchical Modelling

// == Random Effects

// == Parameter Estimation for Mixed Effects Models









#bibliography("bib-refs.bib", style: "nature.csl")

// Ik ben makelaar in koffi, en woon op de Lauriergracht No 37. Het is mijn gewoonte niet, romans te schrijven, of zulke dingen, en het heeft dan ook lang geduurd, voor ik er toe overging een paar riem papier extra te bestellen, en het werk aan te vangen, dat gij, lieve lezer, zoâven in de hand hebt genomen, en dat ge lezen moet als ge makelaar in koffie zijt, of als ge wat anders zijt. Niet alleen dat ik nooit iets schreef wat naar een roman geleek, maar ik houd er zelfs niet van, iets dergelijks te lezen, omdat ik een man van zaken ben.

// #warning_box(
//   title: "Let op!",
//   body: [Dit document is alleen bedoeld voor intern gebruik binnen Bosman B.V. en mag niet worden gedeeld met derden zonder toestemming.],
// )

// Sedert jaren vraag ik mij af, waartoe zulke dingen dienen, en ik sta verbaasd over de onbeschaamdheid, waarmee een dichter of romanverteller u iets op de mouw durft spelden, dat nooit gebeurd is, en meestal niet gebeuren kan.Als ik in mijn vak -- ik ben makelaar in koffie, en woon op de Lauriergracht No 37 -- aan een principaal -- een principaal is iemand die koffie verkoopt -- een opgave deed, waarin maar een klein gedeelte der onwaarheden voorkwam, die in gedichten en romans de hoofdzaak uitmaken, zou hij terstond Busselinck & Waterman nemen.

// Dat zijn ook makelaars in koffie, doch hun adres behoeft ge niet te weten. Ik pas er dus wel op, dat ik geen romans schrijf, of andere valse opgaven doe. Ik heb dan ook altijd opgemerkt dat mensen die zich met zoiets inlaten, gewoonlijk slecht wegkomen. Ik ben drieënveertig jaar oud, bezoek sedert twintig jaren de beurs, en kan dus voor de dag treden, als men iemand roept die ondervinding heeft. Ik heb al wat huizen zien vallen! En gewoonlijk, wanneer ik de oorzaken naging, kwam het me voor, dat die moesten gezocht worden in de verkeerde richting die aan de meesten gegeven was in hun jeugd.

// == Subsectie
// Ik zeg: waarheid en gezond verstand, en hier blijf ik bij. Voor de Schrift maak ik natuurlijk een uitzondering. De fout begint al van Van Alphen af, en wel terstond bij de eerste regel over die 'lieve wichtjes'. Wat drommel kon die oude heer bewegen, zich uit te geven voor een aanbidder van mijn zusje Truitje die zere ogen had, of van mijn broer Gerrit die altijd met zijn neus speelde? En toch, hij zegt: 'dat hij die versjes zong, door liefde gedrongen'.

// Meer kan u vinden in @section.

// #info_box(
//   title: "Wist je dat?",
//   body: [De eerste aflevering van het Sinterklaasjournaal in 2025 is op 5 november uitgezonden. Het journaal is een traditie die al sinds 2001 bestaat en elk jaar miljoenen kijkers trekt!],
// )

// === Subsubsectie
// Ik dacht dikwijls als kind: 'Man, ik wilde u graag eens ontmoeten, en als ge mij de marmerknikkers weigerde, die ik u vragen zou, of mijn naam voluit in banket -- ik heet Batavus -- dan houd ik u voor een leugenaar.' Maar ik heb Van Alphen nooit gezien. Hij was al dood, geloof ik, toen hij ons vertelde dat mijn vader mijn beste vriend was -- ik hield meer van Pauweltje Winser, die naast ons woonde in de Batavierstraat -- en dat mijn kleine hond zo dankbaar was. We hielden geen honden, omdat ze zo onzindelijk zijn.

// === Nog meer verdeling<section>
// Ik heb dus nooit iets tegen de waarheid gehad, en ik heb er ook nooit iets tegen gehad, dat mensen mij de waarheid vertelden. Ik heb er zelfs nooit iets tegen gehad, dat mensen mij de waarheid vertelden, die ik niet wilde horen. Ik heb er zelfs nooit iets tegen gehad, dat mensen mij de waarheid vertelden, die ik niet wilde horen, zolang ze het maar op een nette manier deden. 

// Kan ik u nog iets anders vertellen? Ja, ik kan u nog wel iets anders vertellen. Ik kan u vertellen dat ik een makelaar in koffie ben, en dat ik op de Lauriergracht No 37 woon. Ik kan u vertellen dat ik al jaren in het vak zit, en dat ik veel ervaring heb. Ik kan u vertellen dat ik altijd eerlijk ben, en dat ik altijd de waarheid vertel. En ik kan u vertellen dat ik nooit iets schrijf wat niet waar is. 

// = Het Sinterklaasjournaal
// Welkom bij het Sinterklaasjournaal van 2025. Dit is de eerste aflevering van het jaar. We zijn blij dat je kijkt en hopen dat je veel plezier beleeft aan dit journaal. We hebben veel leuke dingen voor je in petto, dus blijf kijken!

// == De eerste aflevering
// In deze eerste aflevering van het Sinterklaasjournaal van 2025 hebben we een aantal leuke dingen voor je in petto. We beginnen met een kort overzicht van wat er allemaal gaat gebeuren in de komende weken. We hebben een aantal leuke surprises voor je in petto, en we gaan ook een aantal leuke cadeaus weggeven. We hopen dat je veel plezier beleeft aan het kijken naar dit journaal en dat je veel leert over Sinterklaas en zijn Pieten. 
// #figure(
//   image("assets/sample_img.jpg", width: 100%),
//   caption: [Een voorbeeld van de Sinterklaasviering in 2025. De vrouw op de foto is verkleed als Sinterklaas en zoekt naar antieke Poolse kerstballen op de zolder van het kasteel.],
// )
// Ook dit jaar gaat er weer iets mis! De Sint en zijn Pieten hebben per ongeluk antieke Poolse kerstballen besteld in plaats van de gebruikelijke Sinterklaascadeaus. Gelukkig hebben ze nog tijd om het goed te maken, maar ze hebben jouw hulp nodig! 

// == De speciale rollen van Bert en Ernie
// Bert en Ernie hebben een speciale rol in het Sinterklaasjournaal van 2025. Ze zijn de vaste verslaggevers van het journaal en zorgen ervoor dat alles op rolletjes loopt. Ze zijn altijd vrolijk en enthousiast, en ze hebben een geweldige band met de Sint en zijn Pieten.

// #help_box(
//   title: "Hulp nodig?",
//   body: [Als je hulp nodig hebt bij het maken van je surprise of het vinden van een cadeau, aarzel dan niet om contact op te nemen met de Sint en zijn Pieten. Ze staan altijd klaar om te helpen!],
// )

// == Het verband tussen het verdwenen toiletpapier en de antieke Poolse kerstballen
// Volgens een hardnekkige theorie onder de Pieten is het verdwijnen van het toiletpapier geen toeval, maar onderdeel van een groot complot. Alles begon toen Opa Piet op zolder een mysterieuze doos vond met antieke Poolse kerstballen. Op het eerste gezicht leken het gewone versieringen, maar bij nadere inspectie bleken ze voorzien van geheime inscripties in onleesbaar handschrift.

// Na veel speurwerk ontdekten Bert en Ernie dat deze kerstballen ooit eigendom waren van de beruchte Poolse Toiletpapierfabrikant Stanisław Wcrolski. In de jaren '30 zou hij een revolutionaire formule hebben ontwikkeld voor superzacht toiletpapier, maar uit angst voor concurrentie verstopte hij het recept... in de kerstballen!

// #tip_box(
//   body: [Zorg dat je altijd voldoende toiletpapier in huis hebt, vooral tijdens de drukke Sinterklaasperiode! Het is een goed idee om een extra voorraad aan te leggen, zodat je nooit zonder komt te zitten.]
// )

// Nu, jaren later, zijn de kerstballen per ongeluk bij de Sint terechtgekomen. Maar zodra de ballen in het kasteel arriveerden, begon het toiletpapier op mysterieuze wijze te verdwijnen. Sommige Pieten beweren zelfs dat de kerstballen 's nachts zachtjes ritselen en dat er af en toe een geur van lavendel door de gang zweeft.

// De theorie luidt dat de kerstballen een magneet zijn voor toiletpapier: alles in de buurt verdwijnt spoorloos en wordt op magische wijze naar Polen getransporteerd. Totdat het mysterie is opgelost, moeten de Pieten dus creatief zijn met servetten en keukenrollen!