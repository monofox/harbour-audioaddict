function checkAccountByKey(apiKey, callback) {
    var url = "https://api.audioaddict.com/v1/di/members/authenticate"
    var params = "api_key=" + apiKey
    sendHttpRequest("POST", url, callback, params);
}

function sendHttpRequest(requestType, url, callback, params) {
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState === 4) {
            if (doc.status === 200) {
                callback(doc.responseText);
            } else {
                callback("error", doc.responseText);
            }
        }
    }
    doc.open(requestType, url);
    if(requestType === "GET") {
        doc.setRequestHeader('User-Agent', 'Mozilla/5.0 (X11; Linux x86_64; rv:12.0) Gecko/20100101 Firefox/21.0');
        doc.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    } else {
        doc.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    }
    console.log("send url: ", requestType, url, params);
    doc.send(params);
}

function resetApiLogin(config) {
    config.setValue("apiKey", "")
    config.setValue("listenKey", "")
    config.setValue("firstName", "")
    config.setValue("lastName", "")
}

function updateApiLogin(config, data) {
    var userData = JSON.parse(data);
    var lastEl = userData.subscriptions.length - 1;
    config.setValue("expiresOn", userData.subscriptions[lastEl].expires_on);
    if (userData.listen_key) {
        config.setValue("listenKey", userData.listen_key);
    }
    config.setValue("apiKey", userData.api_key);
    config.setValue("status", userData.subscriptions[lastEl].status);
    config.setValue("firstName", userData.first_name);
    config.setValue("lastName", userData.last_name);
}
