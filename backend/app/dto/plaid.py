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


class ExchangePublicTokenResponseDTO(BaseModel):
    access_token: str
    item_id: str
