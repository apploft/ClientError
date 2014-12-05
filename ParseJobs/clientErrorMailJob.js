Parse.Cloud.job("sendClientErrorMail", function(request, status) {
  // override class permissions and ACLs
  Parse.Cloud.useMasterKey();
    // the mail provider as string, e.g. "mandrill" or "mailgun"
  var providerName = request.params.providerName,
    // the parameters for sending a mail as object, see documentation from the mail provider
    parameters = request.params.parameters,
     // the credential arguments for calling initialize on the mail provider as array
    credentials = request.params.credentials
    // find errors that occured during the last x hours, default is one day
    elapsedHours = request.params.elapsedHours || 24,
    // maximum and default is 1000 errors per mail
    limit = request.params.limit || 1000,
    // do not send a mail report if count of new errors is zero, default is true
    omitMailIfNoError = request.params.omitMailIfNoError != undefined ? 
      request.params.omitMailIfNoError : true,
    // anonymize installation ID for security reasons to the first 4 digits as default
    // 0 would be completely hidden, 10 would be full length
    installationDigits = request.params.installationDigits != undefined ? 
      request.params.installationDigits : 4,
    startDate = new Date(+new Date() - elapsedHours * 3600000),
    errorQuery = new Parse.Query("ClientError"),
    message = parameters;
  
  if (providerName == "mandrill") {
    message = parameters.message;
  }
    
  if (!providerName || !parameters || !credentials || !credentials.length || !message) {
    status.error("job parameters 'providerName', 'parameters' and 'credentials' are required");
    return;
  }
  
  var provider = require(providerName);
  provider.initialize.apply(provider, credentials);
    
  errorQuery.greaterThanOrEqualTo("createdAt", startDate);
  errorQuery.limit(limit);
  errorQuery.include("installation");
  errorQuery.descending("createdAt");
  
  message.text = "Domain, Code, Time, Installation, UserInfo\n\n";
  
  errorQuery.find(function(results) {
    if (omitMailIfNoError && (!results || (results.length == 0))) {
      return status.success("no new errors, omitting mail report");
    }
    
    message.text += (results || []).map(function(result) {
      var installationID = (result.get("installation") || {"id": "----------"}).id
        .substr(0, installationDigits) + "**********".substr(0, 10 - installationDigits),
        userInfo = JSON.stringify(result.get("userInfo"));
      
      return [result.get("domain"), result.get("code"), result.createdAt, installationID, 
        userInfo].join(", ");
    }).join("\n");
    
    if (results.length == limit) {
      message.text += "\n\n" + 
        "Limit of " + limit + " errors per mail reached.\n" + 
        "Check your database, there are probably more errors.\n";
    }
    
    provider.sendEmail(parameters, {
      "success": function(httpResponse) {
        status.success(JSON.stringify(httpResponse.data || httpResponse));
      },
      "error": function(httpResponse) {
        status.error(JSON.stringify(httpResponse.data || httpResponse));
      }
    });
  }).fail(function(error) {
    status.error(JSON.stringify(error));
  });
});
