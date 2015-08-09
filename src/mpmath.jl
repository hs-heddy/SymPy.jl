## in mpmath module
## These are not right!!!
## see hyper and meijerg to indicate what needs to be done for these special function
## they really need to be coordinated with `Julia`'s as well.
mpmath_fns = (:hyp0f1, 
           :hyp1f1, :hyp1f2, 
           :hyp2f0, :hyp2f1, :hyp2f2, :hyp2f3,
           :hyp3f2,
           :hypercomb,
#           :meijerg,
           :bihyper,
           :hyper2d,
           :appellf1, :appellf2, :appellf3, :appellf4,
           :ber,:bei,:ker,:kei,
           :struveh,:struvel,
           :angerj,
           :webere,
           :coulombc,
           :legenp, :legenq,
           :chebyt, :chebyu, 
           :pcfd, :pcfu, :pcfv, :pcfw,
           :lommels1, :lommels2,
           :coulombf, :coulombg,
           :hyperu,
           :whitm, :whitw,
           :scorergi, :scorerhi,
           :spherharm,
           :airyaizero, :airybizero, 
           :besseljzero, :besselyzero
           )
for fn in mpmath_fns
    meth = string(fn)
    @eval ($fn)(xs::Union(Sym, Number)...;kwargs...) = mpmath_meth(symbol($meth), xs...; kwargs...)
    eval(Expr(:export, fn))
end


function init_mpmath()
    PyCall.mpmath_init()
    ## try to load mpmath module
    try
        const global mpmath = pyimport("sympy.mpmath")
    catch err
        try
            const global mpmath = pyimport("mpmath")
        catch err
            const global mpmath = nothing
        end
    end
    if !isa(mpmath, Nothing)
        ## ignore warnings for now...
        mpftype = mpmath["mpf"]
        pytype_mapping(mpftype, BigFloat) ## Raises warning!!!
        mpctype = mpmath["mpc"]
        pytype_mapping(mpctype, Complex{BigFloat})
    end

    global mpmath_meth(meth::Symbol, args...; kwargs...) = begin
        if isa(mpmath, Nothing)
            warn("The mpmath module of Python is not installed. http://docs.sympy.org/dev/modules/mpmath/setup.html#download-and-installation")
            return(Sym(NaN))
        end

        fn = mpmath[meth]
        ans = call_sympy_fun(fn, args...; kwargs...)
        ## make nicer...
        if isa(ans, Vector)
            ans = Sym[i for i in ans]
        end
        ans
    end
end