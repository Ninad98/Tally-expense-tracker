from __future__ import annotations

import uuid
from datetime import date

from app.dao.plaid_dao import PlaidDAO
from app.dto.plaid import (
    ExchangePublicTokenRequestDTO,
    ExchangePublicTokenResponseDTO,
    LinkTokenCreateRequestDTO,
    LinkTokenCreateResponseDTO,
    SyncTransactionsRequestDTO,
    SyncTransactionsResponseDTO,
    SyncedTransactionDTO,
)
from app.services.plaid_token_store import PlaidTokenStore


class PlaidService:
    def __init__(self, plaid_dao: PlaidDAO, token_store: PlaidTokenStore) -> None:
        self._plaid = plaid_dao
        self._tokens = token_store

    def create_link_token(self, body: LinkTokenCreateRequestDTO) -> LinkTokenCreateResponseDTO:
        user_id = body.client_user_id or f"tally-{uuid.uuid4().hex[:24]}"
        token = self._plaid.create_link_token(client_user_id=user_id)
        return LinkTokenCreateResponseDTO(link_token=token)

    def exchange_public_token(self, body: ExchangePublicTokenRequestDTO) -> ExchangePublicTokenResponseDTO:
        access_token, item_id = self._plaid.exchange_public_token(public_token=body.public_token)
        if body.client_user_id:
            self._tokens.save_for_user(
                user_id=body.client_user_id,
                access_token=access_token,
                item_id=item_id,
            )
        return ExchangePublicTokenResponseDTO(access_token=access_token, item_id=item_id)

    def sync_transactions(self, body: SyncTransactionsRequestDTO) -> SyncTransactionsResponseDTO:
        record = self._tokens.get_for_user(user_id=body.client_user_id)
        if record is None:
            raise ValueError("No Plaid access token found for this user. Please link a bank first.")

        cursor = record.cursor
        added = []
        while True:
            response = self._plaid.sync_transactions(access_token=record.access_token, cursor=cursor)
            added.extend(response.added)
            cursor = response.next_cursor
            if not response.has_more:
                break

        self._tokens.update_cursor(user_id=body.client_user_id, cursor=cursor)

        transactions = [
            SyncedTransactionDTO(
                transaction_id=t.transaction_id,
                name=t.name,
                amount=float(t.amount),
                date=self._to_iso_date(t.date),
                merchant_name=t.merchant_name,
                pending=bool(t.pending),
            )
            for t in added
        ]
        return SyncTransactionsResponseDTO(
            transactions=transactions,
            imported_count=len(transactions),
        )

    @staticmethod
    def _to_iso_date(value) -> str:
        if isinstance(value, date):
            return value.isoformat()
        return str(value)
