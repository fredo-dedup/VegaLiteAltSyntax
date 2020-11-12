module VegaLiteAltSyntax

using VegaLite
using Dates

import Tables
import DataStructures: Trie, subtrie, keys_with_prefix
# import Base: getproperty, show

export VL, quantitative, ordinal, temporal, nominal, getproperty


## the VL struct

# this will help limit what goes into the spec tree
const LeafType = Union{
	String,
	Symbol,
	Number,
	Date, DateTime, Time,
	Nothing
}

struct VL
  payload::Trie{Union{LeafType, Vector}}
end

const VecValues = Union{LeafType, Vector, NamedTuple, VL}

# single arg case (not caught by named args function below apparently)
VL(vl::VL) = vl
VL(nt::NamedTuple) = VL(;pairs(nt)...)

# general constructor
function VL(pargs...;nargs...)
	all( isa.(pargs, Union{VL, NamedTuple}) ) ||
		@error "non-named argument(s) not allowed"
    # TODO : catch errors and show helpful message

	vl = VL( Trie{Union{LeafType, Vector}}() )

	# add named arguments if any
	for (k,v) in pairs(nargs)
		insert!(vl, String(k), v)
		# TODO : ensure vectors are VecValues[] ?
	end

	# add positional arguments (can be NamedTuples or VL only)
	for pa in pargs
		nvl = VL(pa) # force to VL if NamedTuple
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

# NamedTuples into VL structs
Base.insert!(vl::VL, index, item::NamedTuple) =
	insert!(vl, index, VL(;pairs(item)...))

function Base.insert!(vl::VL, index, item::Union{LeafType, Vector, VL})
  # leaf already existing => add to vector or create vector
  if haskey(vl.payload, index)
    if isa(vl.payload[index], Vector)
      push!(vl.payload[index], item)
    else
      vl.payload[index] = VecValues[ vl.payload[index], item ]
    end

  # there is already a branch on index
  # TODO use 1st level of index instead of index ?
  elseif length(keys_with_prefix(vl.payload, index * "_")) > 0
    prefix = index * "_"
    vl.payload[index] = VecValues[ VL(subtrie(vl.payload, prefix)), item ]  # create vector with subtrie
    delete!(subtrie(vl.payload, index).children, '_') # remove subtrie

  # if VL graft the branch
  elseif isa(item, VL)
    for k in keys(item.payload)
      vl.payload[index * "_" * k] = item.payload[k]
    end

  elseif isa(item, Union{LeafType, Vector})
    vl.payload[index] = item

  else
    @warn "unanticipated case : item is a $(typeof(item))"
  end

  vl
end

## let's try to accept rowtables

function Base.insert!(vl::VL, index, item::Any)
  Base.insert!(vl, index, Tables.rowtable(item))
  # TODO : catch errors and show helpful message
end


## make the VL().sym1().sym2() syntax work
function Base.getproperty(vl::VL, sym::Symbol)
  # treat VL fieldname :payload as it should
  (sym == :payload) && return getfield(vl, :payload)

  function (pargs...; nargs...)
		# single, non-named argument
		if (length(pargs)==1) && (length(nargs)==0)
			a = pargs[1]
			if a isa Union{LeafType, Vector}
				insert!(vl, String(sym), a)
			elseif a isa VL
				insert!(vl, String(sym), a)
			elseif a isa NamedTuple
				insert!(vl, String(sym), VL(a))
			else  # last chance try to turn it into a row table
				insert!(vl, String(sym), a)
			end
		else
			insert!(vl, String(sym), VL(pargs...;nargs...))
		end
  end
end

## make the VL().sym1().sym2() syntax also work for the VL type :
#   VL.sym1().sym2()

# forbidden symbols are the DataType symbols
# :name, :super, :parameters, :types, :names, :instance, :layout, :size,
# :ninitialized, :uid, :abstract, :mutable, :hasfreetypevars, :isconcretetype,
# :isdispatchtuple, :isbitstype, :zeroinit, :isinlinealloc,
# :has_concrete_subtype, Symbol("llvm::StructType"), Symbol("llvm::DIType"))

function Base.getproperty(vlt::Type{VL}, sym::Symbol)
	# treat DataType fieldnames as usual
	(sym in fieldnames(DataType)) && return getfield(vlt, sym)

	# create new VL
	getproperty(VL(), sym)
end


## helper funcs

quantitative(v::Union{Symbol, String}) = VL(field=v, type=:quantitative)
nominal(     v::Union{Symbol, String}) = VL(field=v, type=:nominal     )
temporal(    v::Union{Symbol, String}) = VL(field=v, type=:temporal    )
ordinal(     v::Union{Symbol, String}) = VL(field=v, type=:ordinal     )


end
