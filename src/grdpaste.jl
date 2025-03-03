"""
	grdpaste(cmd0::String="", arg1=nothing, arg2=nothing, kwargs...)

Combine grids ``grid1`` and ``grid2`` into ``grid3`` by pasting them together along their common edge.
Both grids must have the same dx, dy and have one edge in common.

Full option list at [`grdpaste`]($(GMTdoc)grdpaste.html)

Parameters
----------

- **G** | **save** | **outgrid** | **outfile** :: [Type => Str]

    Output grid file name. Note that this is optional and to be used only when saving
    the result directly on disk. Otherwise, just use the G = grdpaste(....) form.
    ($(GMTdoc)grdpaste.html#g)
- $(GMT.opt_V)
- $(GMT.opt_f)
"""
function grdpaste(cmd0::String="", arg1=nothing, arg2=nothing; kwargs...)

	d = init_module(false, kwargs...)[1]		# Also checks if the user wants ONLY the HELP mode
	cmd, = parse_common_opts(d, "", [:G :V_params :f])

	cmd, got_fname, arg1, arg2 = find_data(d, cmd0, cmd, arg1, arg2)
	return common_grd(d, "grdpaste " * cmd, arg1, arg2)		# Finish build cmd and run it
end

# ---------------------------------------------------------------------------------------------------
grdpaste(arg1, arg2=nothing, cmd0::String=""; kw...) = grdpaste(cmd0, arg1, arg2; kw...)
