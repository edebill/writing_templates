defmodule WritingTemplates do
  def go(page = %WritingTemplates.Page{horizontal_line_spacing: horizontal_spacing, horizontal_line_width: horizontal_width}) do
    {:ok, pid} = Gutenex.start_link
    output_filename = "./tmp/template.pdf"
    
    Gutenex.line_width(pid, line_width)
    |> draw_horizontal_lines(page)
    |> Gutenex.export(output_filename)
    |> Gutenex.stop

    System.cmd("open", [output_filename])
  end

  def go do
    go(%WritingTemplates.Page{})
  end

  def draw_horizontal_lines(doc, page) do
    draw_horizontal_lines(doc, page, 0)
  end

  def draw_horizontal_lines(doc, page, n) do
    horizontal_line(doc, page, height(page.horizontal_line_spacing, n))
    spacing = page.horizontal_line_spacing
    tm = top_margin
    case height(spacing, n + 1) do
      h when h > tm -> doc
      _ -> draw_horizontal_lines(doc, page, n + 1)
    end
  end
  
  def height(spacing, n) do  
    bottom_margin + n * spacing
  end

  def horizontal_line(doc, page, height) do
    Gutenex.line(doc, {{page.left_margin, height}, {page.right_margin, height}})
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
