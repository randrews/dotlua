package.path = package.path .. ";" .. os.getenv("HOME") .. "/.lua/?.lua"
package.cpath = package.cpath .. ";" .. os.getenv("HOME") .. "/.lua/?.so"
inspect = require 'inspect'
class = require 'middleclass'

-- Try for lpeg, load it if it's present
local f = io.open(os.getenv("HOME") .. '/.lua/lpeg.so', 'r')
if f then
    f:close()
    lpeg = require 'lpeg'
    re = require 're'
end

-- Some table utilities
setmetatable(table,
             { __call = function(_, ...)
                   return setmetatable({...}, table.mt) end })

table.mt = {
    __index = table,
    __tostring = function(self)
        return "{" .. self:map(tostring):concat(", ") .. "}"
    end
}

function table:map(fn, ...)
    local t = table()
    for _, e in ipairs(self) do
        local r = fn(e, ...)
        t:insert(r)
    end
    return t
end

function table:select(query)
    local t = table()

    self:map( function(el)
            if query(el) then t:insert(el) end
    end)

    return t
end

function table:reduce(fn, init)
    local i = 1
    local accum = init
    if init == nil then
        accum = self[1]
        i = 2
    end

    while i <= #self do
        accum = fn(accum, self[i])
        i = i + 1
    end

    return accum
end

function table:sum()
    return self:reduce( function(a,b) return a+b end, 0 )
end

function table:max(comp)
    return self:reduce( function(a,b)
            if a > b then return a
            else return b end end )
end

function table:min(comp)
    return self:reduce( function(a,b)
            if a < b then return a
            else return b end end )
end

function using(namespace, env)
    env = env or _ENV
    if not getmetatable(env) then setmetatable(env, {}) end
    local mt = getmetatable(env)

    if not mt.__mixins then
        mt.__mixins = {}

        mt.__index = function(_, key)
            for _, module in ipairs(mt.__mixins) do
                if module[key] then return module[key] end
            end
        end
    end

    table.insert(mt.__mixins, namespace)
end
