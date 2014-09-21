package nanomsg;

/**
 * Enum for the scalability protocols nanomsg supports.
 */
@:enum
abstract NanoProtocol(Int) from Int to Int
{
    // http://nanomsg.org/v0.4/nn_pair.7.html
    var PAIR = 16;

    // http://nanomsg.org/v0.4/nn_pubsub.7.html
    var PUB = 32;
    var SUB = 33;

    // http://nanomsg.org/v0.4/nn_reqrep.7.html
    var REQ = 48;
    var REP = 49;

    // http://nanomsg.org/v0.4/nn_pipeline.7.html
    var PUSH = 80;
    var PULL = 81;

    // http://nanomsg.org/v0.4/nn_survey.7.html
    var SURVEYOR   = 96;
    var RESPONDENT = 97;

    // http://nanomsg.org/v0.4/nn_bus.7.html
    var BUS = 112;
}
