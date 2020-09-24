const AWS = require('aws-sdk');

const s3 = new AWS.S3();

const allAddressesHeader = 'application/payid+json'

const responseHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
  'Access-Control-Allow-Headers': 'PayID-Version',
  'Access-Control-Expose-Headers': 'PayID-Version, PayID-Server-Version',
  'Cache-Control': 'no-store',
};

const successResponse = {
  statusCode: 200,
  headers: responseHeaders,
};

const notFoundResponse = {
  statusCode: 404,
}

// From payid/src/services/headers.ts
// This will throw if the regex doesn't match.
function parseAcceptHeader(acceptHeader) {
  const ACCEPT_HEADER_REGEX = /^(?:application\/)(?<paymentNetwork>\w+)-?(?<environment>\w+)?(?:\+json)$/u
  // TODO (tedkalaw): Support content negotiation?
  // From payid/services/headers.ts
  const lowerCaseMediaType = acceptHeader.toLowerCase();
  const regexResult = ACCEPT_HEADER_REGEX.exec(lowerCaseMediaType);
  return {
    mediaType: lowerCaseMediaType,
    // Optionally returns the environment (only if it exists)
    ...(regexResult && regexResult.groups && regexResult.groups.environment && {
      environment: regexResult.groups.environment.toUpperCase(),
    }),
    paymentNetwork: regexResult && regexResult.groups && regexResult.groups.paymentNetwork.toUpperCase(),
  }
}

exports.handler =  async function(event, context) {
  if (event.path === '/') {
    return { ...successResponse, body: 'Welcome to PayID!' };
  }


  const payIdVersionHeader = event.headers['PayID-Version'];
  if (payIdVersionHeader && payIdVersionHeader !== '1.0') {
    return {
      statusCode: 422,
      body: 'Unknown PayID version set.',
    };
  }

  const payId = event.pathParameters.payId;
  const fullPayId = `${payId}$${process.env.PAYID_DOMAIN}`

  try {
    const params = {
      Bucket: `${process.env.PAYID_BUCKET}`,
      Key: `${payId}.json`,
    };
    const payIdResource = await s3.getObject(params).promise();
    const payIdJson = JSON.parse(payIdResource.Body.toString());

    const acceptHeader = event.headers.Accept;
    if (!acceptHeader || acceptHeader === allAddressesHeader) {
      return {
        ...successResponse,
        body: JSON.stringify({
          addresses: payIdJson.addresses,
          payId: fullPayId
        })
      }
    }

    const {paymentNetwork, environment} = parseAcceptHeader(acceptHeader);

    if (!paymentNetwork && !environment) {
      return {
        ...successResponse,
        body: JSON.stringify({
          addresses: payIdJson.addresses,
          payId: fullPayId
        })
      }
    }

    const selectedAddress = payIdJson.addresses
      .find(a => a.paymentNetwork === paymentNetwork
        && (!environment || a.environment === environment)
      );

    if (!selectedAddress) {
      return {
        ...notFoundResponse,
        body: JSON.stringify({
          ...notFoundResponse,
          error: 'Not found',
          message: `Payment information for ${payId}$${process.env.PAYID_DOMAIN} could not be found.`,
        })
      };
    }

    const addressFoundResponse = {...successResponse }
    addressFoundResponse.headers['Content-Type'] = acceptHeader;

    return {
      ...addressFoundResponse,
      body: JSON.stringify({
        addresses: [selectedAddress],
        payId: fullPayId
      })
    };
  } catch (error) {
    console.error('Uncaught exception handling PayID request', error);
    return {
      ...notFoundResponse,
      body: JSON.stringify({
        ...notFoundResponse,
        message: 'PayID resource not found',
      })
    };
  }
};
