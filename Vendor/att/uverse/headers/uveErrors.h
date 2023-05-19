//
//  uveErrors.h
//
//  Created by Arnold Goldberg on 3/21/11.
//  Copyright 2011 AT&T Labs, Inc. All rights reserved.
//

/*! \file uveErrors.h
 */

/*! \enum uveErrorCodes
 An enumeration of error codes returned by the Uverse Connected library
 */
typedef enum
{
    uveInternalError                = 3000, /**< An Internal Error. */
    uveNetworkError                 = 3001, /**< A Network Error. */
    uveApplicationBlocked           = 3002, /**< This application has been blocked by AT&T. */ 
    uveDeviceRegistrationError      = 3003, /**< Failed to register this device with the server. */
    uveAuthTokenRequired            = 3004, // An Authentication Token must be supplied.
    uveAuthTokenInvalid             = 3005, // The supplied Authentication Token was invalid.
    uveNotOnSubscriberNetwork       = 3006, /**< This application will only work on your home Uverse network, you are not currently on that network. */
    uveNoSetTopBoxesAvailableForDeviceRegistration = 3007, /**< A device registration is required, but there are not any set top boxes configured for Uverse Enabled. */
    uveDeviceNotAllowedToRun        = 3008, /**<  This DAIS device is not allowed to be used in this household. */
    uveAuthTokenUnexpected          = 3009, // An Authentication Token was was not expected to be received.
    uveUnableToParseResourceFile    = 3010, /**< The library failed to parse the resource file. */
    uveInvalidSetTopBoxId           = 3011, /**< Set Top Box indentifier is invalid. */
    uveSetTopBoxVersionUnrecognized = 3012, /**< The Set Top Box version was unrecognized by the library. */

    uveAllSetTopBoxInUse            = 4000, /**< All SetTopBoxes are currently in use. */
    uveSetTopBoxNotRegistered       = 4001, /**< An unknown SetTopBox is on your network. */
    uveSetTopBoxNotAllowed          = 4002, /**< A blocked SetTopBox is on your network. */
    uveNonceRequired                = 4003, /**< A Nonce is required to associate to this SetTopBox. */
    uveNonceExpired                 = 4004, /**< The supplied Nonce has expired. */
    uveNonceInvalid                 = 4005, /**< The supplied Nonce is invalid. */
    uveNotOnAUverseNetwork          = 4006, /**< The device is not currently connected to a Uverse Wi-Fi network. */
    uveURLNotAllowed                = 4007, /**< The requested URL is blocked for this application. */
    uveOperationNotAllowed          = 4008, /**< The requested command is blocked for this application. */
    uveLibraryNotReady              = 4009, /**< The Library is not initialized. */
    uveLibrarySessionExpired        = 4010, /**< The Library session has expired or is invalid, please restart discovery. */
    uveCommandDoesNotWorkWithLiveTV = 4011, /**< The GetSeekTime command does not work with Live TV. */
    uveDiscoveryInProgress          = 4012, /**< Operation failed because the network is currently being discovered. */
    uveNonceAttemptedTooManyTimes   = 4013, /**< The supplied Nonce has been attempted too many times. */

    uveAppServerFailedToStart             = 5000, /**< Failed to start the application server. */
    uveAppServerCertificateRequestFailure = 5001, /**< The Application Server failed to obtain a Certificate. */
    uveAppServerCertificateUnavailable    = 5002, /**< The Certificate for this IP Address is not available at this time. This is a transient error, usually resolved by trying again. */
    uveAppServerNotAllowed                = 5003, /**< The Application Server functionality is not allowed on this particular SetTopBox. */

    uveSetTopBoxUnreachable         = 6000, /**< Could not communicate with Set Top Box. */
    uveSetTopBoxProtocolError       = 6001, /**< Set Top Box reported error during communication. */
    uveSetTopBoxInvalidResponse     = 6002, /**< Set Top Box responded with an unexpected message. */
    uveSetTopBoxNotEngaged          = 6003 /**< Sending a command to a Set Top Box that is not engaged is not allowed. */
} uveErrorCodes;