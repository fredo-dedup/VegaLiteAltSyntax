using VegaLite
using DataFrames
using Distributions


df = DataFrame(x= rand(LogNormal(1., 1.),1000))



# using VegaLiteAltSyntax
using Distributions
dat = [ (x=rand(LogNormal(1., 0.2)),) for i in 1:1000 ]

include("src/VegaLiteAltSyntax.jl")
VL = VegaLiteAltSyntax.VL



ttt = VL().encoding_x(bin=true);
println(ttt)


ttt = VL().encoding_x(field=:x, bin=true);
println(ttt)


ttt = VL().encoding_x(VL(field=:x), bin=true);
println(ttt)
VegaLiteAltSyntax.totree(ttt)


ttt = 	VL(width=600).
	mark(type= :bar,
		line_color=:darkgreen,
		stroke=:black, strokeSize=3,
		VL().color(x1=1, y1=1, x2=1, y2=0, gradient=:linear,
		 		stops=[(offset=0, color=:red), (offset=1, color=:darkgreen)]));
println(ttt)

ttt = 	VL(width=600).
	mark(type= :bar,
		line_color=:darkgreen,
		stroke=:black, strokeSize=3,
		color=(x1=1, y1=1, x2=1, y2=0, gradient=:linear,
		 		stops=[(offset=0, color=:red), (offset=1, color=:darkgreen)]));
println(ttt)

ttt = 	VL(width=600).
	mark(type= :bar,
		line_color=:darkgreen,
		stroke=:black, strokeSize=3,
		VL().color(VL().x1(1).y1(1).x2(1).y2(0).y2(:abcd).gradient(:linear),
		 		stops=[(offset=0, color=:red), (offset=1, color=:darkgreen)]));
println(ttt)

ttt = 	VL(width=600).
	mark(type= :bar,
		line_color=:darkgreen,
		stroke=:black, strokeSize=3,
		VL().color(VL().x1(1).y1(1).x2(1).y2(0).y2(:abcd).gradient(:linear),
		 		stops=[(offset=0, color=:red), (offset=1, color=:darkgreen)])).
					mark(type= :bar,
						line_color=:darkgreen,
						stroke=:black, strokeSize=3,
						VL().color(VL().x1(1).y1(1).x2(1).y2(0).y2(:abcd).gradient(:linear),
						 		stops=[(offset=0, color=:red), (offset=1, color=:darkgreen)]));
println(ttt)



ttt = VL(width=600).
	mark(type= :bar,
	line_color=:darkgreen,
	stroke=:black, strokeSize=3,
	VL.color(x1=1, y1=1, x2=1, y2=0, gradient=:linear,
			stops=[(offset=0, color=:red), (offset=1, color=:darkgreen)])).
	data_values(dat).
	encoding_x(field=:x, bin=true ).
	encoding_y(aggregate=:count, type=:quantitative) ;
println(ttt)



using Distributions
dat = [ (x=rand(LogNormal(1., 0.2)),) for i in 1:1000 ]

VL(width=600).
	mark(type= :bar,
		line_color=:darkgreen,
		stroke=:black, strokeSize=3,
		VL.color(x1=1, y1=1, x2=1, y2=0, gradient=:linear,
		 		stops=[(offset=0, color=:red), (offset=1, color=:darkgreen)])).
    data_values(dat).
    encoding_x(field=:x, bin=true ).
	encoding_y(aggregate=:count, type=:quantitative)

dist = MixtureModel( [ MvNormal([2., 2.], 0.5), MvNormal([0., 0.], 0.5) ],
						[ 0.6, 0.4] )
dat2 = [ ((x,y) = rand(dist) ; (x=x, y=y)) for i in 1:10000 ]
ttt = VL(spacing=15, bounds=:flush, data_values=dat2).
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


VegaLiteAltSyntax.totree(ttt)

ttt = (offset=0, color=:red)


Dict(pairs(ttt))


#############
using Distributions
dat = [ (x=rand(LogNormal(1., 0.2)),) for i in 1:1000 ]

include("src/VegaLiteAltSyntax.jl")
VL = VegaLiteAltSyntax.VL


using VegaLiteAltSyntax

VL.width(600).
	mark(type= :tick).
	data_values(dat).
	encoding_x(VegaLiteAltSyntax.quantitative(:x), bin=true)
