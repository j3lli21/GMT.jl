"""
	mask(cmd0::String="", arg1=nothing; kwargs...)

Reads (length,azimuth) pairs from file and plot a windmask diagram.

Full option list at [`psmask`]($(GMTdoc)mask.html)

Parameters
----------

- $(GMT.opt_I)
    ($(GMTdoc)mask.html#i)
- $(GMT.opt_R)

- $(GMT.opt_B)
- **C** | **end_clip_path** :: [Type => Bool]

    Mark end of existing clip path. No input file is needed.
    ($(GMTdoc)mask.html#c)
- **D** | **dump** :: [Type => Str]

    Dump the (x,y) coordinates of each clipping polygon to one or more output files
    (or stdout if template is not given).
    ($(GMTdoc)mask.html#d)
- **F** | **oriented_polygons** :: [Type => Str | []]

    Force clip contours (polygons) to be oriented so that data points are to the left (-Fl [Default]) or right (-Fr) 
    ($(GMTdoc)mask.html#f)
- **G** | **fill** :: [Type => Number | Str]

    Set fill shade, color or pattern for positive and/or negative masks [Default is no fill].
    ($(GMTdoc)mask.html#g)
- $(GMT.opt_J)
- $(GMT.opt_Jz)
- **L** | **node_grid** :: [Type => Str]

    Save the internal grid with ones (data constraint) and zeros (no data) to the named nodegrid.
    ($(GMTdoc)mask.html#l)
- **N** | **invert** :: [Type => Bool]

    Invert the sense of the test, i.e., clip regions where there is data coverage.
    ($(GMTdoc)mask.html#n)
- $(GMT.opt_P)
- **Q** | **cut_number** :: [Type => Number | Str]

    Do not dump polygons with less than cut number of points [Dumps all polygons].
    ($(GMTdoc)mask.html#q)
- **S** | **search_radius** :: [Type => Number | Str]

    Sets radius of influence. Grid nodes within radius of a data point are considered reliable.
    ($(GMTdoc)mask.html#s)
- **T** | **tiles** :: [Type => Bool]

    Plot tiles instead of clip polygons. Use -G to set tile color or pattern. Cannot be used with -D.
    ($(GMTdoc)mask.html#t)
- $(GMT.opt_U)
- $(GMT.opt_V)
- $(GMT.opt_X)
- $(GMT.opt_Y)
- $(GMT.opt_bi)
- $(GMT.opt_di)
- $(GMT.opt_e)
- $(GMT.opt_h)
- $(GMT.opt_i)
- $(GMT.opt_p)
- $(GMT.opt_r)
- $(GMT.opt_t)
- $(GMT.opt_w)
- $(GMT.opt_swap_xy)
"""
function mask(cmd0::String="", arg1=nothing; first=true, kwargs...)

    gmt_proggy = (IamModern[1]) ? "mask "  : "psmask "
    length(kwargs) == 0 && return monolitic(gmt_proggy, cmd0, arg1)

	d, K, O = init_module(first, kwargs...)		# Also checks if the user wants ONLY the HELP mode

	cmd, opt_B, opt_J, opt_R = parse_BJR(d, "", "", O, " -JX12c/12c")
	cmd, = parse_common_opts(d, cmd, [:I :UVXY :JZ :c :e :p :r :t :w :params], first)
	cmd  = parse_these_opts(cmd, d, [[:C :end_clip_path], [:D :dump], [:F :oriented_polygons],
	                                 [:L :node_grid], [:N :invert], [:Q :cut_number], [:S :search_radius], [:T :tiles]])

	# If file name sent in, read it and compute a tight -R if this was not provided 
	cmd, arg1, opt_R, = read_data(d, cmd0, cmd, arg1, opt_R)

	cmd = add_opt_fill(cmd, d, [:G :fill], 'G')

	return finish_PS_module(d, gmt_proggy * cmd, "", K, O, true, arg1)
end

# ---------------------------------------------------------------------------------------------------
mask!(cmd0::String="", arg1=nothing; kw...) = mask(cmd0, arg1; first=false, kw...)
mask(arg1,  cmd0::String=""; kw...)  = mask(cmd0, arg1; first=true, kw...)
mask!(arg1, cmd0::String=""; kw...) = mask(cmd0, arg1; first=false, kw...)

const psmask  = mask			# Alias
const psmask! = mask!			# Alias
