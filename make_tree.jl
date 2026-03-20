
const sep = "-"

function make_tree(o::AbstractVector, key::AbstractString)
    list_of_lists = []
    for (idx, elem) in enumerate(o)
        if isa(elem, OrderedDict)
            elem = OrderedDict( "Dict-" * string(idx) => elem)
        end
        push!(list_of_lists, make_tree(elem, key * sep * string(idx)))
    end
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
    dict_list = []
    for (dict_key, dict_value) in o
        if isa(dict_value, Union{AbstractString, Number})
            # avoid sub-tree
            push!(dict_list, Dict(
                "label" => dict_key * ": " * string(dict_value),
                "key" => key * sep * dict_key,
            ))
        else
            push!(dict_list, Dict(
                "label" => dict_key,
                "key" => key * sep * dict_key,
                "children" => make_tree(dict_value, key * sep * dict_key),
            ))
        end
    end
    return dict_list
end
