from __future__ import annotations

from plaid.api import plaid_api
from plaid.api_client import ApiClient
from plaid.configuration import Configuration
from plaid.model.country_code import CountryCode
from plaid.model.item_public_token_exchange_request import ItemPublicTokenExchangeRequest
from plaid.model.link_token_create_request import LinkTokenCreateRequest
from plaid.model.link_token_create_request_user import LinkTokenCreateRequestUser
from plaid.model.products import Products
from plaid.model.transactions_sync_request import TransactionsSyncRequest

from app.config import Settings


class PlaidDAO:

    def __init__(self, settings: Settings) -> None:
        self._settings = settings
        configuration = Configuration(
            host=settings.plaid_api_host,
            api_key={
                "clientId": settings.plaid_client_id,
                "secret": settings.plaid_secret,
            },
        )
        self._client = plaid_api.PlaidApi(ApiClient(configuration))

    def create_link_token(self, *, client_user_id: str) -> str:
        request = LinkTokenCreateRequest(
            products=[Products("transactions")],
            client_name="Tally",
            language="en",
            country_codes=[CountryCode("US")],
            user=LinkTokenCreateRequestUser(client_user_id=client_user_id),
        )
        response = self._client.link_token_create(request)
        return response.link_token

    def exchange_public_token(self, *, public_token: str) -> tuple[str, str]:
        request = ItemPublicTokenExchangeRequest(public_token=public_token)
        response = self._client.item_public_token_exchange(request)
        return response.access_token, response.item_id

    def sync_transactions(self, *, access_token: str, cursor: str | None):
        payload = {"access_token": access_token}
        if cursor is not None:
            payload["cursor"] = cursor
        request = TransactionsSyncRequest(**payload)
        return self._client.transactions_sync(request)
