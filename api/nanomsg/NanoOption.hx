package nanomsg;

/**
 * Enum for generic socket options.
 */
@:enum
abstract NanoOption(Int) from Int to Int
{
    // generic socket options (NN_SOL_SOCKET level)
    var LINGER            = 1;
    var SNDBUF            = 2;
    var RCVBUF            = 3;
    var SNDTIMEO          = 4;
    var RCVTIMEO          = 5;
    var RECONNECT_IVL     = 6;
    var RECONNECT_IVL_MAX = 7;
    var SNDPRIO           = 8;
    var RCVPRIO           = 9;
    var SNDFD             = 10;
    var RCVFD             = 11;
    var DOMAIN            = 12;
    var PROTOCOL          = 13;
    var IPV4ONLY          = 14;
    var SOCKET_NAME       = 15;
    var RCVMAXSIZE        = 16;

    // TCP protocol options
    var TCP_NODELAY    = 1;
    var TCPMUX_NODELAY = 1;

    // http://nanomsg.org/v0.7/nn_reqrep.7.html
    var REQ_RESEND_IVL = 1;

    // http://nanomsg.org/v0.7/nn_pubsub.7.html
    var SUB_SUBSCRIBE   = 1;
    var SUB_UNSUBSCRIBE = 2;

    // http://nanomsg.org/v0.7/nn_survey.7.html
    var SURVEYOR_DEADLINE = 1;
}
