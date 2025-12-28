local first_names =
    { "Laury", "Jailyn", "Maribel", "Arlo", "Zara", "Kai", "Lennie", "Reagan" }
local last_names =
    { "Spinka", "Johnson", "Martinez", "Lee", "Trantow", "O'Neil", "Schiller" }
local states = { "Rhode Island", "Texas", "California", "Florida", "New York" }
local countries = { "USA", "Panama", "Canada", "UK", "Germany" }
local job_titles = {
    "Regional Interactions Facilitator",
    "Senior Systems Analyst",
    "Product Operations Manager",
    "Marketing Coordinator",
}
local descriptors = { "Customer", "Corporate", "Internal", "Global" }
local areas = { "Infrastructure", "Marketing", "Operations", "Security" }
local types = { "Technician", "Engineer", "Manager", "Coordinator" }
local companies =
    { "Schiller and Sons", "Acme Corp", "Globex", "Wayne Enterprises" }
local card_issuers = { "visa", "mastercard", "amex" }
local tlds = { "com", "org", "de", "biz", "xyz" }

local function choice<T>(from: { [number]: T }): T
    return from[math.random(1, #from)]
end

local function digits(n: number): string
    local str = ""
    for _ = 1, n do
        str ..= tostring(math.random(0, 9))
    end
    return str
end

local function gen_phone(): string
    return string.format(
        "%03d-%03d-%04d (%d)",
        math.random(100, 999),
        math.random(100, 999),
        math.random(1000, 9999),
        math.random(1000, 9999)
    )
end

local function gen_international_phone(): string
    return string.format(
        "+%d %d %d %02d %02d",
        math.random(10, 99),
        math.random(100, 999),
        math.random(100, 999),
        math.random(10, 99),
        math.random(10, 99)
    )
end

local function gen_coordinates(): { latitude: string, longitude: string }
    return {
        latitude = string.format("%.4f", math.random(-90, 90)),
        longitude = string.format("%.4f", math.random(-180, 180)),
    }
end

local function gen_uuidv4(): string
    local uuidv4 = string.gsub(
        "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx",
        "[xy]",
        function(char)
            local value = if char == "x"
                then math.random(0, 0xf)
                else math.random(8, 0xb)
            return string.format("%x", value)
        end
    )
    return uuidv4
end

local function gen_profile()
    local first = choice(first_names)
    local middle = choice(first_names)
    local last = choice(last_names)
    local tld = choice(tlds)

    return {
        message = `Hello, {first}! Your order number is: {math.random(10, 999)}`,

        phone_number = gen_phone(),
        phone_variation = gen_international_phone(),
        status = if math.random(0, 1) == 0 then "active" else "inactive",

        name = {
            first = first,
            middle = middle,
            last = last,
        },

        username = `{first}-{last}`,
        password = gen_uuidv4(),

        emails = {
            `{first}{math.random(1, 99)}@gmail.com`,
            `{middle}_{last}{math.random(10, 99)}@protonmail.com`,
        },

        location = {
            street = `{math.random(100, 9999)} {choice(last_names)} Street`,
            city = `{choice(last_names)}ville`,
            state = choice(states),
            country = choice(countries),
            zip = digits(5),
            coordinates = gen_coordinates(),
        },

        website = `https://{first}-{last}.{tld}/`,
        domain = `{first}-{last}.{tld}`,

        job = {
            title = choice(job_titles),
            descriptor = choice(descriptors),
            area = choice(areas),
            type = choice(types),
            company = choice(companies),
        },

        credit_card = {
            number = `{digits(4)}-{digits(4)}-{digits(4)}-{digits(4)}`,
            ccv = digits(3),
            issuer = choice(card_issuers),
        },

        uuid = gen_uuidv4(),
    }
end

return gen_profile
