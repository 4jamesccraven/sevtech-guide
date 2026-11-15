#let bg_colour_light = rgb("8d99ae")
#let bg_colour_dark  = rgb("2b2d42")
#let fg_colour       = rgb("cdd6f4")

#let biome_matrix = json("biome-matrix.json")

// Colours
#let hum_cols    = biome_matrix.at("humidity_colours").map(rgb)
#let temp_cols   = biome_matrix.at("temperature_colours").map(rgb)
// Data for heat/humidity matrix
#let matrix      = biome_matrix.at("biomes")
#let mat_columns = biome_matrix.at("humidity")
#let mat_rows    = matrix.keys()
// Data for map
#let map_columns = biome_matrix.at("climate_map").at("columns")
#let map_rows    = biome_matrix.at("climate_map").at("rows")
#let map_data    = biome_matrix.at("climate_map").at("data")

// Helper function(s)
#let fill_count(count) = { (1fr,) * count }
#let header_text(body) = { smallcaps([#body]) }

// Preamble
#set page(
  paper: "a3",
  margin: 12mm,
  flipped: true,
  fill: bg_colour_light,
)
#set text(fill: fg_colour, font: "Atkinson Hyperlegible")
#set align(horizon + center)

// Auto invert text_colour based on luminosity.
#show table.cell: it => {
  let bg = if type(it.fill) == color { it.fill } else { bg_colour_dark }
  let lightness = oklab(bg).components().at(0)
  set text(fill: if lightness < 65% { fg_colour } else { bg_colour_dark })
  it
}

// Title
#align(left, pad(left: 6%, right: 6%, text(size: 26pt, weight: "bold", fill: bg_colour_dark)[
  SevTech Biome Reference #h(1fr) #text(size: 18pt, weight: "light")[by 4jamesccraven]
]))
#line(length: 90%, stroke: 1pt + bg_colour_dark)

// Information
#box(
  width: 95%,
  height: 90%,
  grid(
    columns: (40%, 60%),
    rows: (60%, 40%),
    gutter: 15pt,
    fill: bg_colour_dark,
    // ====[ Biome Map ]====
    [
      #set text(size: 16pt, weight: "bold")
      #let b_width = 300pt
      #box(
        width: b_width,
        height: b_width,
        stroke: none,
      )[
        #table(
          columns: (60pt,) + fill_count(map_columns.len()),
          rows: (40pt,) + fill_count(map_rows.len()),
          stroke: 1.5pt + bg_colour_light,
          fill: (x, y) => {
            if x == 0 and y > 0 {
              let curr_temp = map_rows.at(y - 1)
              let temp_idx = mat_rows.position(s => s == curr_temp)
              temp_cols.at(temp_idx)
            } else if y == 0 and x > 0 {
              let curr_hum = map_columns.at(x - 1)
              let hum_idx = mat_columns.position(s => s == curr_hum)
              hum_cols.at(hum_idx)
            } else if x > 0 and y > 0 {
              let curr_temp = map_rows.at(y - 1)
              let temp_idx = mat_rows.position(s => s == curr_temp)
              let curr_hum = map_columns.at(x - 1)
              let hum_idx = mat_columns.position(s => s == curr_hum)
              temp_cols.at(temp_idx).mix(hum_cols.at(hum_idx))
            }          },
          table.header(
            [], ..map_columns
              .map(s => if s == "average" { "avg." } else { s })
              .map(header_text)
          ),
          ..map_rows
            .zip(map_data)
            .map(((temp_header, rest)) =>
              (header_text(temp_header),)
              + rest.map(comb => [
                #set text(size: 12pt)
                #comb.split("/").map(smallcaps).join("/\n")
              ])
            ).flatten()
          )

          #set text(size: 16pt)
          #place(
            top + center,
            dy: -36pt,
            [
              X #linebreak()
              W #h(1fr) #sym.arrow #h(1fr) E
            ]
          )

          #place(
            left + horizon,
            dx: -36pt,
            stack(
              dir: ttb,
              align(right)[N],
              1fr,
              align(right)[Z #box(rotate(90deg, sym.arrow))],
              1fr,
              align(right)[S],
            )
          )
        ]
    ],
    // ====[ Biome Matrix ]====
    grid.cell(
      rowspan: 2,
      [
        #set text(size: 18pt, weight: "bold")
        == Heat/Humidity Biome Matrix
        #set text(fill: bg_colour_light)

        #box(
          width: 90%,
          height: 90%,
          table(
            columns: (60pt,) + fill_count(mat_columns.len()),
            rows: (40pt,) + fill_count(matrix.len()),
            stroke: 2pt + bg_colour_light,
            fill: (x, y) => {
              if x == 0 and y > 0 {
                temp_cols.at(y - 1)
              } else if y == 0 and x > 0 {
                hum_cols.at(x - 1)
              } else if x > 0 and y > 0 {
                temp_cols.at(y - 1).mix(hum_cols.at(x - 1))
              }
            },
            table.header(
              [], ..mat_columns.map(title => [#header_text(title)])
            ),
            ..matrix
              .pairs()
              .map(((temp_header, hums)) => (
                // Each temperature key is the left row header
                header_text(temp_header),
                // Discard nested keys...
                ..hums.values().map(vals =>
                  [
                    #set text(size: 11pt)
                    #set align(top + left)
                    #list(
                        marker: sym.diamond.filled,
                        ..vals
                          .sorted(key: b => b.at("name"))
                          .map(b => [
                            #b.at("name")
                            #if "mod" in b {
                              [
                                #set text(size: 10pt)
                                (#b.at("mod"))
                              ]
                            }
                          ])
                    )
                  ])
              )
            ).flatten()
          )
        )
      ]
    ),
    [
      #set text(size: 17pt)
      #box(
        width: 90%,
        height: 90%,
      )[
        #set align(horizon + left)
        == Usage Notes
        + Identify the HH classification of your current biome (e.g., Savanna #sym.arrow #smallcaps([warm/dry]))
        + Identify the HH classification of your target biome (e.g., Roofed Forest #sym.arrow #smallcaps([warm/wet]))
        + Consult the map above and move towards the target biome. *Do not move diagonally* (NW, SE, etc.)! (e.g., East to go from Savanna to Roofed Forest)
        + When you enter a new biome, repeat from step 1 until you are at your destination.
      ]
    ]
  )
)
#place(bottom+left, dy: 20pt)[
  #set text(fill: bg_colour_dark, size: 16pt, weight: "semibold")
  #pad(left: 3%, right: 2%)[
    #sym.copyright 2026 James C. Craven #sym.dot CC BY 4.0
    #h(8pt)
    #text(size: 14pt, weight: "light")[made with typst]
    #h(1fr) https://github.com/4jamesccraven/sevtech-guide
  ]
]
