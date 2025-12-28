local deep_equals = require("./deep_equals")
local generate_profile = require("@generators/profile")
local runner = require("@lib/runner")

local zune_json = zune.serde.json
local zune_json_encode = zune_json.encode
local zune_json_decode = zune_json.decode
local lute_json = require("@std/json")
local lute_json_encode = lute_json.serialize
local lute_json_decode = lute_json.deserialize

runner {
    title = "Encode",
    benchmarks = {
        ["zune"] = @native function(input)
            return zune_json_encode(input)
        end,
        ["lute"] = @native function(input)
            return lute_json_encode(input)
        end,
    },
    generator = generate_profile,
    validator = function(input, output)
        local decoded = zune_json_decode(output)
        return deep_equals(input, decoded)
    end,
    runs = 1_000,
    warmup_runs = 1_000,
}

runner {
    title = "Decode",
    benchmarks = {
        ["zune"] = @native function(input)
            return zune_json_decode(input)
        end,
        ["lute"] = @native function(input)
            return lute_json_decode(input)
        end,
    },
    generator = function()
        return zune_json_encode(generate_profile())
    end,
    validator = function(input, output)
        local decoded = zune_json_decode(input)
        return deep_equals(output, decoded)
    end,
    runs = 1_000,
    warmup_runs = 1_000,
}
