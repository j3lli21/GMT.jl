"""
	grd2cpt(cmd0::String="", arg1=nothing, kwargs...)

Make linear or histogram-equalized color palette table from grid

Full option list at [`grd2cpt`]($(GMTdoc)grd2cpt.html)

Parameters
----------

- **A** | **alpha** | **transparency** :: [Type => Str]

    Sets a constant level of transparency (0-100) for all color slices.
    ($(GMTdoc)grd2cpt.html#a)
- $(GMT.opt_C)
- **D** | **bg** | **background** :: [Type => Str | []]			`Arg = [i|o]`

    Select the back- and foreground colors to match the colors for lowest and highest
    z-values in the output CPT. 
    ($(GMTdoc)grd2cpt.html#d)
- **E** | **nlevels** :: [Type => Int | []]		`Arg = [nlevels]`

    Create a linear color table by using the grid z-range as the new limits in the CPT.
    Alternatively, append nlevels and we will resample the color table into nlevels equidistant slices.
    ($(GMTdoc)grd2cpt.html#e)
- **F** | **color_model** :: [Type => Str | []]		`Arg = [R|r|h|c][+c]]`

    Force output CPT to written with r/g/b codes, gray-scale values or color name.
    ($(GMTdoc)grd2cpt.html#f)
- **G** | **truncate** :: [Type => Str]             `Arg = zlo/zhi`

    Truncate the incoming CPT so that the lowest and highest z-levels are to zlo and zhi.
    ($(GMTdoc)grd2cpt.html#g)
- **I** | **inverse** | **reverse** :: [Type => Str]	    `Arg = [c][z]`

    Reverse the sense of color progression in the master CPT.
    ($(GMTdoc)grd2cpt.html#i)
- **L** | **range** :: [Type => Str]			`Arg = minlimit/maxlimit`

    Limit range of CPT to minlimit/maxlimit, and don’t count data outside this range when estimating CDF(Z).
    [Default uses min and max of data.]
    ($(GMTdoc)grd2cpt.html#l)
- **M** | **overrule_bg** :: [Type => Bool]

    Overrule background, foreground, and NaN colors specified in the master CPT with the values of
    the parameters COLOR_BACKGROUND, COLOR_FOREGROUND, and COLOR_NAN.
    ($(GMTdoc)grd2cpt.html#m)
- **N** | **no_bg** | **nobg** :: [Type => Bool]

    Do not write out the background, foreground, and NaN-color fields.
    ($(GMTdoc)grd2cpt.html#n)
- **Q** | **log** :: [Type => Bool]

    Selects a logarithmic interpolation scheme [Default is linear].
    ($(GMTdoc)grd2cpt.html#q)
- $(GMT.opt_R)
- **S** | **symetric** :: [Type => Str]			`Arg = h|l|m|u`

    Force the color table to be symmetric about zero (from -R to +R).
    ($(GMTdoc)grd2cpt.html#s)

- **T** | **range** :: [Type => Str]			`Arg = (min,max,inc) or = "n"`

    Set steps in CPT. Calculate entries in CPT from zstart to zstop in steps of (zinc). Default
    chooses arbitrary values by a crazy scheme based on equidistant values for a Gaussian CDF.
    ($(GMTdoc)grd2cpt.html#t)
- $(GMT.opt_V)
- **W** | **wrap** | **categorical** :: [Type => Bool | Str | []]      `Arg = [w]`

    Do not interpolate the input color table but pick the output colors starting at the
    beginning of the color table, until colors for all intervals are assigned.
    ($(GMTdoc)grd2cpt.html#w)
- **Z** | **continuous** :: [Type => Bool]

    Creates a continuous CPT [Default is discontinuous, i.e., constant colors for each interval].
    ($(GMTdoc)grd2cpt.html#z)
- $(GMT.opt_V)
- $(GMT.opt_write)
"""
function grd2cpt(cmd0::String="", arg1=nothing; kwargs...)

	length(kwargs) == 0 && occursin(" -", cmd0) && return monolitic("grd2cpt", cmd0, arg1)

	d = init_module(false, kwargs...)[1]		# Also checks if the user wants ONLY the HELP mode

    cmd, = parse_common_opts(d, "", [:R :V_params])
	cmd = helper_cpt(d, cmd)[1]                 # Still left to be seen how to deal with an eventual Tvec (BUG here then)
	if ((val = find_in_dict(d, [:E :nlevels])[1]) !== nothing)  cmd *= " -E" * arg2str(val)  end

	cmd, got_fname, arg1 = find_data(d, cmd0, cmd, arg1)
	N_used = got_fname == 0 ? 1 : 0			# To know whether a cpt will go to arg1 or arg2
	cmd, arg1, arg2, = add_opt_cpt(d, cmd, CPTaliases, 'C', N_used, arg1)

    r = common_grd(d, "grd2cpt " * cmd, arg1, arg2)
	current_cpt[1] = (r !== nothing) ? r : GMTcpt()
    return r
end

# ---------------------------------------------------------------------------------------------------
grd2cpt(arg1; kw...) = grd2cpt("", arg1; kw...)