-- This filter removes colspecs, preventing Pandoc from generating <colgroup>
function Table(tbl)
  tbl.colspecs = nil  -- Remove column specifications
  return tbl
end