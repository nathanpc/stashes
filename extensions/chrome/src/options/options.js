// options.js
// Options.

document.addEventListener("DOMContentLoaded", function () {
	var server_url = document.getElementById("url");
	var browser_id = document.getElementById("id");
	var name = document.getElementById("name");

	chrome.storage.local.get(["server_url", "id", "name"], function (res) {
		if (typeof res.server_url !== "undefined") {
			server_url.value = res.server_url;
		}

		if (typeof res.id !== "undefined") {
			browser_id.value = res.id;
		}

		if (typeof res.name !== "undefined") {
			name.value = res.name;
		}
	});

	document.getElementById("save").addEventListener("click", function () {
		chrome.storage.local.set({
			"server_url": server_url.value,
			"id": browser_id.value,
			"name": name.value
		});
	});

	// TODO: Send a /update_browser.
	// TODO: Add a permission for the server: https://developer.chrome.com/extensions/permissions 
});

