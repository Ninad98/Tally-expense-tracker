from __future__ import annotations

import uuid

from app.dao.plaid_dao import PlaidDAO
from app.dto.plaid import (
    ExchangePublicTokenRequestDTO,
    ExchangePublicTokenResponseDTO,
    LinkTokenCreateRequestDTO,
    LinkTokenCreateResponseDTO,
)


class PlaidService:
    def __init__(self, plaid_dao: PlaidDAO) -> None:
        self._plaid = plaid_dao

    def create_link_token(self, body: LinkTokenCreateRequestDTO) -> LinkTokenCreateResponseDTO:
        user_id = body.client_user_id or f"tally-{uuid.uuid4().hex[:24]}"
        token = self._plaid.create_link_token(client_user_id=user_id)
        return LinkTokenCreateResponseDTO(link_token=token)

    def exchange_public_token(self, body: ExchangePublicTokenRequestDTO) -> ExchangePublicTokenResponseDTO:
        access_token, item_id = self._plaid.exchange_public_token(public_token=body.public_token)
        return ExchangePublicTokenResponseDTO(access_token=access_token, item_id=item_id)
