function removeWorkers() {
  navigator.serviceWorker.getRegistrations()
    .then(function(registrations) {
      for(let registration of registrations) {
        registration.unregister();
        console.log("Removing: " + registration.active.scriptURL);
      }
    });
}

function unsubscribe() {
  console.log('Unsubscribing');
  navigator.serviceWorker.ready.then(function(serviceWorker) {
    serviceWorker.pushManager.getSubscription().then(function(subscription) {
      if (subscription) {
        subscription.unsubscribe().then(function(successful) {
          console.log('Successfully unsubscribed');
        }).catch(function(e) {
          console.log('Unsubscription failed');
        })
      }
    });
  });
}
