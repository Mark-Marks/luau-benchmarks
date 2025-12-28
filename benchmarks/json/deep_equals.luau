-- I'd normally bring in an external, proven library such as CJson (especially with zune's great FFI support) in order to validate the benchmarks, but chances are that if something's wrong then the results of at least one library won't match zunes, be it zunes fault or the librarys.
local function deep_equals<T, U>(lhs: T, rhs: U): boolean
    if type(lhs) ~= "table" or type(rhs) ~= "table" then
        return lhs == rhs
    end

    local lhs_field_count = 0
    for key, value in lhs :: any do
        if type(key) == "userdata" then
            continue
        end

        lhs_field_count += 1
        if not deep_equals(value, (rhs :: any)[key]) then
            return false
        end
    end

    local rhs_field_count = 0
    for key, value in rhs :: any do
        if type(key) == "userdata" then
            continue
        end

        rhs_field_count += 1
    end

    return lhs_field_count == rhs_field_count
end

return deep_equals
