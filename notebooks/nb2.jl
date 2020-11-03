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
VL.width(600).mark(type= :tick).data_values(dat).encoding_x(quantitative(:x))

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

# ╔═╡ 1260b984-1c55-11eb-1c20-bb8ac524c5a7
VL().
	data_values( [
      (category= 1, value= 4 ),
      (category= 2, value= 6 ),
      (category= 3, value= 10),
      (category= 4, value= 3 ),
      (category= 5, value= 7 ),
      (category= 6, value= 8 )
    ]).
	transform([(calculate="datum.value-1", as=:v2)]).
  	mark(type=:arc, innerRadius=40).
  	encoding_theta(quantitative(:value)).
  	encoding_theta2(quantitative(:v2)).
    encoding_radius(quantitative(:value)).
  	encoding_radius2(quantitative(:v2)).
  	encoding_color(nominal(:category)) 

# ╔═╡ 868786d0-1a2a-11eb-3533-537469d8b03a
VL(width=600).
	mark(type= :area, 
		line_color=:darkgreen,
		stroke=:black, strokeSize=3,
		color=(x1=1, y1=1, x2=1, y2=0, gradient=:linear,
		 		stops=[(offset=0, color=:transparent), (offset=1, color=:darkgreen)])).
    data_values(dat).
    encoding_x(field=:x, bin=true ).
	encoding_y(aggregate=:count, type=:quantitative)

# ╔═╡ c6a4d1a0-1a2a-11eb-23e9-5f0d63ef7986
begin
	dist = MixtureModel( [ MvNormal([2., 2.], 0.5), MvNormal([0., 0.], 0.5) ],
					[ 0.6, 0.4] )
	dat2 = [ ((x,y) = rand(dist) ; (x=x, y=y)) for i in 1:10000 ]
end

# ╔═╡ d8d6b878-1a2a-11eb-07ae-290e07793327
VL(spacing=15, bounds=:flush, data_values=dat2).
vconcat(
	VL.mark(:bar).height(0.1).
	encoding_x(quantitative(:x), bin_maxbins=25, axis=nothing).
	encoding_y(aggregate=:count, scale_domain=[-1,2], title="")
).vconcat(
	VL.hconcat(
		VL.mark(:rect).
		encoding_x(quantitative(:x), bin_maxbins=25).
		encoding_y(bin_maxbins=25, quantitative(:y)).
		encoding_color_aggregate(:count)
	).hconcat(
		VL.mark(:bar).width(0.1).
		encoding_y(bin_maxbins=25, quantitative(:y), axis=nothing).
		encoding_x(aggregate=:count, scale_domain=[-1,2], title="")
	)
).config_view_stroke(:transparent)

# ╔═╡ c84e541c-1b89-11eb-1677-91e7959b11df
VL.width(400).height(100).
data_values([
		(x= 1,  y= 28), (x= 2,  y= 55),
		(x= 3,  y= 43), (x= 4,  y= 91),
		(x= 5,  y= 81), (x= 6,  y= 53),
		(x= 7,  y= 19), (x= 8,  y= 87),
		(x= 9,  y= 52), (x= 10, y= 48),
		(x= 11, y= 24), (x= 12, y= 49),
		(x= 13, y= 87), (x= 14, y= 66),
		(x= 15, y= 17), (x= 16, y= 27),
		(x= 17, y= 68), (x= 18, y= 16),
		(x= 19, y= 49), (x= 20, y= 15)
    ]
  ).
encoding_x(quantitative(:x), scale=(zero=false, nice=false)).
encoding_y(quantitative(:y), scale_domain=[0,50], axis_title=:y).
layer_mark(type=:area, clip=true, orient=:vertical, opacity= 0.6, line=true).
layer(transform= [(calculate= "datum.y - 50", as= :ny)],
      mark=(type=:area, clip=true, orient=:vertical, line=true),
      VL.encoding_y(quantitative(:ny), scale_domain= [0,50]).
	  encoding_opacity_value(0.3)
	).
config_area_interpolate(:monotone).
config_line(interpolate=:monotone, )

# ╔═╡ 5d393f90-1b8c-11eb-28bb-ad60c99fd0ed


# ╔═╡ Cell order:
# ╠═a1e1c328-1a02-11eb-2d14-9589688b268e
# ╠═af76a2e2-1a02-11eb-0cd6-3768598c1a14
# ╟─84238b3c-1a2a-11eb-3091-e7799304f61f
# ╠═a7d385f0-1a32-11eb-153d-2b093d4c9741
# ╟─b95d0b16-1a2a-11eb-0414-a56ce3f0d4a1
# ╟─1260b984-1c55-11eb-1c20-bb8ac524c5a7
# ╟─868786d0-1a2a-11eb-3533-537469d8b03a
# ╠═c6a4d1a0-1a2a-11eb-23e9-5f0d63ef7986
# ╟─d8d6b878-1a2a-11eb-07ae-290e07793327
# ╟─c84e541c-1b89-11eb-1677-91e7959b11df
# ╠═5d393f90-1b8c-11eb-28bb-ad60c99fd0ed
