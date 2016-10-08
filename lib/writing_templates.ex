defmodule WritingTemplates do
  def go(%{horizontal_spacing: horizontal_spacing, horizontal_width: horizontal_width}) do
    {:ok, pid} = Gutenex.start_link
    output_filename = "./tmp/template.pdf"
    
    Gutenex.line_width(pid, line_width)
    |> draw_horizontal_lines(horizontal_spacing)
    |> Gutenex.export(output_filename)
    |> Gutenex.stop

    System.cmd("open", [output_filename])
  end

  def go do
    go(%{horizontal_spacing: 9, horizontal_width: 0.5})
  end

  def draw_horizontal_lines(doc, spacing) do
    draw_horizontal_lines(doc, spacing, 0)
  end

  def draw_horizontal_lines(doc, spacing, n) do
    horizontal_line(doc, height(spacing, n))

    tm = top_margin
    case height(spacing, n + 1) do
      h when h > tm -> doc
      _ -> draw_horizontal_lines(doc, spacing, n + 1)
    end
  end
  
  def height(spacing, n) do  
    bottom_margin + n * (spacing / 25.4) * 72 # 72 pt/in 25.4 mm/in spacing mm / line
  end

  def horizontal_line(doc, height) do
    Gutenex.line(doc, {{left_margin, height}, {right_margin, height}})
  end

  def top_margin do
    inches_to_pt(11) - inches_to_pt(1) # 1 in at top of page
  end
  
  def bottom_margin do
    inches_to_pt(0.75)
  end

  def right_margin do
    inches_to_pt(8.5) - inches_to_pt(0.75)
  end
  
  def left_margin do
    inches_to_pt(0.75)
  end

  def inches_to_pt(inches) do
    inches * 72.0
  end

  def mm_to_pt(mm) do
    inches_to_pt(mm / 25.4)
  end

  def line_width do
    0.25
  end
end
