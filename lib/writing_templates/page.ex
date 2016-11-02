defmodule WritingTemplates.Page do
  @doc """
    All measurements are in pdf points (roughly 72/in).

    Margins are relative to the origin in the lower left corner of the page.

    Vertical line angle is measured from the horizontal in degrees. 45 would go from 
    lower left to upper right. 52 was standard for Spencerian, 60-75 is modern.
  """
  defstruct left_margin: 72,
    right_margin: 540,
    top_margin: 702,
    bottom_margin: 72,
    horizontal_line_width: 0.25,
    horizontal_line_spacing: 25.5, # ~ 9mm/wide ruled
    vertical_line_width: 0.1,
    vertical_line_spacing: 36,
    vertical_line_angle: 60

    
  def trim_for_whole_lines(%WritingTemplates.Page{} = req) do
    requested_height = lined_height(req)
    num_lines = requested_height / req.horizontal_line_spacing
    fractional = num_lines - trunc(num_lines)
    
    case fractional do
      0 -> req
      _ -> resize_and_center(req, trunc(num_lines) * req.horizontal_line_spacing)
    end
  end

  def resize_and_center(orig, new_height) do
    orig_height = lined_height(orig)
    fudge = (orig_height - new_height) / 2
    %WritingTemplates.Page{ orig | bottom_margin: orig.bottom_margin + fudge,
                                   top_margin: orig.top_margin - fudge }
  end

  def lined_height(%WritingTemplates.Page{} = req) do
    req.top_margin - req.bottom_margin
  end
end
