defmodule WritingTemplates.Page do
  @doc """
    All measurements are in pdf points (roughly 72/in).

    Margins are relative to the origin in the lower left corner of the page.

    Vertical line angle is measured from the horizontal in degrees. 45 would go from 
    lower left to upper right. 52 was standard for Spencerian, 60-75 is modern.
  """
  defstruct left_margin: 72,
    right_margin: 540,
    top_margin: 684,
    bottom_margin: 72,
    horizontal_line_width: 0.25,
    horizontal_line_spacing: 25.5, # ~ 9mm/wide ruled
    vertical_line_width: 0.1,
    vertical_line_spacing: 36,
    vertical_line_angle: 75
end
