### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# ╔═╡ 284b5ee6-17b3-11eb-1e2e-d90897f44502
module VegaLiteAltSyntax

using VegaLite

export VL

import DataStructures: Trie, subtrie, keys_with_prefix
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
		
    # if isa(param, Values) || isa(param, Vector)
    #   # add at 'sym', ignore pars because it would make an inconsistent tree
    #   insert!(vl, String(sym), param)
		# 
    # else
    #   if isa(param, NamedTuple) || isa(param, VL) # param has names, compatible with pars
    #     svl = isa(param, NamedTuple) ? VL(param) : param
    #     insert!(vl, String(sym), svl)
    #   elseif ismissing(param)
		# 
    #   else
    #     @warn "unanticipated case : param is a $(typeof(param))"
    #   end
		# 
    #   if (length(pars) > 0)
		# 		insert!(vl, String(sym), VL(;pars...))
		#   end
    # end
    vl
  end
end


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


end


# ╔═╡ 914c1312-17b7-11eb-1ad6-67f86cf4f046
begin
	using Distributions
	dat = [ (x=rand(LogNormal(1., 0.1)),) for i in 1:1000 ]
end

# ╔═╡ 6c91f4f4-17b4-11eb-2825-eb3d340b73b5
VL = VegaLiteAltSyntax.VL

# ╔═╡ 7c3ff39c-17b4-11eb-0e63-13f1d8f131b6


# ╔═╡ 8c517986-17b4-11eb-3252-672fede118e9
begin
	quantitative(v::Union{Symbol, String}) = VL(field=v, type=:quantitative)
	nominal(     v::Union{Symbol, String}) = VL(field=v, type=:nominal     )
	temporal(    v::Union{Symbol, String}) = VL(field=v, type=:temporal    )
	ordinal(     v::Union{Symbol, String}) = VL(field=v, type=:ordinal     )
end

# ╔═╡ dad7dcd0-17b4-11eb-1b31-c5b4dfe57a70


# ╔═╡ c6f32f0e-17b8-11eb-1917-597fabf90c76
VL(width=600).
	mark(type= :bar, 
		line_color=:darkgreen,
		stroke=:black, weight=3,
		color= (x1=1, y1=1, x2=1, y2=0, gradient=:linear,
		 		stops=[(offset=0, color=:red), (offset=1, color=:darkgreen)])).
    data_values(dat).
    encoding_x(field=:x, type=:quantitative, bin=true ).
	encoding_y(aggregate=:count, type=:quantitative)

# ╔═╡ e4205e64-183a-11eb-1de5-15a711287792
ttt= VL(width=600).
	mark(type= :bar, 
		line_color=:darkgreen,
		stroke=:black, weight=3,
		color= (x1=1, y1=1, x2=1, y2=0, gradient=:linear,
		 		stops=[(offset=0, color=:red), (offset=1, color=:darkgreen)])).
    data_values(dat).
    encoding_x(field=:x, type=:quantitative, bin=true ).
	encoding_y(aggregate=:count, type=:quantitative);

# ╔═╡ f015ab02-183a-11eb-14da-15d59fe1804e
keys(ttt.payload)

# ╔═╡ 06371c26-17b8-11eb-25d9-412d08c038d3
VL().
	data_values( [
      (category= 1, value= 4 ),
      (category= 2, value= 6 ),
      (category= 3, value= 10),
      (category= 4, value= 3 ),
      (category= 5, value= 7 ),
      (category= 6, value= 8 )
    ]).
  	layer( 
		VL().mark(type=:arc, innerRadius=60).
  		encoding_theta(quantitative(:value)).
  		encoding_color(nominal(:category)) ).
  	layer( 
		VL().mark(type=:arc, innerRadius=20, outerRadius=40).
  		encoding_theta(quantitative(:value)).
  		encoding_color(nominal(:category)) )


# ╔═╡ f74339f4-17b7-11eb-33da-4bde2250dc2c
begin
	dist = MixtureModel( [ MvNormal([2., 2.], 0.5), MvNormal([0., 0.], 0.5) ],
					[ 0.6, 0.4] )
	dat2 = [ ((x,y) = rand(dist) ; (x=x, y=y)) for i in 1:10000 ]
end

# ╔═╡ dafc0b66-17d5-11eb-3882-81d4dedf6808
VL(spacing=15, bounds=:flush, data_values=dat2).
vconcat(
	mark=:bar, height=0.1, 
	encoding_x=(field=:x, type=:quantitative, bin_maxbins=30, axis=nothing),
	encoding_y=(aggregate=:count, scale_domain=[-1,2], title="")
).vconcat(
	VL().hconcat(
		mark=:rect,
		encoding_x=(bin_maxbins=30, field=:x),
		encoding_y=(bin_maxbins=30, field=:y),
		encoding_color_aggregate=:count,
	).hconcat(
		mark=:bar, width=0.1,
		encoding_y=(bin_maxbins=30, field=:y, axis=nothing),
		encoding_x=(aggregate=:count, scale_domain=[-1,2], title="")
	)
).config_view_stroke(:transparent)

# ╔═╡ 746a151c-1831-11eb-172a-23c89160de37


# ╔═╡ 6dee2ce6-182c-11eb-1d3d-e3037da80d2b


# ╔═╡ 4b78036a-17c0-11eb-3768-c3665b257c46
VL(spacing=15, bounds=:flush, data_values=dat2,
	mark=:rect,
	VL().encoding_x(quantitative(:x), bin=true),
	VL().encoding_y(quantitative(:y), bin=true),
	encoding_color=(aggregate=:count,)
)

# ╔═╡ 6a38e01e-182c-11eb-0abd-51f5516b60fa


# ╔═╡ Cell order:
# ╟─284b5ee6-17b3-11eb-1e2e-d90897f44502
# ╠═6c91f4f4-17b4-11eb-2825-eb3d340b73b5
# ╠═7c3ff39c-17b4-11eb-0e63-13f1d8f131b6
# ╠═8c517986-17b4-11eb-3252-672fede118e9
# ╠═dad7dcd0-17b4-11eb-1b31-c5b4dfe57a70
# ╠═914c1312-17b7-11eb-1ad6-67f86cf4f046
# ╠═c6f32f0e-17b8-11eb-1917-597fabf90c76
# ╠═e4205e64-183a-11eb-1de5-15a711287792
# ╠═f015ab02-183a-11eb-14da-15d59fe1804e
# ╠═06371c26-17b8-11eb-25d9-412d08c038d3
# ╠═f74339f4-17b7-11eb-33da-4bde2250dc2c
# ╠═dafc0b66-17d5-11eb-3882-81d4dedf6808
# ╠═746a151c-1831-11eb-172a-23c89160de37
# ╠═6dee2ce6-182c-11eb-1d3d-e3037da80d2b
# ╠═4b78036a-17c0-11eb-3768-c3665b257c46
# ╠═6a38e01e-182c-11eb-0abd-51f5516b60fa
