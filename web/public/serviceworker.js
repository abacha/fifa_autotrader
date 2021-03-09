if (typeof window !== "undefined") {
  var btn = document.getElementById("btn-register");
  btn.addEventListener('click', function() {
  console.log('Registering');
    var publicKey = btn.getAttribute("data-public-key");
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.getRegistration().then( function(r) {
        navigator.serviceWorker.register("/serviceworker.js", { scope: "/" })
          .then( subscribe(publicKey) )
          .catch( function(error) {
            console.log(error);
          }
        );
      });
    } else {
      console.log('Service workers are not supported.');
    }
  });
} else {
  self.addEventListener("push", function(event) {
    var json = event.data.json();
    self.registration.showNotification(json.title, {
      body: json.description,
      icon: location.origin + "/images/FA_logo.png",
    });
  });

  self.addEventListener("notificationclick", function(event) {
    event.notification.close();
    clients.openWindow("/");
  }, false);
}

function subscribe(serverPublicKey) {
  navigator.serviceWorker.ready.then(function(serviceWorker) {
    console.log("Subscribing");
    Notification.requestPermission(function(permission) {
      if (permission !== 'denied') {
        serviceWorker.pushManager.subscribe({
          userVisibleOnly: true,
          applicationServerKey: new Uint8Array(base64ToArrayBuffer(serverPublicKey))
        }).then(function(s) {
          var data = {
            endpoint: s.endpoint,
            p256dh: btoa(String.fromCharCode.apply(null, new Uint8Array(s.getKey('p256dh')))).replace(/\+/g, '-').replace(/\//g, '_'),
            auth: btoa(String.fromCharCode.apply(null, new Uint8Array(s.getKey('auth')))).replace(/\+/g, '-').replace(/\//g, '_')
          }
          console.log('Subscription success!');
          displayView(data);
        });
      }
    });
  });
}

function displayView(data) {
  $("#endpoint").text(data.endpoint);
  $("#p256dh").text(data.p256dh);
  $("#auth").text(data.auth);
}

function base64ToArrayBuffer(serverPublicKey) {
  var string =  window.atob(serverPublicKey.replace(/-/g, '+').replace(/_/g, '/'));
  var len = string.length;
  var bytes = new Uint8Array(len);
  for (var i = 0; i < len; i++) {
    bytes[i] = string.charCodeAt(i);
  }
  return bytes.buffer;
}
