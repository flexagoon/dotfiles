from typing import Protocol

import structlog


class Order(Protocol):
    id: int
    status: str


class OrderRepository(Protocol):
    async def get(self, order_id: int) -> Order | None: ...

    async def set_status(self, order: Order, status: str) -> Order: ...


class OrderNotFoundError(Exception):
    pass


logger = structlog.stdlib.get_logger(__name__)


async def set_order_status(
    order_id: int,
    new_status: str,
    repository: OrderRepository,
) -> Order:
    log = logger.bind(order_id=order_id, requested_status=new_status)
    order = await repository.get(order_id)

    if order is None:
        log.warning("order.not_found")
        raise OrderNotFoundError(order_id)

    previous_status = order.status
    try:
        updated_order = await repository.set_status(order, new_status)
    except Exception:
        log.exception("order.status_change_failed", previous_status=previous_status)
        raise

    log.info(
        "order.status_changed",
        previous_status=previous_status,
        new_status=updated_order.status,
    )
    return updated_order
