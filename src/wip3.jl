import DataStructures: Trie, subtrie, partial_path, keys_with_prefix
import Base: getproperty
import Base: show

const Values = Union{String, Symbol, Number, Nothing}

struct VL
  payload::Trie{Union{Values, Vector}}
end
VL() = VL(Trie{Union{Values, Vector}}())

function VL(ps::Base.Iterators.Pairs)
  vl = VL( Trie{Union{Values, Vector}}() )
  for (k,v) in ps
    sk = String(k)
    if isa(v, Values)
      insert!(vl, sk, v)
    elseif isa(v, Vector)
      vs = [ isa(e,NamedTuple) ? VL(e) : e for e in v ]
      insert!(vl, sk, vs)
    else
      insert!(vl, sk, VL(v))
    end
  end
  vl
end


VL(nt::NamedTuple) = VL(pairs(nt))
VL(;pars...)       = VL(pairs(pars))


function Base.show(io::IO, vl::VL)
  printtree(io, totree(vl))
end

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
    elseif isa(v, VL)
      pardict[kend] = totree(v)
    elseif isa(v, Vector)
      pardict[kend] = totree(v)
    else
      @warn "unanticipated case : v is a $(typeof(v))"
    end
  end
  kdict
end

function totree(v::Vector)
  [ isa(e, Values) ? e : totree(e) for e in v  ]
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


function insert!(vl::VL, index, item::Union{Values, Vector, VL})
  # leaf already existing => add to vector or create vector
  if haskey(vl.payload, index)
    if isa(vl.payload[index], Vector)
      push!(vl.payload[index], item)
    else
      vl.payload[index] = Any[ vl.payload[index], item ]
    end

  # there is already a branch on index
  elseif length(keys_with_prefix(vl.payload, index * "_")) > 0
    prefix = index * "_"
    vl.payload[index] = Any[ VL(subtrie(vl.payload, prefix)), item ]  # create vector with subtrie
    delete!(subtrie(vl.payload, index).children, '_') # remove subtrie

  # if VL graft the branch
  elseif isa(item, VL)
    for k in keys(item.payload)
      vl.payload[index * "_" * k] = item.payload[k]
    end

  elseif isa(item, Union{Values, Vector})
    vl.payload[index] = item

  else
    @warn "unanticipated case : item is a $(typeof(item))"
  end

  vl
end

function getproperty(vl::VL, sym::Symbol)
  (sym == :payload) && return getfield(vl, :payload)

  function (param=missing; pars...)
    if isa(param, Values) || isa(param, Vector)
      # add at 'sym', ignore pars because it would make an inconsistent tree
      insert!(vl, String(sym), param)

    else
      if isa(param, NamedTuple) || isa(param, VL) # param has names, compatible with pars
        svl = isa(param, NamedTuple) ? VL(param) : param
        insert!(vl, String(sym), svl)
      elseif ismissing(param)

      else
        @warn "unanticipated case : param is a $(typeof(param))"
      end

      insert!(vl, String(sym), VL(;pars...))
    end
    vl
  end
end


## examples

vl = VL().mark(:circle).
  encoding(
    y= (field=:time, type=:ordinal, timeUnit=:day, sort=[:mon,:tue, :sun]),
    x= (field=:time, type=:ordinal, timeUnit=:hours),
    size= (field=:count, type=:quantitative, aggregate=:sum) )

totree(vl)


vl = VL().title("Questionnaire Ratings").
  width(250).heigth(175).
  encoding_y(
    field="name",
    type="nominal",
    sort= nothing,
    axis=(
      domain= false,
      offset= 50,
      labelFontWeight= :bold,
      ticks= false,
      grid= true,
      title= nothing
     )
   ).
   encoding_x(
     type= :quantitative,
     scale= (domain= [0, 6],),
     axis= (grid= false, values= [1, 2, 3, 4, 5], title= nothing)
  ).
  view_stroke(nothing).
  layer(
    mark= "circle",
    data_name= "values",
    transform= [ (filter= "datum.name != 'Toolbar_First'",),
     (filter= "datum.name != 'Tablet_First'",),
     (filter= "datum.name != 'Participant ID'",)
    ],
    encoding_x_field= "value",
    encoding_size= (aggregate=:count, type= "quantitative",
       title= "Number of Ratings", legend_offset= 75),
    encoding_color_value= "#6EB4FD"
  ).
  layer(
    mark= "tick",
    encoding = (
      x_field= "median",
      color_value= "black"
    )
  ).
  layer(
    mark= (type= "text", x= -5, align= "right"),
    encoding_text_field = "lo"
  ).
  layer(
    mark= (type= "text", x= 255, align= "left"),
    encoding_text_field= "hi"
  )


VL().slice(abcd="aaa", xyz=15).slice(abcd="bbb", cdf=[5])

VL().slice(abcd="aaa", xyz=15)

vl = VL(abcd="aaa", xyz=456, ttt=(abcd="aaa", xyz=456), ttt_xyz=[:bcd])
display(vl)

graft!(VL(), "toto", VL(abcd="aaa", xyz=456, ttt=(abcd="aaa", xyz=456), ttt_xyz=[:bcd]))


VL().layer(
  mark= "circle",
  data_name= "values",
  transform= [ (filter= "datum.name != 'Toolbar_First'",),
   (filter= "datum.name != 'Tablet_First'",),
   (filter= "datum.name != 'Participant ID'",)
  ],
  encoding_x_field= "value",
  encoding_size= (aggregate=:count, type= "quantitative",
     title= "Number of Ratings", legend_offset= 75),
  encoding_color_value= "#6EB4FD"
)
