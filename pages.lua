local modelString = resolveModel(props)

local pages = {}
table.insert(pages, { name = modelString })
table.insert(pages, { name = "Groups and Trunks" })
table.insert(pages, { name = "Neighbors" })
table.insert(pages, { name = "Configuration" })

return pages
