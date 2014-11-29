package nanomsg;

import haxe.io.Bytes;
import haxe.io.BytesData;
import hext.Closure;
import hext.IllegalArgumentException;
import hext.IllegalStateException;
import nanomsg.Loader;
import nanomsg.NanoDomain;
import nanomsg.NanoException;
import nanomsg.NanoFlag;
import nanomsg.NanoLevel;
import nanomsg.NanoOption;
import nanomsg.NanoProtocol;

using hext.ArrayTools;
using hext.IterableTools;

/**
 * Wrapper class around the native nanomsg functions provided through the Haxe C FFI:
 *
 * @link http://nanomsg.org/
 */
class NanoSocket
{
    /**
     * References to the native nanomsg function implementations loaded through C FFI.
     */
    private static var _bind:Socket->String->Connection         = Loader.load("hx_nn_bind", 2);
    private static var _close:Socket->Int                       = Loader.load("hx_nn_close", 1);
    private static var _connect:Socket->String->Connection      = Loader.load("hx_nn_connect", 2);
    private static var _device:Socket->Socket->Void             = Loader.load("hx_nn_device", 2);
    private static var _getsockopt:Socket->Int->Int->Int        = Loader.load("hx_nn_getsockopt", 3);
    private static var _poll:Array<Socket>->Array<Socket>->Array<Socket>->Int->Dynamic = Loader.load("hx_nn_poll", 4);
    private static var _recv:Socket->Int->NanoFlag->BytesData   = Loader.load("hx_nn_recv", 3);
    private static var _recv_all:Socket->NanoFlag->BytesData    = Loader.load("hx_nn_recv_all", 2);
    private static var _send:Socket->BytesData->Int->NanoFlag->Int = Loader.load("hx_nn_send", 4);
    private static var _setsockopt:Socket->NanoLevel->NanoOption->Dynamic->Int = Loader.load("hx_nn_setsockopt", 4);
    private static var _shutdown:Socket->Connection->Int        = Loader.load("hx_nn_shutdown", 2);
    private static var _socket:NanoDomain->NanoProtocol->Socket = Loader.load("hx_nn_socket", 2);
    private static var _term:Closure                            = Loader.load("hx_nn_term", 0);

    /**
     * Stores the underlaying libnanomsg Socket.
     *
     * @var Null<nanomsg.NanoSocket.Socket>;
     */
    private var handle:Null<Socket>;

    /**
     * Stores the Connections the Socket has been binded/connected to.
     *
     * @var List<nanomsg.NanoSocket.Connection>
     */
    @:final private var conns:List<Connection>;


    /**
     * Constructor to initialize a new NanoSocket instance.
     *
     * @param nanomsg.NanoDomain   domain the domain type to use
     * @param nanomsg.NanoProtocol protocol the protocol to use
     *
     * @throws nanomsg.NanoException if the socket initialization fails
     */
    public function new(domain:NanoDomain, protocol:NanoProtocol):Void
    {
        try {
            this.handle = NanoSocket._socket(domain, protocol)  /* < 0? */;
        } catch (ex:Dynamic) {
            throw new NanoException(ex);
        }
        this.conns = new List<Connection>();
    }

    /**
     * Binds the Socket to the given address.
     *
     * @param nanomsg.NanoAddress address the address to bind to
     *
     * @return nanomsg.NanoSocket.Connection the opened Connection
     *
     * @throws hext.IllegalStateException if the instance has already been cleaned up
     * @throws nanomsg.NanoException      if the FFI call raises an error
     */
    public function bind(address:NanoAddress):Connection
    {
        if (this.handle == null) {
            throw new IllegalStateException("NanoSocket not available");
        }

        try {
            var cnx:Connection = NanoSocket._bind(this.handle, address) /* < 0? */;
            this.conns.add(cnx);

            return cnx;
        } catch (ex:Dynamic) {
            throw new NanoException(ex);
        }
    }

    /**
     * Closes the Socket and all open Connections it has.
     *
     * @param Bool force if true sets NN_LINGER to 0 so no tries are made to deliver outstanding
     * messages before the socket is closed
     *
     * @throws hext.IllegalStateException if the instance has already been cleaned up
     * @throws nanomsg.NanoException      if the FFI call raises an error
     */
    public function close(force:Bool = false):Void
    {
        if (this.handle == null) {
            throw new IllegalStateException("NanoSocket not available");
        }

        if (force) {
            this.setOption(NanoLevel.SOL_SOCKET, NanoOption.LINGER, 0);
        }
        for (cnx in this.conns.toList()) { // make sure we iterate over copy
            this.shutdown(cnx);
        }

        try {
            NanoSocket._close(this.handle) /* == 0? */;
            this.handle = null;
        } catch (ex:Dynamic) {
            throw new NanoException(ex);
        }
    }

    /**
     * Connects to the given TransportAddress.
     *
     * @param nanomsg.NanoAddress address the address to connect to
     *
     * @return nanomsg.NanoSocket.Connection the connection ID
     *
     * @throws hext.IllegalStateException if the instance has already been cleaned up
     * @throws nanomsg.NanoException      if the FFI call raises an error
     */
    public function connect(address:NanoAddress):Connection
    {
        if (this.handle == null) {
            throw new IllegalStateException("NanoSocket not available");
        }

        try {
            var cnx:Connection = NanoSocket._connect(this.handle, address) /* < 0? */;
            this.conns.add(cnx);

            return cnx;
        } catch (ex:Dynamic) {
            throw new NanoException(ex);
        }
    }

    /**
     * Starts a device to forward messages between two sockets.
     *
     * @param nanomsg.NanoSocket x the first socket to link
     * @param nanomsg.NanoSocket x the second socket to link
     *
     * @throws hext.IllegalStateException if one of the instances has already been cleaned up
     * @throws nanomsg.NanoException      if the FFI call raises an error
     */
    public static function device(x:NanoSocket, y:NanoSocket):Void
    {
        if (x == null || x.handle == null || y == null || y.handle == null) {
            throw new IllegalStateException("One of the input sockets is unavailable");
        }

        try {
            NanoSocket._device(x.handle, y.handle);
        } catch (ex:Dynamic) {
            throw new NanoException(ex);
        }
    }

    /**
     * Returns the value of the given option.
     *
     * @param nanomsg.NanoLevel  level  the level on which the option is valid
     * @param nanomsg.NanoOption option the option to get the value for
     *
     * @return Int the option's value
     *
     * @throws hext.IllegalStateException if the instance has already been cleaned up
     * @throws nanomsg.NanoException      if the FFI call raises an error
     */
    public function getOption(level:NanoLevel, option:NanoOption):Int
    {
        if (this.handle == null) {
            throw new IllegalStateException("NanoSocket not available");
        }

        try {
            return NanoSocket._getsockopt(this.handle, level, option);
        } catch (ex:Dynamic) {
            throw new NanoException(ex);
        }
    }

    /**
     * Polls a set of SP sockets for readability and/or writability.
     *
     * @param Null<Array<nanomsg.NanoSocket>> reads  NanoSocket to observ for readability
     * @param Null<Array<nanomsg.NanoSocket>> writes NanoSocket to observ for writability
     * @param Null<Array<nanomsg.NanoSocket>> boths  NanoSocket to observ for readability or writability
     *
     * @return Array<Array<nanomsg.NanoSocket>> where [0] are the sockets to read and [1] to write
     */
    public static function poll(reads:Null<Array<NanoSocket>>, writes:Null<Array<NanoSocket>>, timeout:Float = 0.2):Array<Array<NanoSocket>>
    {
        // preparation
        var rhandles:Array<Null<Socket>>;
        var whandles:Array<Null<Socket>>;
        var bhandles:Array<Socket>;
        if (reads == null || reads.length == 0) {
            rhandles = new Array<Socket>();
        } else {
            rhandles = reads.map(function(sock:NanoSocket):Null<Socket> {
                return sock.handle;
            });
            rhandles.purge(null);
        }
        if (writes == null || writes.length == 0) {
            whandles = new Array<Socket>();
        } else {
            whandles = writes.map(function(sock:NanoSocket):Null<Socket> {
                return sock.handle;
            });
            whandles.purge(null);
        }
        if (rhandles.length == 0 || whandles.length == 0) {
            bhandles = new Array<Socket>();
        } else {
            bhandles = rhandles.filter(function(handle:Socket):Bool {
                return whandles.contains(handle);
            });
            rhandles.purgeAll(bhandles);
            whandles.purgeAll(bhandles);
        }

        try {
            // polling
            var ret:Array<Array<Null<Socket>>> = NanoSocket._poll(rhandles, whandles, bhandles, Std.int(timeout * 1000));
            if (ret != null) {
                // postprocessing
                var polls:Array<Array<NanoSocket>> = [ new Array<NanoSocket>(), new Array<NanoSocket>() ];
                if (ret[0].length != 0) {
                    polls[0] = reads.filter(function(sock:NanoSocket):Bool {
                        return ret[0].contains(sock.handle);
                    });
                    polls[0].purge(null);
                }
                if (ret[1].length != 0) {
                    polls[1] = writes.filter(function(sock:NanoSocket):Bool {
                        return ret[1].contains(sock.handle);
                    });
                    polls[1].purge(null);
                }

                return polls;
            }
        } catch (ex:Dynamic) {
            throw new NanoException(ex);
        }

        return new Array<Array<NanoSocket>>();
    }

    /**
     * Reads 'nbytes' from the Socket's input stream.
     *
     * If the 'DONTWAIT' flag is passed, the action will be performed in non-blocking mode.
     *
     * @param Int              nbytes the number of bytes to read
     * @param nanomsg.NanoFlag flags  flags defining how to receive the message
     *
     * @return haxe.io.Bytes the read Bytes
     *
     * @throws hext.IllegalArgumentException if the number of bytes to read is negative
     * @throws hext.IllegalStateException    if the instance has already been cleaned up
     * @throws nanomsg.NanoException         if the FFI call raises an error
     */
    public function read(nbytes:Int, flags:NanoFlag = NanoFlag.NONE):Bytes
    {
        if (nbytes < 0) {
            throw new IllegalArgumentException("Cannot read negative number of bytes");
        }
        if (this.handle == null) {
            throw new IllegalStateException("NanoSocket not available");
        }

        var read:Bytes;
        if (nbytes == 0) {
            read = Bytes.alloc(0);
        } else {
            try {
                read = Bytes.ofData(NanoSocket._recv(this.handle, nbytes, flags));
            } catch (ex:Dynamic) {
                throw new NanoException(ex);
            }
        }

        return read;
    }

    /**
     * Reads everything from the Socket.
     *
     * If the 'DONTWAIT' flag is passed, the action will be performed in non-blocking mode.
     *
     * @param nanomsg.NanoFlag flags flags defining how to receive the message
     *
     * @return haxe.io.Bytes the read Bytes
     *
     * @throws hext.IllegalStateException if the instance has already been cleaned up
     * @throws nanomsg.NanoException      if the FFI call raises an error
     */
    public function readAll(flags:NanoFlag = NanoFlag.NONE):Bytes
    {
        if (this.handle == null) {
            throw new IllegalStateException("NanoSocket not available");
        }

        try {
            return Bytes.ofData(NanoSocket._recv_all(this.handle, flags));
        } catch (ex:Dynamic) {
            throw new NanoException(ex);
        }
    }

    /**
     * Sets the value of the given option.
     *
     * @param nanomsg.NanoLevel  level  the level on which the option is valid
     * @param nanomsg.NanoOption option the option to set the value for
     * @param Dynamic            value  the value to set for the option
     *
     * @return nanomsg.NanoSocket this instance
     *
     * @throws hext.IllegalStateException if the instance has already been cleaned up
     * @throws nanomsg.NanoException      if the FFI call raises an error
     */
    public function setOption(level:NanoLevel, option:NanoOption, value:Dynamic):NanoSocket
    {
        if (this.handle == null) {
            throw new IllegalStateException("NanoSocket not available");
        }

        try {
            NanoSocket._setsockopt(this.handle, level, option, value) /* == 0 ?*/;
        } catch (ex:Dynamic) {
            throw new NanoException(ex);
        }

        return this;
    }

    /**
     * Closes the open Connection and removes it from the Socket.
     *
     * @param nanomsg.NanoSocket.Connection cnx the Connection to shutdown
     *
     * @throws hext.IllegalStateException if the instance has already been cleaned up
     * @throws nanomsg.NanoException      if the FFI call raises an error
     */
    public function shutdown(cnx:Connection):Void
    {
        if (this.handle == null) {
            throw new IllegalStateException("NanoSocket not available");
        }

        try {
            NanoSocket._shutdown(this.handle, cnx) /* == 0 ?*/;
            this.conns.remove(cnx);
        } catch (ex:Dynamic) {
            throw new NanoException(ex);
        }
    }

    /**
     * To help with shutdown of multi-threaded programs nanomsg provides the nn_term() function
     * which informs all the open sockets that process termination is underway.
     */
    public static inline function terminate():Void
    {
        NanoSocket._term();
    }

    /**
     * Writes the provided Bytes to the Socket.
     *
     * If the 'DONTWAIT' flag is passed, the action will be performed in non-blocking mode.
     *
     * @param Null<haxe.io.Bytes> bytes the Bytes to send
     * @param nanomsg.NanoFlag    flags flags defining how to send the message
     *
     * @return Int the number of written bytes
     *
     * @throws hext.IllegalStateException if the instance has already been cleaned up
     * @throws nanomsg.NanoException      if the FFI call raises an error
     */
    public function write(bytes:Null<Bytes>, flags:NanoFlag = NanoFlag.NONE):Int
    {
        if (this.handle == null) {
            throw new IllegalStateException("NanoSocket not available");
        }

        var sent:Int;
        if (bytes == null || bytes.length == 0) {
            sent = 0;
        } else {
            try {
                sent = NanoSocket._send(this.handle, bytes.getData(), bytes.length, flags);
            } catch (ex:Dynamic) {
                throw new NanoException(ex);
            }
        }

        return sent;
    }
}


/**
 * Extern for nanomsg connections.
 *
 * Connections are nothing other than Ints (file descriptors).
 */
extern class Connection {}

/**
 * Extern for nanomsg sockets.
 *
 * Sockets are nothing other than Ints (file descriptors).
 */
private extern class Socket {}
