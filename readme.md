# Marketplace Managed App Notification Proxy

This static web app acts as a simple proxy for Logic Apps to receive Azure managed application notifications.

It's necessary because the notification URL format is fixed so some sort of routing capability is required. Other options include:
  * Azure Function + proxies
  * Azure API Management

There is a single function at ```api/notification-webhook``` which checks the webook signature query parameter matches the expected value. If it does, it accepts the request. If the notification is for a new, successful deployment, it will also call a Logic App workflow to invoke a GitHub action to complete the post deployment steps (typically deploying an application).
