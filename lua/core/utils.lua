local M = {}

--- Decode percent-encoded chars in a URI (e.g. %3C → <)
function M.uri_decode(str)
    return (str:gsub("%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end))
end

return M
