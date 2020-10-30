module VegaLiteAltSyntax

using VegaLite


import DataStructures: Trie, subtrie, keys_with_prefix
# import Base: getproperty, show

export VL, quantitative, ordinal, temporal, nominal, getproperty


## the struct

const Values    = Union{String, Symbol, Number, Nothing}

struct VL
  payload::Trie{Union{Values, Vector}}
end

const VecValues = Union{Values, Vector, NamedTuple, VL}

function VL(pargs...;nargs...)
	all( isa.(pargs, Union{VL, NamedTuple}) ) ||
		@error "non-named argument(s) not allowed"

	vl = VL( Trie{Union{Values, Vector}}() )

	# add named arguments if any
	for (k,v) in pairs(nargs)
		insert!(vl, String(k), v)
		# TODO : ensure vectors are VecValues[] ?
	end

	# add positional arguments (can be NamedTuples or VL only)
	for pa in pargs
		nvl = isa(pa, NamedTuple) ? VL(pairs(pa)) : pa
		for l1k in l1keys(nvl)
			if haskey(nvl.payload, l1k)  # leaf
				insert!(vl, l1k, nvl.payload[l1k])
			else  # branch
				insert!(vl, l1k, VL(subtrie(nvl.payload, l1k * "_")))
			end
		end
	end
	vl
end

# gets 1st level keys
function l1keys(vl::VL)
	l1k = Set{String}()
	for k in keys(vl.payload)
		ks = split(k, "_")
		push!(l1k, ks[1])
	end
	l1k
end


include("io.jl")


## functions amending the structure

# insert at index in vl

Base.insert!(vl::VL, index, item::NamedTuple) =
	insert!(vl, index, VL(;pairs(item)...))

function Base.insert!(vl::VL, index, item::Union{Values, Vector, VL})
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



function Base.getproperty(vl::VL, sym::Symbol)
  (sym == :payload) && return getfield(vl, :payload)

  function (pargs...; nargs...)
		# single, non-named argument
		if (length(pargs)==1) && (length(nargs)==0) && isa(pargs[1], Union{Values, Vector})
			insert!(vl, String(sym), pargs[1])

		else
			# if there are multiple args, all should have a name (always true for
			# named arguments, but true for positional arguments only if they are VL or
			#  NamedTuples)
			# all( isa.(pargs, Union{VL, NamedTuple}) ) ||
			# 	@error "non-named argument(s) not allowed if more than one argument"
			#
			insert!(vl, String(sym), VL(pargs...;nargs...))
		end
  end
end

# Base.getproperty(::Type{VL}, sym::Symbol) = getproperty(VL(), sym)


## helper funcs

quantitative(v::Union{Symbol, String}) = VL(field=v, type=:quantitative)
nominal(     v::Union{Symbol, String}) = VL(field=v, type=:nominal     )
temporal(    v::Union{Symbol, String}) = VL(field=v, type=:temporal    )
ordinal(     v::Union{Symbol, String}) = VL(field=v, type=:ordinal     )


end
