import DataStructures: Trie, subtrie, partial_path, keys_with_prefix
import Base: getproperty

const Values = Union{String, Symbol, Number, Nothing}

struct VL
  payload::Trie{Union{Values, Vector}}
end
VL() = VL(Trie{Union{Values, Vector}}())

function VL(nt::NamedTuple)
  tps = [ (String(a),b) for (a,b) in pairs(nt) ]
  VL( Trie{Union{Values, Vector}}(tps) )
end


"e" ^5
import Base: show

split("abcde", "_")

function show(io::IO, vl::VL)
  ptree(io, vl.payload)
end

function ptree(io, t::Trie; indent=0)
  prevprefix = nothing
  for k in keys(t)
    els = split(k, "_")
    # println(k)
    if (prevprefix != els[1]) && (length(els) > 1) # go down one level
      println(" " ^ indent, els[1])
      ptree(io, subtrie(t, els[1] * "_"),
        indent=indent+2)
    elseif (t[k] != "xxxx") && (length(els) == 1)
      println(" " ^ indent, els[1], " : ", t[k])
    end
    prevprefix = els[1]
  end
end

function ptree(io, v::Vector; indent=0)
  for (i,e) in enumerate(v)
    if isa(e, Values)
      println(" " ^ indent, i, " : ", e)
    elseif isa(e, VL)
      println(" " ^ indent, i, " : ")
      ptree(io, e.payload, indent=indent+2)
    else
      println(" " ^ indent, i, " : ")
      ptree(io, e, indent=indent+2)
    end
  end
end

struct TT <: Trie{}


kkk = sort(keys(vl.payload))


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
      pardict[kend] = totree.(v)
    else
      @warn "unanticipated case : v is a $(typeof(v))"
    end
  end
  kdict
end

function totree(v::Vector)
  [ isa(e, Values) ? e : totree(e) for e in v  ]
end

totree(vl)

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
        print(" " ^ indent, i, " : ")
        printtree(io, v2, indent=indent+2)
      end
    end
  end
end
      
function printtree(io::IO, vl::VL; indent=0)
  kdict = totree(vl.payload)
  for (k,v) in kdict
    if isa(v, Values)
      println(" " ^ indent, k, " : ", v)
    elseif isa(v, VL)
      println(" " ^ indent, k, " : ")
      printtree(io, v.payload, indent=indent+2)
    elseif isa(v, Vector)
      if all( e -> isa(e, Values), v )  # print on one line
        rs = repr(v)
        if length(rs) > 50
          rs = rs[1:50] * "..."
        end
        println(" " ^ indent, k, " : ", rs)
      else
        println(" " ^ indent, k, " : ")
        for (i, v2) in enumerate(v)
          if isa(v2, Values)
            println(" " ^ indent, i, " : ")
          println(" " ^ indent, i, " : ")
          printtree(io, e, indent=indent+2)


VL( Trie{Union{Values, Vector}}(collect(pairs(nt))) )

first(pairs( (ab=456, ddd="sdkjhf")) )


t = Trie([("aa", 6), ("ab", :ggg), ("a_x", 45.5)])

subtrie(t, "a_").children = Dict{Char, Trie{Any}}()

subtrie(t, "a_")
keys(t)

subtrie(t, "ab")

haskey(t, "a")
length(keys_with_prefix(t, ""))
length(keys_with_prefix(t, "a"))
length(keys_with_prefix(t, "ab"))


t["a"]
delete!(t, "a")


# Trie indexing stops at vectors

## duplicate entry management

boxitem(item::Values) = item
boxitem(item)         = VL(item)

function dupindex!(vl, index, old, newitem)
  vl.payload[index] = Any[ old, boxitem(newitem) ]
end

function dupindex!(vl, index, old::Vector, newitem)
  push!(vl.payload[index], boxitem(newitem))
end


function addfield(vl::VL, index::String, item)
  # index already used => push into vector
  if haskey(vl.payload, index)
    dupindex!(vl, index, vl.payload[index], item)

  # there are already children for this index => encapsulate in new vl and create vector
  elseif length(keys_with_prefix(vl.payload, index * "_")) > 0
    prefix = index * "_"
    vl.payload[index] = [ subtrie(vl.payload, prefix) ]  # create vector with subtrie
    vl.payload[prefix].children = Dict{Char, Trie{Any}}() # remove subtrie

    # oits = []
    # for k in keys_with_prefix(vl.payload, index * "_")
    #   push!(oits, ( k[ length(index)+2 : end ], vl.payload[k] ))
    #   vl.payload[k] = "xxxx"
    # end
    # ovl = VL( Trie{Union{Values, Vector}}(oits) )
    # dupindex!(vl, index, ovl, item)

  elseif isa(item, Values)
    vl.payload[index] = item

  elseif isa(item, NamedTuple)
    for (k,v) in pairs(item)
      addfield(vl, index * "_" * String(k), v)
    end

  elseif isa(item, VL)
    for k in keys(item)
      addfield(vl, index * "_" * k, item[k])
    end

  elseif isa(item, Vector)
    for v in item
      addfield(vl, index, v)
    end

  else
    @warn "unanticipated case : item is a $(typeof(item))"

  end
end



function getproperty(vl::VL, sym::Symbol)
  (sym == :payload) && return getfield(vl, :payload)

  function (param=nothing; pars...)
    if (param != nothing)
      addfield(vl, String(sym), param)
    else
      for (a,b) in pairs(pars)
        addfield(vl, String(sym) * "_" * String(a), b)
      end
    end
    vl
  end
end


vl = VL()

vl.mark(:circle).
  encoding(
    y= (field=:time, type=:ordinal, timeUnit=:day, sort=[:mon,:tue, :sun]),
    x= (field=:time, type=:ordinal, timeUnit=:hours),
    size= (field=:count, type=:quantitative, aggregate=:sum) )

vl.payload

for k in keys(vl.payload)
  println("$k -> $(vl.payload[k])")
end



vl = VL()
vl.title("Questionnaire Ratings").
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

for k in keys(vl.payload)
  println("$k -> $(vl.payload[k])")
end
