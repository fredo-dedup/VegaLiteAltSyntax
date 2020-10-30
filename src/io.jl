###############################################################################
#  printing / displaying functions
###############################################################################

## conversion to a tree (a dict of dicts)

function totree(vl::VL)
  kdict = Dict{String,Any}()
  for k in sort(keys(vl.payload))
    ks = split(k, "_")
    # build dict tree if no set yet
    pardict = kdict
    for k2 in ks[1:end-1]
      if ! haskey(pardict, k2)
        pardict[k2] = Dict{String,Any}()
      end
      pardict = pardict[k2]
    end

    # set value
    v = vl.payload[k]
    kend = ks[end]
    if isa(v, Values)
      pardict[kend] = v
    elseif isa(v, Vector)
      pardict[kend] = totree(v)
    else
      @warn "unanticipated case : v is a $(typeof(v))"
    end
  end
  kdict
end

totree(e::Values)     = e
totree(e::NamedTuple) = e
totree(v::Vector) = map(totree, v)



## printing the tree
function Base.show(io::IO, vl::VL)
  printtree(io, totree(vl))
end


function printtree(io::IO, subtree::Union{NamedTuple, Dict, Vector}; indent=0)
  for (k,v) in pairs(subtree)
    if isa(v, Values)
      println(io, " " ^ indent, k, " : ", v)

    elseif isa(v, Vector) && all( e -> isa(e, Values), v ) # vector printable on one line
      rs = repr(v)
      if length(rs) > 50
        rs = rs[1:50] * "..."
      end
      println(io, " " ^ indent, k, " : ", rs)

    else
      println(io, " " ^ indent, k, " : ")
      printtree(io, v, indent=indent+2)

    end

    # escape if long vector
    if isa(subtree, Vector) && (k > 20)
      println(io, " " ^ indent, "$k - $(length(subtree)) : ...")
      break
    end
  end
end



## displaying the graph

function Base.show(io::IO, m::MIME"application/vnd.vegalite.v4+json", v::VL)
    VegaLite.our_json_print(io, VegaLite.VLSpec(totree(v)))
end

function Base.show(io::IO, m::MIME"application/vnd.vega.v5+json", v::VL)
    print(io, VegaLite.convert_vl_to_vg(VegaLite.VLSpec(totree(v))))
end

function Base.show(io::IO, m::MIME"image/svg+xml", v::VL)
    print(io, VegaLite.convert_vl_to_svg(VegaLite.VLSpec(totree(v))))
end

function Base.show(io::IO, m::MIME"application/vnd.julia.fileio.htmlfile", v::VL)
    VegaLite.writehtml_full(io, VegaLite.VLSpec(totree(v)))
end

function Base.show(io::IO, m::MIME"application/prs.juno.plotpane+html", v::VL)
    VegaLite.writehtml_full(io, VegaLite.VLSpec(totree(v)))
end
