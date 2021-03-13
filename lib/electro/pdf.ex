defmodule Electro.Pdf do
  @dpi_cm 72.0 / 2.54

  def print_part_label(part) do
    {:ok, tmp_path} = Temp.path(%{suffix: ".pdf"})
    gen_part_label(part, tmp_path)
    # TODO allow configuration of that command
    System.cmd("lp", ["-d", "brother_ql", "-o", "PageSize=62x100", tmp_path])
    File.rm(tmp_path)
  end

  def print_text_label(nil, opts), do: nil
  def print_text_label("", opts), do: nil

  def print_text_label(text, opts) do
    {:ok, tmp_path} = Temp.path(%{suffix: ".pdf"})
    gen_text_label(text, opts, tmp_path)
    # TODO allow configuration of that command
    System.cmd("lp", ["-d", "brother_ql", "-o", "PageSize=62x100", tmp_path])
    File.rm(tmp_path)
  end

  defp txt(nil), do: ""

  defp txt(str) do
    str
    |> String.to_charlist()
    |> Enum.filter(&(&1 in 0..127))
    |> List.to_string()
  end

  defp gen_part_label(part, path) do
    h = 6.2 * @dpi_cm

    Pdf.build([size: [10 * @dpi_cm, h], compress: true], fn pdf ->
      {pdf, _} =
        pdf
        |> Pdf.set_info(title: "Label")
        |> Pdf.set_font("Helvetica", 20)
        |> Pdf.text_at({20, h - 35}, to_string(part.id))
        |> Pdf.text_at({160, h - 35}, part[:location] |> txt())
        |> Pdf.set_font("Helvetica", 12)
        |> Pdf.text_at({20, h - 60}, part[:name] |> txt())
        |> Pdf.text_at({20, h - 80}, part[:mpn] |> txt())
        |> Pdf.text_wrap({20, h - 90}, {200, 60}, part[:description] |> txt())

      Pdf.write_to(pdf, path)
    end)
  end

  defp gen_text_label(text, opts, path) do
    h = 6.2 * @dpi_cm
    w = 10 * @dpi_cm
    lines = String.split(text, "\n")
    hc = length(lines)

    wc =
      Enum.reduce(lines, 0, fn line, len ->
        max(String.length(line), len)
      end)

    s =
      if Map.get(opts, :fit) do
        min(w / wc, h / hc) * 0.75
      else
        20
      end

    Pdf.build([size: [w, h], compress: true], fn pdf ->
      pdf =
        pdf
        |> Pdf.set_info(title: "Label")
        |> Pdf.set_font("Helvetica", s)

      {pdf, _} =
        lines
        |> Enum.reduce({pdf, h - 20}, fn line, {pdf, y} ->
          {Pdf.text_at(pdf, {20, y - s}, txt(line)), y - s}
        end)

      Pdf.write_to(pdf, path)
    end)
  end
end
