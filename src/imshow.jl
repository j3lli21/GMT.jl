"""
    imshow(arg1; kw...)

Is a simple front end to the [`grdimage`](@ref)  [`grdview`](@ref) programs that accepts GMTgrid, GMTimage,
2D array of floats or strings with file names of grids or images. The normal options of the *grdimage*
and *grdview* programs also apply here but some clever guessing of suitable necessary parameters is done
if they are not provided. Contrary to other image producing modules the "show' keyword is not necessary to
display the image. Here it is set by default. If user wants to use *imshow* to create layers of a more complex
fig he can use *show=false* for the intermediate layers.

This module uses some internal logic to decide whether use `grdimge`, `grdview` or `plot`. Namely, when the
`view` option is used `grdview` is choosed and a default vertical scale is assigned. However, sometimes we want
a rotated plot, optionally tilted, but not 3D view. In that case use the option `flat=true`, which forces
the use of `grdimage`.

# Examples
```julia-repl
# Plot vertical shaded illuminated view of the Mexican hat
julia> G = gmt("grdmath -R-15/15/-15/15 -I0.3 X Y HYPOT DUP 2 MUL PI MUL 8 DIV COS EXCH NEG 10 DIV EXP MUL =");
julia> imshow(G, shade="+a45")

# Same as above but add automatic contours
julia> imshow(G, shade="+a45", contour=true)

# Plot a random heat map
julia> imshow(rand(128,128))

# Display a web downloaded jpeg image wrapped into a sinusoidal projection
julia> imshow("http://larryfire.files.wordpress.com/2009/07/untooned_jessicarabbit.jpg", region="d", frame="g", proj="I15", img_in="r", fmt=:jpg)
```
See also: [`grdimage`](@ref)
"""
function imshow(arg1, x::AbstractVector{Float64}=Vector{Float64}(), y::AbstractVector{Float64}=Vector{Float64}(); kw...)
	# Take a 2D array of floats and turn it into a GMTgrid or if input is a string assume it's a file name
	# In this later case try to figure if it's a grid or an image and act accordingly.
	is_image = false
	if (isa(arg1, String))		# If it's string it has to be a file name. Check extension to see if is an image
		ext = splitext(arg1)[2]
		if (ext == "" && arg1[1] != '@' && !isfile(arg1))
			G = mat2grid(arg1, x, y)
		else
			G = arg1
			ext = lowercase(ext)
			(ext == ".jpg" || ext == ".tif" || ext == ".tiff" || ext == ".png" || ext == ".bmp" || ext == ".gif") && (is_image = true)
			snif_GI_set_CTRLlimits(arg1)			# Set CTRL.limits to be eventually used by J=:guess
		end
	elseif (isa(arg1, Array{UInt8}) || isa(arg1, Array{UInt16,3}))
		G = mat2img(arg1; kw...)
	elseif (isGMTdataset(arg1) || (isa(arg1, Matrix{<:Real}) && size(arg1,2) <= 4))
		ginfo = gmt("gmtinfo -C", arg1)
		CTRL.limits[1:4] = ginfo[1].data[1:4]
		return plot(arg1; show=true, kw...)
	else
		G = mat2grid(arg1, x, y, reg=1)							# For displaying, pixel registration is more appropriate
	end

	d = KW(kw)
	see = (!haskey(d, :show)) ? true : see = d[:show]			# No explicit 'show' keyword means show=true

	if (is_image)
		grdimage(G; show=see, kw...)
	else
		if (isa(G, String))		# Guess also if call grdview or grdimage 
			if (get(kw, :JZ, 0) != 0 || get(kw, :Jz, 0) != 0 || get(kw, :zscale, 0) != 0 || get(kw, :zsize, 0) != 0)
				(get(kw, :Q, "") == "" && get(kw, :surf, "") == "" && get(kw, :surftype, "") == "") && (kw = (kw..., Q="s"))
				grdview(G; show=see, kw...)			# String when fname is @xxxx
			else
				grdimage(G; show=see, kw...)
			end
		else	imshow(G; kw...)					# Call the specialized method
		end
	end
end

function imshow(arg1::GMTgrid; kw...)
	# Here the default is to show, but if a 'show' was used let it rule
	d = KW(kw)
	see = (!haskey(d, :show)) ? true : see = d[:show]	# No explicit 'show' keyword means show=true
	if ((cont_opts = find_in_dict(d, [:contour])[1]) !== nothing)
		new_see = see
		see = false			# because here we know that 'see' has to wait till last command
	end
	opt_p, = parse_common_opts(d, "", [:p], true)
	til = find_in_dict(d, [:T :no_interp :tiles])[1]
	flat = (find_in_dict(d, [:flat])[1] !== nothing)		# If true, force the use of grdimage
	if (flat || (opt_p == "" && til === nothing))
		(flat && opt_p != "") && (d[:p] = opt_p[4:end])		# Restore the meanwhile deleted -p option
		R = grdimage("", arg1; show=see, d...)
	else
		zsize = ((val = find_in_dict(d, [:JZ :Jz :zscale :zsize])[1]) !== nothing) ? val : 8
		srf = ((val = find_in_dict(d, [:Q :surf :surftype])[1]) !== nothing) ? val : "i100"
		if (til !== nothing)		# This forces some others
			srf = zsize = nothing	# These are mutually exclusive
			opt_p = " -p180/90"
		end
		R = grdview("", arg1; show=see, p=opt_p[4:end], JZ=zsize, Q=srf, T=til, d...)
	end
	if (isa(cont_opts, Bool))				# Automatic contours
		R = grdcontour!(arg1; J="", show=new_see)
	elseif (isa(cont_opts, NamedTuple))		# Expect a (cont=..., annot=..., ...)
		R = grdcontour!(arg1; J="", show=new_see, cont_opts...)
	end
	return R
end

function imshow(arg1::GMTimage; kw...)
	# Here the default is to show, but if a 'show' was used let it rule
	see = (!haskey(kw, :show)) ? true : see = kw[:show]	# No explicit 'show' keyword means show=true
	if (isa(arg1.image, Array{UInt16}))
		I = mat2img(arg1; kw...)
		d = KW(kw)			# Needed because we can't delete from kwargs
		(haskey(kw, :stretch) || haskey(kw, :histo_bounds)) && del_from_dict(d, [:histo_bounds :stretch])
		grdimage("", I; D=true, show=see, d...)
	else
		grdimage("", arg1; D=true, show=see, kw...)
	end
end

if (GMTver >= v"6")			# Needed to cheat the autoregister autobot
	function imshow(arg1::Gdal.AbstractDataset; kw...)
		(Gdal.OGRGetDriverByName(Gdal.shortname(getdriver(arg1))) != C_NULL) && return plot(gd2gmt(arg1), show=1)
		imshow(gd2gmt(arg1); kw...)
	end
end

imshow(x::AbstractVector{Float64}, y::AbstractVector{Float64}, f::Function; kw...) = imshow(mat2grid(f, x, y); kw...)

function snif_GI_set_CTRLlimits(G_I)::Bool
	# Set CTRL.limits to be eventually used by J=:guess
	(G_I == "") && return false
	(isa(G_I, String) && (G_I[1] == '@' || startswith(G_I, "http"))) && return false	# Remote files are very dangerous to sniff in
	ginfo = grdinfo(G_I, C=:n)
	if (isa(ginfo, Vector{<:GMTdataset}) && ginfo[1].data[2] != ginfo[1].data[9] && ginfo[1].data[4] != ginfo[1].data[10])
		CTRL.limits[1:4] = ginfo[1].data[1:4]
		return true
	else
		CTRL.limits[1:6] = zeros(6)
	end
	return false
end

imshow(x::AbstractVector{Float64}, f::Function; kw...) = imshow(x, x, f::Function; kw...) 
imshow(f::Function, x::AbstractVector{Float64}; kw...) = imshow(x, x, f::Function; kw...) 
imshow(f::Function, x::AbstractVector{Float64}, y::AbstractVector{Float64}; kw...) = imshow(x, y, f::Function; kw...) 
imshow(x::AbstractVector{Float64}, y::AbstractVector{Float64}, f::String; kw...) = imshow(f::String, x, y; kw...) 
imshow(x::AbstractVector{Float64}, f::String; kw...) = imshow(f::String, x, x; kw...) 