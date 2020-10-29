### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# ╔═╡ 3fbcb3a6-1a02-11eb-2b59-77299aa65775
using VegaLiteAltSyntax

# ╔═╡ 914c1312-17b7-11eb-1ad6-67f86cf4f046
begin
	using Distributions
	dat = [ (x=rand(LogNormal(1., 0.1)),) for i in 1:1000 ]
end

# ╔═╡ 48f96b9e-1a02-11eb-1fa3-61a321ee4dc0


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
# ╠═3fbcb3a6-1a02-11eb-2b59-77299aa65775
# ╠═48f96b9e-1a02-11eb-1fa3-61a321ee4dc0
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
