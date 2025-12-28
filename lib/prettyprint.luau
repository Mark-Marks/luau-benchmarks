local ansi = require("./ansi")
local benchmark = require("./benchmark")
type statistics = benchmark.statistics
export type multipliers = {
    min: number,
    max: number,
    avg: number,

    perc10: number,
    perc50: number,
    perc90: number,

    total: number,
}

export type unit = "μs" | "ms" | "sec" | "min" | "hr"
local unit_lookup: { [unit]: number } = {
    ["μs"] = 1e-6,
    ms = 1e-3,
    sec = 1,
    min = 60,
    hr = 3_600,
}

local unit_pairs: { { unit: unit, seconds: number } } = {
    { unit = "μs", seconds = 1e-6 },
    { unit = "ms", seconds = 1e-3 },
    { unit = "sec", seconds = 1 },
    { unit = "min", seconds = 60 },
    { unit = "hr", seconds = 3_600 },
}

local function pick_best_unit(n: number): (number, unit)
    for index = #unit_pairs, 1, -1 do
        local pair = unit_pairs[index]
        if n >= pair.seconds then
            return n / pair.seconds, pair.unit
        end
    end

    local lowest_pair = unit_pairs[1]
    return n / lowest_pair.seconds, lowest_pair.unit
end

local function div(statistics: statistics, n: number): statistics
    return {
        min = statistics.min / n,
        max = statistics.max / n,
        avg = statistics.avg / n,

        perc10 = statistics.perc10 / n,
        perc50 = statistics.perc50 / n,
        perc90 = statistics.perc90 / n,

        total = statistics.total,
        runs = statistics.runs,
        warmup_runs = statistics.warmup_runs,
    }
end

local function pretty_int(n: number): string
    local stringified = tostring(n)
    local reversed = string.reverse(stringified)
    local prettified = string.gsub(reversed, "(%d%d%d)", `%1'`)
    local ordered = string.reverse(prettified)
    local trimmed = string.gsub(ordered, `^'`, "")
    local result = string.gsub(trimmed, "'", `{ansi.dim}'{ansi.reset}`)
    return result
end

local function dimmed_decimal(n: number): string
    local stringified = tostring(n)
    local result = string.gsub(stringified, "%.", `{ansi.dim}.{ansi.reset}`)
    return result
end

local function trim_to(n: number, decimal_point: number): number
    local k = 10 ^ decimal_point
    return math.floor(n * k) / k
end

local function prettyprint(
    title: string,
    statistics: statistics,
    unit: unit,
    multipliers: multipliers?
): string
    statistics = div(statistics, unit_lookup[unit])

    local str = `{ansi.bold}{title}{ansi.reset}\n`

    str ..= `{ansi.dim}⎸{ansi.reset} minimum{ansi.dim}:{ansi.reset} {dimmed_decimal(
        trim_to(statistics.min, 4)
    )} {ansi.dim}{unit}{ansi.reset} {if multipliers
        then `{ansi.bold}[{trim_to(multipliers.min, 2)}x]{ansi.reset}`
        else ""}\n`
    str ..= `{ansi.dim}⎸{ansi.reset} maximum{ansi.dim}:{ansi.reset} {dimmed_decimal(
        trim_to(statistics.max, 4)
    )} {ansi.dim}{unit}{ansi.reset} {if multipliers
        then `{ansi.bold}[{trim_to(multipliers.max, 2)}x]{ansi.reset}`
        else ""}\n`
    str ..= `{ansi.dim}⮡{ansi.reset} average{ansi.dim}:{ansi.reset} {dimmed_decimal(
        trim_to(statistics.avg, 4)
    )} {ansi.dim}{unit}{ansi.reset} {if multipliers
        then `{ansi.bold}[{trim_to(multipliers.avg, 2)}x]{ansi.reset}`
        else ""}\n`

    str ..= "\n"

    str ..= `{ansi.dim}⎸{ansi.reset} 10th %{ansi.dim}:{ansi.reset} {dimmed_decimal(
        trim_to(statistics.perc10, 4)
    )} {ansi.dim}{unit}{ansi.reset} {if multipliers
        then `{ansi.bold}[{trim_to(multipliers.perc10, 2)}x]{ansi.reset}`
        else ""}\n`
    str ..= `{ansi.dim}⎸{ansi.reset} 50th %{ansi.dim}:{ansi.reset} {dimmed_decimal(
        trim_to(statistics.perc50, 4)
    )} {ansi.dim}{unit}{ansi.reset} {if multipliers
        then `{ansi.bold}[{trim_to(multipliers.perc50, 2)}x]{ansi.reset}`
        else ""}\n`
    str ..= `{ansi.dim}⮡{ansi.reset} 90th %{ansi.dim}:{ansi.reset} {dimmed_decimal(
        trim_to(statistics.perc90, 4)
    )} {ansi.dim}{unit}{ansi.reset} {if multipliers
        then `{ansi.bold}[{trim_to(multipliers.perc90, 2)}x]{ansi.reset}`
        else ""}\n`

    str ..= "\n"

    local best_total_seconds, best_total_unit = pick_best_unit(statistics.total)

    str ..= `{ansi.dim}·{ansi.reset} {ansi.bold}warmup{ansi.reset} runs{ansi.dim}:{ansi.reset} {pretty_int(
        statistics.warmup_runs
    )}\n`
    str ..= `{ansi.dim}·{ansi.reset} {ansi.bold}summed{ansi.reset} runs{ansi.dim}:{ansi.reset} {pretty_int(
        statistics.runs
    )}\n`
    str ..= `{ansi.dim}·{ansi.reset} {ansi.bold}summed{ansi.reset} time{ansi.dim}:{ansi.reset} {dimmed_decimal(
        trim_to(best_total_seconds, 4)
    )} {ansi.dim}{best_total_unit}{ansi.reset} {if multipliers
        then `{ansi.bold}[{trim_to(multipliers.total, 2)}x]{ansi.reset}`
        else ""}\n`

    return str
end

return {
    microsecond = "μs" :: "μs",
    milisecond = "ms" :: "ms",
    second = "s" :: "s",
    minute = "m" :: "m",
    hour = "h" :: "h",

    prettyprint = prettyprint,
}
