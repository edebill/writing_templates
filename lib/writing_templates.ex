defmodule WritingTemplates do
  def go(%WritingTemplates.Page{} = page) do
    {:ok, pid} = Gutenex.start_link
    output_filename = "./tmp/template.pdf"

    pid
    |> add_page(page, 1)
    |> Gutenex.export(output_filename)
    |> Gutenex.stop

    System.cmd("open", [output_filename])
  end

  def go do
    go(%WritingTemplates.Page{})
  end

  def multi_page do
    multi_page %WritingTemplates.Page{}
  end
  
  def multi_page(%WritingTemplates.Page{} = page_spec) do
    {:ok, pid} = Gutenex.start_link
    output_filename = "./tmp/template_multi.pdf"

    pid
    |> add_page(page_spec, 1)
    |> Gutenex.add_page
    |> add_page(page_spec, 2)
    |> Gutenex.add_page
    |> Gutenex.export(output_filename)
    |> Gutenex.stop

    System.cmd("open", [output_filename])
  end

  def add_page(doc, page_spec, n) do
    IO.puts "     my add_page #{n}"
    doc
    |> Gutenex.line_width(page_spec.horizontal_line_width)
    |> draw_horizontal_lines(page_spec)
    |> draw_vertical_lines(page_spec)
  end

  def draw_horizontal_lines(doc, page_spec) do
    draw_horizontal_lines(doc, page_spec, 0)
  end

  def draw_horizontal_lines(doc, page_spec, n) do
    horizontal_line(doc, page_spec, height(page_spec, n))

    tm = page_spec.top_margin
    case height(page_spec, n + 1) do
      h when h > tm -> doc
      _ -> draw_horizontal_lines(doc, page_spec, n + 1)
    end
  end

  def draw_vertical_lines(doc, page) do
    Gutenex.line_width(doc, page.vertical_line_width)
    |> draw_vertical_lines_up_side(page, 1)
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

  def draw_vertical_lines_up_side(doc, page, n) do
    doc = draw_vertical_line(doc, page, page.left_margin, origin_y(page, n))

    tm = page.top_margin
    case origin_y(page, n + 1) do
      h when h > tm -> doc
      _ -> draw_vertical_lines_up_side(doc, page, n + 1)
    end
  end

  def origin_x(page, n) do
    page.left_margin + n * page.vertical_line_spacing
  end

  def origin_y(page, n) do
    page.bottom_margin + n * page.vertical_line_spacing * :math.tan((page.vertical_line_angle/360) * 2 * :math.pi)
  end

  def draw_vertical_line(doc, page, origin_x, origin_y) do
    possible_end_x = page.right_margin
    possible_end_y = (possible_end_x - origin_x) * :math.tan((page.vertical_line_angle/360) * 2 * :math.pi) + origin_y

    tm = page.top_margin
    end_y = case possible_end_y do
              y when y > tm -> tm
              _ -> possible_end_y
            end
    
    end_x = origin_x + (end_y - origin_y) / :math.tan((page.vertical_line_angle/360) * 2 * :math.pi)
    
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
