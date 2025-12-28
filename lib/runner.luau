local ansi = require("./ansi")
local benchmark = require("./benchmark")
local prettyprint = require("./prettyprint")

local first_run = true

local bg_colors = {
    ansi.bg.red,
    ansi.bg.green,
    ansi.bg.yellow,
    ansi.bg.blue,
    ansi.bg.magenta,
    ansi.bg.cyan,
}

local function runner(data: {
    title: string,
    benchmarks: { [string]: (any) -> any },
    generator: (() -> any)?,
    validator: ((any, any) -> boolean)?,
    runs: number,
    warmup_runs: number?,
})
    local all_statistics: { benchmark.statistics } = {}
    local names: { string } = {}

    for name, fn in data.benchmarks do
        local generator = data.generator
        local warmup_runs = data.warmup_runs or 0

        for _ = 1, warmup_runs do
            fn(generator and generator())
        end

        local statistics = benchmark(fn, data.runs, generator, data.validator)
        statistics.warmup_runs = warmup_runs
        table.insert(all_statistics, statistics)
        table.insert(names, name)
    end

    table.sort(all_statistics, function(lhs: any, rhs: any)
        return lhs.total < rhs.total
    end)

    local outputs = {}
    local first_statistics = all_statistics[1]
    for idx, statistics in all_statistics do
        local bg_color_idx = ((idx - 1) % #bg_colors) + 1
        if idx == 1 then
            outputs[idx] = prettyprint.prettyprint(
                `{bg_colors[bg_color_idx]}{names[idx]}`,
                statistics,
                "μs"
            )
            continue
        end

        local multipliers: prettyprint.multipliers = {
            min = statistics.min / first_statistics.min,
            max = statistics.max / first_statistics.max,
            avg = statistics.avg / first_statistics.avg,

            perc10 = statistics.perc10 / first_statistics.perc10,
            perc50 = statistics.perc50 / first_statistics.perc50,
            perc90 = statistics.perc90 / first_statistics.perc90,

            total = statistics.total / first_statistics.total,
        }

        outputs[idx] = prettyprint.prettyprint(
            `{bg_colors[bg_color_idx]}{names[idx]}`,
            statistics,
            "μs",
            multipliers
        )
    end

    if first_run then
        first_run = false
    else
        print("\n")
    end

    print(
        `{ansi.bold}---[ {ansi.reset}{ansi.bg.white}{ansi.black}{data.title}{ansi.reset}{ansi.bold} ]---{ansi.reset}\n`
    )
    print(table.concat(outputs, "\n"))
end

return runner
