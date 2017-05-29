defmodule WritingTemplates do
  def go(%WritingTemplates.Page{} = page) do
    pdf = :eg_pdf.new()
    output_filename = "./tmp/template.pdf"

    pdf
    |> init
    |> add_page(page, 1)
    |> add_page(page, 2)


    {serialized, _page_no} = :eg_pdf.export(pdf)
    :ok = :file.write_file(String.to_charlist(output_filename), serialized)

    :eg_pdf.delete(pdf)
    System.cmd("open", [output_filename])
  end

  def go do
    go(%WritingTemplates.Page{})
  end

  def init(pdf) do
    :eg_pdf.set_pagesize(pdf, :letter)

    pdf
  end

  def add_page(doc, page, 1) do
    add_page(doc, page)
  end

  def add_page(doc, page, _n) do
    :eg_pdf.new_page(doc)
    add_page(doc, page)
  end

  def add_page(doc, page) do
    :eg_pdf.set_line_width(doc, page.horizontal_line_width)
    :eg_pdf.set_dash(doc, :solid)
    :eg_pdf.set_stroke_color(doc, :lightgray)

    doc 
    |> draw_horizontal_lines(page)
    |> draw_vertical_lines(page)
  end

  def draw_horizontal_lines(doc, page) do
    draw_horizontal_lines(doc, page, 0)
  end

  def draw_horizontal_lines(doc, page, n) do
    horizontal_line(doc, page, height(page, n))

    tm = page.top_margin
    case height(page, n + 1) do
      h when h > tm -> doc
      _ -> draw_horizontal_lines(doc, page, n + 1)
    end
  end

  def draw_vertical_lines(doc, page) do
    :eg_pdf.set_line_width(doc, page.vertical_line_width)

    doc
    |> draw_vertical_lines_across_bottom(page, 0)
    |> draw_vertical_lines_up_side(page, 1)
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
    
    :eg_pdf.line(doc, origin_x, origin_y, end_x, end_y)    
    doc
  end

  def height(page, n) do  
    page.bottom_margin + n * page.horizontal_line_spacing
  end

  def horizontal_line(doc, page, height) do
    :eg_pdf.line(doc, page.left_margin, height, page.right_margin, height)
    doc
  end

  def inches_to_pt(inches) do
    inches * 72.0
  end

  def mm_to_pt(mm) do
    inches_to_pt(mm / 25.4)
  end
end
