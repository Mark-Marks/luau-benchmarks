local ansi = require("./ansi")

export type statistics = {
    min: number,
    max: number,
    avg: number,

    perc10: number,
    perc50: number,
    perc90: number,

    total: number,
    runs: number,
    warmup_runs: number,
}

local function percentile(data: { number }, p: number): number
    local i = p / 100 * (#data - 1)
    local k = math.floor(i)
    local f = i - k

    local at_k = data[k]
    if k + 1 < #data then
        return at_k + f * (data[k + 1] - at_k)
    end
    return at_k
end

local function statistics(data: { number }): statistics
    table.sort(data)

    local total = 0
    for idx = 1, #data do
        total += data[idx]
    end

    return {
        min = data[1],
        max = data[#data],
        avg = total / #data,

        perc10 = percentile(data, 10) or data[1],
        perc50 = percentile(data, 50) or data[1],
        perc90 = percentile(data, 90) or data[1],

        total = total,
        runs = #data,
        warmup_runs = 0,
    }
end

local function benchmark<I, O>(
    fn: (I) -> O,
    runs: number,
    generator: (() -> I)?,
    validator: ((I, O) -> boolean)?
): statistics
    local times = {}

    for n = 1, runs do
        local input
        if generator then
            input = generator()
        end

        local begin = os.clock()
        local output = fn(input)
        local finish = os.clock()

        if validator and not validator(input, output) then
            print(
                `{ansi.red}Failed{ansi.reset} to validate output data on run {ansi.bold}{n}{ansi.reset}.`
            )
            print(`{ansi.bg.blue}Input{ansi.reset}{ansi.dim}:{ansi.reset}\n`)
            print(input)
            print(`{ansi.bg.green}Output{ansi.reset}{ansi.dim}:{ansi.reset}\n`)
            print(output)
            error(`{ansi.red}Aborting{ansi.reset} further execution.`)
        end

        times[n] = finish - begin
    end

    return statistics(times)
end

return benchmark
