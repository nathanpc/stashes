// background.js
// Does everything.

var populate_tabs = function (callback) {
	// Loop through all the windows.
	chrome.windows.getAll({ populate: true }, function (windows) {
		var tabs = [];
		console.log(windows);

		for (var i = 0; i < windows.length; i++) {
			if (windows[i].type == "normal") {
				for (var j = 0; j < windows[i].tabs.length; j++) {
					if (windows[i].tabs[j].url.match(/^chrome/i) == null) {
						tabs.push(windows[i].tabs[j]);
					}
				}
			}
		}

		callback(tabs);
	});
};

var send_tabs = function() {
	chrome.storage.local.get(["server_url", "id", "name"], function (res) {
		if (typeof res.server_url !== "undefined" && typeof res.id !== "undefined" && typeof res.name !== "undefined") {
			populate_tabs(function (tabs) {
				var req = new XMLHttpRequest();
				req.onreadystatechange = function () {
					if (req.readyState == XMLHttpRequest.DONE) {
						if (req.status !== 200) {
							console.error("Couldn't send the tabs.");
						}
					}
				};

				var data = {
					"browser": {
						"id": res.id,
						"name": res.name,
						"type": "Chrome"
					},
					"tabs": tabs
				};

				req.open("POST", res.server_url + "/update_tabs", true);
				req.send(JSON.stringify(data));
			});
		} else {
			console.error("Settings are not set!");
		}
	});
};

// Window events.
chrome.windows.onRemoved.addListener(function (windowId) {
	console.log("Window: onRemoved");
	send_tabs();
});

// Tab events.
chrome.tabs.onCreated.addListener(function (tab) {
	console.log("Tab: onCreated");
	send_tabs();
});

/*chrome.tabs.onMoved.addListener(function (tabId, props) {
	console.log("Tab: onMoved");
	send_tabs();
});

chrome.tabs.onUpdated.addListener(function(tabId, props) {
	console.log("Tab: onUpdated");
	send_tabs();
});*/

chrome.tabs.onRemoved.addListener(function(tabId) {
	console.log("Tab: onRemoved");
	send_tabs();
});

// Init.
send_tabs();

