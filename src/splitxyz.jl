"""
	gmtsplit(cmd0::String="", arg1=nothing; kwargs...)

Reads a series of (x,y[,z]) records [or optionally (x,y,z,d,h)] and splits this into separate lists
of (x,y[,z]) series, such that each series has a nearly constant azimuth through the x,y plane.

Full option list at [`gmtsplit`]($(GMTdoc)gmtsplit.html)

Parameters
----------

- **A** | **azim_tol** :: [Type => Str | Array]  

    Write out only those segments which are within +/- tolerance degrees of azimuth in heading,
    measured clockwise from North, [0 - 360].
    ($(GMTdoc)gmtsplit.html#a)
- **C** | **course_change** :: [Type => Number]

    Terminate a segment when a course change exceeding course_change degrees of heading is detected.
    ($(GMTdoc)gmtsplit.html#c)
- **D** | **min_dist** | **min_distance** :: [Type => Number]

    Do not write a segment out unless it is at least minimum_distance units long.
    ($(GMTdoc)gmtsplit.html#d)
- **F** | **filter** :: [Type => Str | Array]

    Filter the z values and/or the x,y values, assuming these are functions of d coordinate.
    xy_filter and z_filter are filter widths in distance units.
    ($(GMTdoc)gmtsplit.html#f)
- **Q** | **xyzdh** :: [Type => Str]

    Specify your desired output using any combination of xyzdh, in any order.
    ($(GMTdoc)gmtsplit.html#q)
- **S** | **dh** | **dist_head** :: [Type => Bool]

    Both d and h are supplied. In this case, input contains x,y,z,d,h. [Default expects (x,y,z) input,
    and d,h are computed from delta x, delta y.
    ($(GMTdoc)gmtsplit.html#s)
- $(GMT.opt_V)
- $(GMT.opt_write)
- $(GMT.opt_append)
- $(GMT.opt_bi)
- $(GMT.opt_bo)
- $(GMT.opt_di)
- $(GMT.opt_do)
- $(GMT.opt_e)
- $(GMT.opt_f)
- $(GMT.opt_g)
- $(GMT.opt_h)
- $(GMT.opt_i)
- $(GMT.opt_swap_xy)
"""
function gmtsplit(cmd0::String="", arg1=nothing; kwargs...)

    proggy = (GMTver > v"6.1.1") ? "gmtsplit" : "splitxyz"
	length(kwargs) == 0 && occursin(" -", cmd0) && return monolitic(proggy, cmd0, arg1)

	d = init_module(false, kwargs...)[1]		    # Also checks if the user wants ONLY the HELP mode
	cmd, = parse_common_opts(d, "", [:V_params :bi :bo :di :do :e :f :g :h :i :yx])
	cmd  = parse_these_opts(cmd, d, [[:A :azim_tol], [:C :course_change], [:D :min_dist :min_distance], [:F :filter],
	                                 [:Q :xyzdh], [:S :dh :dist_head]])
	common_grd(d, cmd0, cmd, proggy * " ", arg1)	# Finish build cmd and run it
end

# ---------------------------------------------------------------------------------------------------
gmtsplit(arg1; kw...) = gmtsplit("", arg1; kw...)
const splitxyz = gmtsplit			# Alias