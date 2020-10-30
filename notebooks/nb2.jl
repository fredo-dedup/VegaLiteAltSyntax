### A Pluto.jl notebook ###
# v0.12.6

using Markdown
using InteractiveUtils

# ╔═╡ a1e1c328-1a02-11eb-2d14-9589688b268e
using VegaLiteAltSyntax 

# ╔═╡ af76a2e2-1a02-11eb-0cd6-3768598c1a14
begin
	using Distributions
	dat = [ (x=rand(LogNormal(1., 0.2)),) for i in 1:1000 ]
end

# ╔═╡ 84238b3c-1a2a-11eb-3091-e7799304f61f
VL(width=600).
	mark(type= :bar, 
		line_color=:darkgreen,
		stroke=:black, weight=3,
		color= (x1=1, y1=1, x2=1, y2=0, gradient=:linear,
		 		stops=[(offset=0, color=:red), (offset=1, color=:darkgreen)])).
    data_values(dat).
    encoding_x(field=:x, type=:quantitative, bin=true ).
	encoding_y(aggregate=:count, type=:quantitative)

# ╔═╡ a7d385f0-1a32-11eb-153d-2b093d4c9741
VL().width(600).mark(type= :tick).data_values(dat).encoding_x(quantitative(:x))

# ╔═╡ b95d0b16-1a2a-11eb-0414-a56ce3f0d4a1
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

# ╔═╡ 868786d0-1a2a-11eb-3533-537469d8b03a
VL(width=600).
	mark(type= :bar, 
		line_color=:darkgreen,
		stroke=:black, strokeSize=3,
		color=(x1=1, y1=1, x2=1, y2=0, gradient=:linear,
		 		stops=[(offset=0, color=:red), (offset=1, color=:darkgreen)])).
    data_values(dat).
    encoding_x(field=:x, bin=true ).
	encoding_y(aggregate=:count, type=:quantitative)

# ╔═╡ 9384f35e-1a39-11eb-337c-2d1a4d47b513
VL(width=600).
	mark(type= :bar, 
		line_color=:darkgreen,
		stroke=:black, strokeSize=3,
		VL.color(x1=1, y1=1, x2=1, y2=0, gradient=:linear,
		 		stops=[(offset=0, color=:red), (offset=1, color=:darkgreen)])).
    data_values(dat).
    encoding_x(field=:x, bin=true ).
	encoding_y(aggregate=:count, type=:quantitative)

# ╔═╡ c6a4d1a0-1a2a-11eb-23e9-5f0d63ef7986
begin
	dist = MixtureModel( [ MvNormal([2., 2.], 0.5), MvNormal([0., 0.], 0.5) ],
					[ 0.6, 0.4] )
	dat2 = [ ((x,y) = rand(dist) ; (x=x, y=y)) for i in 1:10000 ]
end

# ╔═╡ 0d796132-1aed-11eb-0bea-4d5227d8b3a0
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
	)
).config_view_stroke(:transparent)

# ╔═╡ 306aa160-1aed-11eb-23d2-5b34c97d208d
VegaLiteAltSyntax.totree(VL().hconcat(
		mark=:rect,
		encoding_x=(bin_maxbins=30, field=:x),
		encoding_y=(bin_maxbins=30, field=:y),
		encoding_color_aggregate=:count,
	))

# ╔═╡ d8d6b878-1a2a-11eb-07ae-290e07793327
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

# ╔═╡ 434ce3c8-1a2b-11eb-07a6-f1f854bffc68
4+5

# ╔═╡ Cell order:
# ╠═a1e1c328-1a02-11eb-2d14-9589688b268e
# ╠═af76a2e2-1a02-11eb-0cd6-3768598c1a14
# ╠═84238b3c-1a2a-11eb-3091-e7799304f61f
# ╠═a7d385f0-1a32-11eb-153d-2b093d4c9741
# ╠═b95d0b16-1a2a-11eb-0414-a56ce3f0d4a1
# ╠═868786d0-1a2a-11eb-3533-537469d8b03a
# ╠═9384f35e-1a39-11eb-337c-2d1a4d47b513
# ╠═c6a4d1a0-1a2a-11eb-23e9-5f0d63ef7986
# ╠═0d796132-1aed-11eb-0bea-4d5227d8b3a0
# ╠═306aa160-1aed-11eb-23d2-5b34c97d208d
# ╠═d8d6b878-1a2a-11eb-07ae-290e07793327
# ╠═434ce3c8-1a2b-11eb-07a6-f1f854bffc68
