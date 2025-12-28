local deep_equals = require("./deep_equals")
local generate_profile = require("@generators/profile")
local runner = require("@lib/runner")

local lute_json = require("@std/json")
local lute_json_encode = lute_json.serialize
local lute_json_decode = lute_json.deserialize

runner {
    title = "Encode",
    benchmarks = {
        ["lute"] = @native function(input)
            return lute_json_encode(input)
        end,
    },
    generator = generate_profile,
    validator = function(input, output)
        local decoded = lute_json_decode(output)
        return deep_equals(input, decoded)
    end,
    runs = 100_000,
    warmup_runs = 1_000,
}

runner {
    title = "Decode",
    benchmarks = {
        ["lute"] = @native function(input)
            return lute_json_decode(input)
        end,
    },
    generator = function()
        return lute_json_encode(generate_profile() :: any)
    end,
    validator = function(input, output)
        -- Validation is a bit wonky here, we rely on Lute's implementation being correct here by being validated in other benchmarks
        local decoded = lute_json_decode(input)
        return deep_equals(output, decoded)
    end,
    runs = 100_000,
    warmup_runs = 1_000,
}
