package nanomsg;

/**
 *
 */
@:enum
abstract NanoLevel(Int) from Int to Int
{
    // transport-specific levels
    var INPROC     = -1;
    var IPC        = -2;
    var TCP        = -3;
    var WS         = -4;

    // generic socket-level
    var SOL_SOCKET = 0;

    // socket-type-specific levels
    var PAIR       = 16;
    var REQ        = 48;
    var REP        = 49;
    var PUB        = 32;
    var SUB        = 33;
    var PUSH       = 80;
    var PULL       = 81;
    var SURVEYOR   = 96;
    var RESPONDENT = 97;
    var BUS        = 112;
}
