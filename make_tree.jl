
const sep = "-"

function make_tree(o::AbstractVector, key::AbstractString)
    list_of_lists = [
        make_tree(elem, key * sep * string(idx)) for (idx, elem) in enumerate(o)
    ]
    return vcat( list_of_lists... )
end

function make_tree(o::AbstractString, key::AbstractString)
    return [ Dict("label" => o, "key" => key) ]
end

function make_tree(o::Integer, key::AbstractString)
    return [ Dict("label" => string(o), "key" => key) ]
end

function make_tree(o::AbstractFloat, key::AbstractString)
    return [ Dict("label" => string(o), "key" => key) ]
end

function make_tree(o::OrderedDict, key::AbstractString)
    return [
        Dict(
            "label" => "Dict",
            "key" => key,
            "children" => [
                Dict(
                    "label" => dict_key,
                    "key" => key * sep * dict_key * "-label",
                    "children" => make_tree(dict_value, key * sep * dict_key * "-value"),
                )
                for (dict_key, dict_value) in o
            ],
        )
    ]
end
