package nanomsg;

import std.NotImplementedException;
import std.Stringable;

/**
 * @abstract
 */
class TransportAddress implements Stringable
{
    /**
     * Stores the address to be used.
     *
     * @var String
     */
    private var address:String;


    /**
     * Constructor to initialize a new TransportAddress instance.
     *
     * @param String address the address to use
     */
    private function new(address:String):Void
    {
        this.address = address;
    }

    /**
     * Returns a stringified version of the address.
     *
     * @return String the address including the protocol prefix
     */
    public function toString():String
    {
        throw new NotImplementedException("Method toString() not implemented in abstract class TransportAddress");
    }
}
