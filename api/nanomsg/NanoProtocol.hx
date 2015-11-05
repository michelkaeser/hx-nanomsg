package nanomsg;

/**
 * Enum for the scalability protocols nanomsg supports.
 */
@:enum
abstract NanoProtocol(Int) from Int to Int
{
    // http://nanomsg.org/v0.7/nn_pair.7.html
    var PAIR = 1 * 16 + 0;

    // http://nanomsg.org/v0.7/nn_pubsub.7.html
    var PUB = 2 * 16 + 0;
    var SUB = 2 * 16 + 1;

    // http://nanomsg.org/v0.7/nn_reqrep.7.html
    var REQ = 3 * 16 + 0;
    var REP = 3 * 16 + 1;

    // http://nanomsg.org/v0.7/nn_pipeline.7.html
    var PUSH = 5 * 16 + 0;
    var PULL = 5 * 16 + 1;

    // http://nanomsg.org/v0.7/nn_survey.7.html
    var SURVEYOR   = 6 * 16 + 2;
    var RESPONDENT = 6 * 16 + 3;

    // http://nanomsg.org/v0.7/nn_bus.7.html
    var BUS = 7 * 16 + 0;
}
