defmodule Electro.SExprs do
  import NimbleParsec

  def parse_float(els) when is_binary(els) do
    Float.parse(els)
    |> elem(0)
  end

  def parse_float(els) do
    Enum.join(els, "")
    |> Float.parse()
    |> elem(0)
  end

  date =
    integer(4)
    |> ignore(string("-"))
    |> integer(2)
    |> ignore(string("-"))
    |> integer(2)

  time =
    integer(2)
    |> ignore(string(":"))
    |> integer(2)
    |> ignore(string(":"))
    |> integer(2)
    |> optional(string("Z"))

  def sexprs do
    integer(4)
    |> ignore(string("-"))
    |> integer(2)
    |> ignore(string("-"))
    |> integer(2)
  end

  sym = ascii_string([?a..?z, ?_, ?A..?Z], min: 1)

  qstr =
    ignore(string("\""))
    |> optional(
      repeat(
        choice([
          ascii_string([not: ?", not: ?\\], min: 1),
          string(~S(\")) |> replace(~S("))
        ])
      )
    )
    |> concat(ignore(string("\"")))

  num =
    optional(string("-"))
    |> ascii_string([?0..?9], min: 1)
    |> optional(string(".") |> ascii_string([?0..?9], min: 1))
    |> wrap()
    |> map(:parse_float)

  uuid =
    ascii_string([?a..?z, ?0..?9], 8)
    |> string("-")
    |> ascii_string([?a..?z, ?0..?9], 4)
    |> string("-")
    |> ascii_string([?a..?z, ?0..?9], 4)
    |> string("-")
    |> ascii_string([?a..?z, ?0..?9], 4)
    |> string("-")
    |> ascii_string([?a..?z, ?0..?9], 12)
    |> wrap()
    |> map({Enum, :join, []})

  ws = repeat(ascii_char([0x20, 0xA, 0xD]))

  defparsec(
    :sexprs,
    ignore(ws)
    |> ignore(string("("))
    |> ignore(ws)
    |> repeat(
      lookahead_not(string(")"))
      |> choice([parsec(:sexprs), uuid, sym, qstr, num])
      |> ignore(ws)
    )
    |> ignore(ws)
    |> ignore(string(")"))
    |> wrap(),
    debug: true
  )
end
