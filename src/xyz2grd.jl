"""
	xyz2grd(cmd0::String="", arg1=nothing; kwargs...)

Convert data table to a grid file. 

Full option list at [`xyz2grd`]($(GMTdoc)xyz2grd.html)

Parameters
----------

- $(GMT.opt_I)
    ($(GMTdoc)xyz2grd.html#i)
- $(GMT.opt_R)
- **A** | **multiple_nodes** :: [Type => Str]      `Arg = [d|f|l|m|n|r|S|s|u|z]`

    By default we will calculate mean values if multiple entries fall on the same node.
    Use A to change this behavior.
    ($(GMTdoc)xyz2grd.html#a)
- **D** | **header** :: [Type => Str]  `Arg = [+xxname][+yyname][+zzname][+sscale][+ooffset][+ninvalid][+ttitle][+rremark]`

    Output edges
    ($(GMTdoc)xyz2grd.html#d)
- **G** | **save** | **outgrid** | **outfile** :: [Type => Str]

    Output grid file name. Note that this is optional and to be used only when saving
    the result directly on disk. Otherwise, just use the G = grdclip(....) form.
    ($(GMTdoc)xyz2grd.html#g)
- $(GMT.opt_J)
- **S** | **swap** :: [Type => Str | []]        `Arg = [zfile]`

    Swap the byte-order of the input only. No grid file is produced.
    ($(GMTdoc)xyz2grd.html#s)
- $(GMT.opt_V)
- **Z** | **flags** :: [Type => Str]

    Read a 1-column table. This assumes that all the nodes are present and sorted according to specified ordering convention contained in. ``flags``.
    ($(GMTdoc)xyz2grd.html#z)
- $(GMT.opt_bi)
- $(GMT.opt_di)
- $(GMT.opt_e)
- $(GMT.opt_f)
- $(GMT.opt_h)
- $(GMT.opt_i)
- $(GMT.opt_r)
- $(GMT.opt_w)
- $(GMT.opt_swap_xy)
"""
function xyz2grd(cmd0::String="", arg1=nothing; kwargs...)

	length(kwargs) == 0 && return monolitic("xyz2grd", cmd0, arg1)

	d = init_module(false, kwargs...)[1]		# Also checks if the user wants ONLY the HELP mode

	cmd, = parse_common_opts(d, "", [:G :RIr :J :V_params :bi :di :e :f :h :i :w :yx])
	cmd  = parse_these_opts(cmd, d, [[:A :multiple_nodes], [:D :header], [:S :swap], [:Z :flags]])
	if (cmd0 == "" && arg1 === nothing)
		(haskey(d, :x) && haskey(d, :y) && haskey(d, :z)) && (arg1 = hcat(d[:x], d[:y], d[z]))
	end
	common_grd(d, cmd0, cmd, "xyz2grd ", arg1)		# Finish build cmd and run it
end

# ---------------------------------------------------------------------------------------------------
xyz2grd(arg1, cmd0::String=""; kw...) = xyz2grd(cmd0, arg1; kw...)