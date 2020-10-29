###############################################################################
#  printing / displaying functions
###############################################################################

# printing the tree
function Base.show(io::IO, vl::VL)
  printtree(io, totree(vl))
end

function printtree(io::IO, v::Vector; indent=0)
  if all( e -> isa(e, Values), v )  # print on one line
    rs = repr(v)
    if length(rs) > 50
      rs = rs[1:50] * "..."
    end
    println(rs)  # no indent
  else
    println()
    for (i, v2) in enumerate(v)
      if isa(v2, Values)
        println(" " ^ indent, i, " : ", v2)
      else
        println(" " ^ indent, i, " : ")
        printtree(io, v2, indent=indent+2)
      end
    end
  end
end

function printtree(io::IO, kdict::Dict; indent=0)
  for (k,v) in kdict
    if isa(v, Values)
      println(" " ^ indent, k, " : ", v)
    elseif isa(v, Dict)
      println(" " ^ indent, k, " : ")
      printtree(io, v, indent=indent+2)

    elseif isa(v, Vector)
      print(" " ^ indent, k, " : ")
      printtree(io, v, indent=indent+2)

    else
      @warn "unanticipated case : v is a $(typeof(v))"
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
