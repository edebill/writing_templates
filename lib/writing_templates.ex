defmodule WritingTemplates do
  def go(%{horizontal_spacing: horizontal_spacing, horizontal_width: horizontal_width}) do
    {:ok, pid} = Gutenex.start_link
    Gutenex.line_width(pid, horizontal_width)
    |> horizontal_line(height(horizontal_spacing, 0))
    |> horizontal_line(height(horizontal_spacing, 1))
    |> horizontal_line(height(horizontal_spacing, 2))
    |> horizontal_line(height(horizontal_spacing, 3))
    |> horizontal_line(height(horizontal_spacing, 4))
    |> horizontal_line(height(horizontal_spacing, 5))
    |> horizontal_line(height(horizontal_spacing, 6))
    |> Gutenex.export("./tmp/template.pdf")
    |> Gutenex.stop
  end

  def go do
    go(%{horizontal_spacing: 9, horizontal_width: 0.5})
  end

  def height(spacing, n) do  
    n * (spacing / 25.4) * 72 # 72 pt/in 25.4 mm/in spacing mm / line
  end

  def horizontal_line(doc, height) do
    Gutenex.line(doc, {{0, height}, {100, height}})
  end

  def line_width do
    0.3
  end
end
