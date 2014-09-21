package nanomsg;

#if cpp
    import cpp.Lib;
#elseif neko
    import neko.Lib;
#else
    #error "The nanomsg library is only available on C++ and Neko targets"
#end
import lib.Error;

/**
 * Haxe FFI loaded class.
 */
class Loader
{
    /**
     * Stores the name of the library to load from.
     *
     * @var String
     */
    private static inline var library:String = "libhxnanomsg";

    #if neko
    // initializes the Neko API so alloc_null() etc. becomes valid
    private static var neko_init = {
        var i = Lib.load(Loader.library, "neko_init", 5);
        if (i != null) {
            i(function(s) return new String(s),
              function(len:Int) { var r = []; if (len > 0) r[len - 1] = null; return r; },
              null, true, false
            );
            i;
        } else {
            throw new Error("Could not find NekoAPI @ " + Loader.library);
        }
    }
    #end


    /**
     * Loads and returns the function defined by 'fn' from the native library.
     *
     * @param String fn    the function to load
     * @param Int    nargs the number of arguments the function expects
     *
     * @return Dynamic
     *
     * @throws lib.Error if the function could not be loaded
     */
    public static function load(fn:String, nargs:Int):Dynamic
    {
        try {
            #if NANOMSG_LOADLAZY
                return Lib.loadLazy(Loader.library, fn, nargs);
            #else
                return Lib.load(Loader.library, fn, nargs);
            #end
        } catch (ex:Dynamic) {
            throw new Error(ex);
        }
    }
}
