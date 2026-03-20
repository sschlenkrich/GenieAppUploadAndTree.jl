using GenieFramework
using Genie.Requests
using YAML
using OrderedCollections

include("make_tree.jl")

const UPLOAD = "public/uploads"

@app begin
    @out nodes = []
    @out display_file_name = ""

    @in selected_node = ""
    @in ticked_nodes = [ ]
    
    # Logic to run when a selection changes
    @onchange selected_node begin
        @info "User selected: $selected_node"
    end

    @onchange ticked_nodes begin
        @info "User ticked: $(string(ticked_nodes))"
    end
end

@event :uploaded begin
    upload_dir = joinpath(pwd(), UPLOAD)
    for file_name in readdir(upload_dir)
        @info "Process and delete file " * file_name * "."
        filepath = joinpath(upload_dir, file_name)
        try
            data = YAML.load_file(filepath; dicttype=OrderedDict{String,Any})
            @info "Parsed result type is " * string(typeof(data))
            tree = make_tree(data, file_name)
            @info "Converted to tree structure."
            nodes = tree
            @info "Assigned tree to nodes."
        catch e
            @info e
        end
        display_file_name = file_name
        rm(filepath)
        @notify("Processed and deleted file " * file_name * ".")
    end
end

function ui()
    [
        heading("Upload and Tree Example"),
        uploader(
            url = "/upload",
            accept = ".yaml, .json",
            @on("uploaded", :uploaded),
        ),
        card([
            h2("Tree representation of {{display_file_name}}"),
            tree(
                nodes = :nodes,
                var"node-key" = "key",
                var"tick-strategy" = "leaf",
                var"v-model:selected" = :selected_node,
                var"v-model:ticked" = :ticked_nodes,
            ),
        ]),
    ]
end

@page("/", ui)

route("/upload", method = POST) do
    files = Genie.Requests.filespayload()
    upload_dir = joinpath(pwd(), UPLOAD)
    mkpath(upload_dir)
    for file in values(files)
        @info "Uploading " * file.name * " with mime type " * file.mime * "."
        write(joinpath(upload_dir, file.name), file.data)
    end
    if length(files) == 0
        @info "No file uploaded."
    end
end