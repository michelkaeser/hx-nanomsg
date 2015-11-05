package nanomsg;

/**
 * Enum for the domain types nanomsg accepts.
 *
 * @link http://nanomsg.org/v0.7/nn_socket.3.html
 */
@:enum
abstract NanoDomain(Int) from Int to Int
{
    var AF_SP     = 1;
    var AF_SP_RAW = 2;
}
