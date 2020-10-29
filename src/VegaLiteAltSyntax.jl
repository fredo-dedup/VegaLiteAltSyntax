module VegaLiteAltSyntax

using VegaLite


import DataStructures: Trie, subtrie, partial_path, keys_with_prefix
import Base: getproperty, show

export VL, quantitative, ordinal, temporal, nominal


## the structure

const Values    = Union{String, Symbol, Number, Nothing}
const VecValues = Union{Values, Vector, NamedTuples, VL}

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
      vs = VecValues[ isa(e,NamedTuple) ? VL(e) : e for e in v ]
      insert!(vl, sk, vs)
    else
      insert!(vl, sk, VL(v))
    end
  end
  vl
end


VL(nt::NamedTuple) = VL(pairs(nt))
VL(;pars...)       = VL(pairs(pars))


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

function totree(v::Vector)
  [ isa(e, Values) ? e : totree(e) for e in v  ]
end

## functions amending the structure

function insert!(vl::VL, index, item::Union{Values, Vector, VL})
  # leaf already existing => add to vector or create vector
  if haskey(vl.payload, index)
    if isa(vl.payload[index], Vector)
      push!(vl.payload[index], item)
    else
      vl.payload[index] = VecValues[ vl.payload[index], item ]
    end

  # there is already a branch on index
  elseif length(keys_with_prefix(vl.payload, index * "_")) > 0
    prefix = index * "_"
    vl.payload[index] = VecValues[ VL(subtrie(vl.payload, prefix)), item ]  # create vector with subtrie
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

  function (pargs...; nargs...)
		# if there are multiple args, all should have a name (always true for
		# named arguments, but true for positional arguments iif they are VL or
		#  Namedtuples)
		if (length(pargs)+length(nargs) > 1)
			all( isa.(pargs, Union{VL, NamedTuple}) ) ||
				@error "non-named argument(s) not allowed if more than one argument"
		end

		for pa in pargs
			svl = isa(pa, NamedTuple) ? VL(pa) : pa # NT into VL,unchanged otherwise
			insert!(vl, String(sym), svl)
		end

		if ( length(nargs) > 0 )
			insert!(vl, String(sym), VL(;nargs...))
		end

    vl
  end
end

getproperty(::Type{VL}, sym::Symbol) = getproperty(VL(), sym)


## helper funcs

quantitative(v::Union{Symbol, String}) = VL(field=v, type=:quantitative)
nominal(     v::Union{Symbol, String}) = VL(field=v, type=:nominal     )
temporal(    v::Union{Symbol, String}) = VL(field=v, type=:temporal    )
ordinal(     v::Union{Symbol, String}) = VL(field=v, type=:ordinal     )


end
