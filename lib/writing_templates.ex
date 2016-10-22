defmodule WritingTemplates do
  def go(page = %WritingTemplates.Page{horizontal_line_spacing: horizontal_spacing, horizontal_line_width: horizontal_width}) do
    {:ok, pid} = Gutenex.start_link
    output_filename = "./tmp/template.pdf"
    
    Gutenex.line_width(pid, page.horizontal_line_width)
    |> draw_horizontal_lines(page)
    |> draw_vertical_lines(page)
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
    horizontal_line(doc, page, height(page, n))
    spacing = page.horizontal_line_spacing
    tm = page.top_margin
    case height(page, n + 1) do
      h when h > tm -> doc
      _ -> draw_horizontal_lines(doc, page, n + 1)
    end
  end

  def draw_vertical_lines(doc, page) do
    Gutenex.line_width(doc, page.vertical_line_width)
    |> draw_vertical_lines_across_bottom(page, 0)
  end
  
  def draw_vertical_lines_across_bottom(doc, page, n) do
    doc = draw_vertical_line(doc, page, origin_x(page, n), page.bottom_margin)

    rm = page.right_margin
    case origin_x(page, n + 1) do
      h when h > rm -> doc
      _ -> draw_vertical_lines_across_bottom(doc, page, n + 1)
    end
    
  end

  def origin_x(page, n) do
    page.left_margin + n * page.vertical_line_spacing
  end

  def draw_vertical_line(doc, page, origin_x, origin_y) do
    end_x = page.right_margin
    end_y = (end_x - origin_x) * :math.tan((page.vertical_line_angle/360) * 2 * :math.pi) + page.bottom_margin

    if end_y > page.top_margin do
      end_y = page.top_margin
      end_x = origin_x + (end_y - origin_y) / :math.tan((page.vertical_line_angle/360) * 2 * :math.pi)
    end
    
    Gutenex.line(doc, {{origin_x, origin_y}, {end_x, end_y}})    
  end

  def height(page, n) do  
    page.bottom_margin + n * page.horizontal_line_spacing
  end

  def horizontal_line(doc, page, height) do
    Gutenex.line(doc, {{page.left_margin, height}, {page.right_margin, height}})
  end

  def inches_to_pt(inches) do
    inches * 72.0
  end

  def mm_to_pt(mm) do
    inches_to_pt(mm / 25.4)
  end
end
