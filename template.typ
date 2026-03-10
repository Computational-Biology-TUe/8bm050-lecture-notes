#import "@preview/showybox:2.0.4": showybox

#let bosman_colors = (
    primary: rgb("#459396"),
    secondary: rgb("#bb5432"),
    darker: rgb("#459396").darken(25%),
    text: rgb("#000000"),
    title: rgb("#ffffff"),
    emph: rgb("#3f5bb0"),
    link: rgb("#459396"),
    light: rgb("#459396").lighten(25%),
    warning: rgb("#bb5432"),
    info: rgb("#3f5bb0"),
  )

#let template(

  title: "Booklet",
  author: none,
  subtitle: none,
  department: none,
  internal: none,
  date: datetime.today(),
  copyright: none,
  theme: bosman_colors,
  font: "Source Sans 3",
  head: "Barlow",
  outline_title: "Contents",
  body
) = {

set text(font: font, size: 11pt)
show link: it => [#text(fill: theme.link)[#underline(it)]]


// Page setup
set page(
  paper: "a4",
  footer: context 
    (if (here().position().page == 3) {
      return text(
        font: font,
        weight: 400,
        fill: theme.text,
        size: 9pt,
        style: "italic", []
        // [The work described in this thesis has been carried out in accordance with the #link("https://assets.w3.tue.nl/w/fileadmin/2019-01-31%20TUe%20Code%20of%20Scientific%20Conduct%20ENG.pdf?_gl=1*1pfx23e*_gcl_au*NDEzNTYzMTg4LjE3NDQ1NTIzOTQ.*_ga*MTI2OTEwNDI2OC4xNzQ0NTUyMzkz*_ga_JN37M497TT*MTc0NDY0MTA5OC41LjEuMTc0NDY0MTM4NC41My4wLjA.", "TU/e Code of Scientific Conduct").]
      )
    } else {
      return [] 
    }),
  footer-descent: 30%,
  margin: (bottom: 12%, top:15%)
)

// Paragraph setup
set par(
  first-line-indent: (amount: 0pt, all: true),
  spacing: 1.5em,
  justify: true,
)

// Contents heading
show heading.where(
  level: 1
): it => [
  #pagebreak(weak: true)
  #block(width: 100%)[
  #text(
      size: 20pt,
      weight: "medium",
      fill: theme.primary,
      font: head,
      align(top + left, it.body),
    )
]]

set page(
  fill: gradient.linear(theme.primary, theme.title, angle: 45deg),
  header: align(right)[#image("assets/tue_logo_white.svg", width: 15%)]
)

// Background image first page
// place(
//   top,
//   float: false,
//   image("assets/Asset 3.png", height: 120%, width: 140%),
//   dx: -20%,
//   dy: -20%,
// )
// Title block background
place(
  left + top,
  float: true,
  grid(
    columns: (auto,),
    rows: (auto,1cm),
    [
      #if internal != none {
      block(width: auto, text(12pt, font: head, weight: "medium", fill: theme.title.transparentize(30%), upper(internal)))
      }
      #block(width: auto, inset: (top: 2pt, bottom: 2pt), text(18pt, font: head, weight: "medium", fill: theme.title, title))
      // Subtitle
      #if subtitle != none {
        block(width: auto, text(12pt, font: head, fill: theme.title, subtitle))
      }
      // Authors and affiliations
      #if author != none {
        grid(columns: 1, rows: 3, gutter: 12pt,
          text(11pt, font: head, weight: 400, author.name, fill: theme.title),
          if type(date) == datetime {
            text(11pt, font: head, weight: 300, date.display("[day] [month repr:long], [year]"), fill: theme.title)
          } else {
            text(11pt, font: head, weight: 300, fill: theme.title, date)
          },
        )
      }
    ],
      rect(width: 15%, height: 15%, fill: theme.title),
  ),
  dx: 0%,
  dy: 0%,
)

// Department block
place(
  center + bottom,
  float: true,
  block(
    width: 100%, 
    height: 20%,
    inset: 0%,
    [
      #if department != none {
        align(horizon + left)[
          #text(12pt, font: head, weight: 600, theme.title.transparentize(30%), upper(department))
        ]
      }
    ]
  ),
  dx: 0%,
)

set page(
  fill: white,
  header: auto,
  margin: auto
)

pagebreak(to: "odd")

image("assets/8bm050-logo.svg", width: 35%)

block(width: 100%, inset: (top: 2pt, bottom: 2pt), text(18pt, font: head, weight: "medium", fill: theme.text, title))



align(
  bottom + left,
  [
    #text(9pt, font: font, weight: 400, theme.text, [
      #if copyright != none {
        copyright
      } else {
        "© " + datetime.today().display("[year]") + " " + author.name
      }
    ])

    #if author.email != none {
      text(9pt, font: font, weight: "bold", theme.text, "Contact")
      linebreak()
      text(9pt, font: font, weight: 400, theme.text, [
      #author.name (#link("mailto:"+author.email))
      ])
      linebreak()
      text(9pt, font: font, weight: 400, theme.text, [
        #box(height: 12pt, image("icons/github-mark.svg"), clip: true, baseline: 25%) #h(0.5em) #link("https://github.com/Computational-Biology-TUe/8bm050-lecture-notes", [Computational-Biology-TUe/8bm050-lecture-notes])
      ])
    } else {
      []
    }
  ]
)

pagebreak(to: "odd")

// Print table of contents
outline(
  title: outline_title
)

pagebreak(to: "odd")

// Reset page counter
counter(page).update(1)
set page(
  paper: "a4",
  footer: context {
  if calc.even(counter(page).get().first()) {
    align(left, counter(page).display("1"))
} else {
    align(right, counter(page).display("1"))
  }
},
)

// Heading setup
set heading(
  numbering: "1.1.1.a"
)
show heading.where(
  level: 1
): it => [
  #pagebreak(weak: true)
  #if it.numbering != none {
    block(width: 100%, below: -20pt)[
    #grid(
      columns: (auto, auto),
      gutter: 1em,
      place(
      top ,
      dy: -0.6em,
      float: true,
        rect(
          fill: theme.primary,
          radius: (
            top-left: 0em,
            top-right: 2.5em,
            bottom-left: 2.5em,
            bottom-right: 2.5em
          ),
          inset: 0.6em,
          text(
            size: 20pt,
            weight: "bold",
            font: head,
            fill: theme.title,
            counter(heading).display(),
          )
        )
      ),
    text(
        size: 20pt,
        weight: "bold",
        fill: theme.primary,
        font: head,
        it.body,
      ),
    )
    #v(1em)
  ]
} else {
    block(width: 100%)[
      #text(
        size: 20pt,
        weight: "bold",
        fill: theme.primary,
        font: head,
        it.body,
      )
    ]
  }
]

show heading.where(
  level: 2
): it => [
  #block(width: 100%)[
    #text(
      size: 16pt,
      weight: "medium",
      fill: theme.primary,
      font: head,
      it,
    )
  ]
]

show heading.where(
  level: 3
): it => [
  #block(width: 100%)[
    #text(
      size: 12pt,
      weight: "medium",
      fill: theme.primary,
      font: head,
      it,
    )
  ]
]

// Image setup
show figure.where(
  kind: image
): set figure(supplement: "Fig.")

show math.equation: set math.equation(supplement: "Eq.")

show figure.where(
  kind: table
): set figure(supplement: "Table")

set heading(supplement: "Section")

set figure.caption(separator: [ --- ])

show figure.caption: c => [#align(left)[
  #text(fill: theme.secondary, weight: "bold")[
    #c.supplement #context c.counter.display(c.numbering)
  ]
  #text(style: "italic")[#c.separator#c.body]
]]


show heading.where(level: 1): it => {
  counter(math.equation).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: raw)).update(0)
  it
}
set math.equation(numbering: num =>
  numbering("(1.1)", counter(heading).get().first(), num)
)
set figure(numbering: num =>
  numbering("1.1", counter(heading).get().first(), num)
)




body
}

#let c_example = counter("example")


#let example_box(
  body: [],
  title: "Example",
  breakable: false
) = {
  c_example.step()
  showybox(
    frame: (
      border-color: bosman_colors.primary,
      title-color: bosman_colors.primary,
      body-color: white,
      footer-color: black.lighten(95%),
      thickness: 2.5pt,
      radius: (top-right: 5%, bottom-right: 5%, bottom-left: 5%, top-left: 5%),
      body-inset: (
        bottom: 2em, top: 1em, left: 3em, right: 3em
      )
    ),
    title-style: (
      color: white,
      weight: "bold",
      align: top+left,
      sep-thickness: 0pt,
      boxed-style: (
        ranchor: (
          x: center,
          y: horizon
        ),
        radius: (top-right: 15pt, bottom-right: 15pt, bottom-left: 15pt, top-left: 0pt),
      )
    ),
    sep: (
      thickness: 0pt,
    ),
    body-style: (
      color: bosman_colors.primary,
    ),
    footer-style: (
      sep-thickness: 0pt,
    ), title: [#box(height: 18pt, image("icons/bulb.svg"), clip: true, baseline: 25%) #text(12pt, [#title #context counter(heading).get().at(0).#context c_example.display()], font: "Helvetica")],
    breakable: breakable,
    body,
  )
}

#let warning_box(
  body: [],
  title: "Tip",
) = {
  showybox(
    frame: (
      border-color: bosman_colors.warning,
      title-color: bosman_colors.warning,
      body-color: white,
      footer-color: black.lighten(95%),
      thickness: 2.5pt,
      radius: (top-right: 5%, bottom-right: 5%, bottom-left: 5%, top-left: 5%),
      body-inset: (
        bottom: 2em, top: 1em, left: 3em, right: 3em
      )
    ),
    title-style: (
      color: white,
      weight: "bold",
      align: top+left,
      sep-thickness: 0pt,
      boxed-style: (
        ranchor: (
          x: center,
          y: horizon
        ),
        radius: (top-right: 15pt, bottom-right: 15pt, bottom-left: 15pt, top-left: 0pt),
      )
    ),
    sep: (
      thickness: 0pt,
    ),
    body-style: (
      color: bosman_colors.warning,
    ),
    footer-style: (
      sep-thickness: 0pt,
    ), title: [#box(height: 18pt, image("icons/warn.svg"), clip: true, baseline: 25%) #text(12pt, title, font: "Helvetica")],
    body,
  )
}

#let help_box(
  body: [],
  title: "Help",
) = {
  showybox(
    frame: (
      border-color: bosman_colors.secondary.darken(25%),
      title-color: bosman_colors.secondary.darken(25%),
      body-color: white,
      footer-color: black.lighten(95%),
      thickness: 2.5pt,
      radius: (top-right: 5%, bottom-right: 5%, bottom-left: 5%, top-left: 5%),
      body-inset: (
        bottom: 2em, top: 1em, left: 3em, right: 3em
      )
    ),
    title-style: (
      color: white,
      weight: "bold",
      align: top+left,
      sep-thickness: 0pt,
      boxed-style: (
        ranchor: (
          x: center,
          y: horizon
        ),
        radius: (top-right: 15pt, bottom-right: 15pt, bottom-left: 15pt, top-left: 0pt),
      )
    ),
    sep: (
      thickness: 0pt,
    ),
    body-style: (
      color: bosman_colors.secondary.darken(25%),
    ),
    footer-style: (
      sep-thickness: 0pt,
    ), title: [#box(height: 18pt, image("icons/help.svg"), clip: true, baseline: 25%) #text(12pt, title, font: "Helvetica")],
    body,
  )
}

#let info_box(
  body: [],
  title: "Info",
) = {
  showybox(
    frame: (
      border-color: bosman_colors.info,
      title-color: bosman_colors.info,
      body-color: white,
      footer-color: black.lighten(95%),
      thickness: 2.5pt,
      radius: (top-right: 50%, bottom-right: 0pt, bottom-left: 50%, top-left: 50%),
      body-inset: (
        bottom: 2em, top: 1em, left: 3em, right: 3em
      )
    ),
    title-style: (
      color: white,
       weight: "bold",
      align: top+left,
      sep-thickness: 0pt,
      boxed-style: (
        ranchor: (
          x: center,
          y: horizon
        ),
        radius: (top-right: 15pt, bottom-right: 15pt, bottom-left: 15pt, top-left: 0pt),
      )
    ),
    sep: (
      thickness: 0pt,
    ),
    body-style: (
      color: bosman_colors.info,
    ),
    footer-style: (
      sep-thickness: 0pt,
    ), title: [#box(height: 18pt, image("icons/info.svg"), clip: true, baseline: 25%) #text(12pt, title, font: "Helvetica")],
    body,
  )
}