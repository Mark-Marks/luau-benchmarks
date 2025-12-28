--!optimize 2
local deep_equals = require("./deep_equals")
local generate_profile = require("@generators/profile")
local runner = require("@lib/runner")

local lune_serde = require("@lune/serde")
local lune_serde_encode = lune_serde.encode
local lune_serde_decode = lune_serde.decode
local lute_json = require("@std/json")
local lute_json_encode = lute_json.serialize
local lute_json_decode = lute_json.deserialize

runner {
    title = "Encode",
    benchmarks = {
        ["lune"] = @native function(input)
            return lune_serde_encode("json", input)
        end,
        ["lute"] = @native function(input)
            return lute_json_encode(input)
        end,
    },
    generator = generate_profile,
    validator = function(input, output)
        local decoded = lune_serde_decode("json", output)
        return deep_equals(input, decoded)
    end,
    runs = 100_000,
    warmup_runs = 1_000,
}

runner {
    title = "Decode",
    benchmarks = {
        ["lune"] = @native function(input)
            return lune_serde_decode("json", input)
        end,
        ["lute"] = @native function(input)
            return lute_json_decode(input)
        end,
    },
    generator = function()
        return lune_serde_encode("json", generate_profile())
    end,
    validator = function(input, output)
        local decoded = lune_serde_decode("json", input)
        return deep_equals(output, decoded)
    end,
    runs = 100_000,
    warmup_runs = 1_000,
}
