from typing import Optional

from pydantic import BaseModel, Field


class LinkTokenCreateRequestDTO(BaseModel):
    client_user_id: Optional[str] = Field(
        default=None,
        description="Stable user id (e.g. Firebase uid). Random if omitted.",
    )


class LinkTokenCreateResponseDTO(BaseModel):
    link_token: str


class ExchangePublicTokenRequestDTO(BaseModel):
    public_token: str
    client_user_id: Optional[str] = Field(
        default=None,
        description="Firestore's user_id",
    )


class ExchangePublicTokenResponseDTO(BaseModel):
    access_token: str
    item_id: str


class SyncTransactionsRequestDTO(BaseModel):
    client_user_id: str = Field(description="Firestore's user_id")


class SyncedTransactionDTO(BaseModel):
    transaction_id: str
    name: str
    amount: float
    date: str
    merchant_name: Optional[str] = None
    pending: bool = False


class SyncTransactionsResponseDTO(BaseModel):
    transactions: list[SyncedTransactionDTO]
    imported_count: int
