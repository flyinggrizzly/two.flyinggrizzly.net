function post_date_from_filename(doc)
  local m = doc.meta
  if m.date == nil then
    pattern = "(%d%d%d%d)%-(%d%d)%-(%d%d)%-[%a%d][%a%d%-]+[%a%d]%.md"
    --matches = string.match(pandoc.path.filename(), pattern)
    --year = matches[0]
    --month = matches[1]
    --day = matches[2]


    print(m)

    --m.date = os.date({year=year, month=month, day=day})
    --m.date = os.time

    return m
  end
end

return {{
  Pandoc = function(doc)
    print(doc)
    local meta = insert_post_date_from_filename(doc)

    return pandoc.Pandoc(doc.blocks, meta)
  end
  }}
