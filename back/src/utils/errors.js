/**
 * Classes de erro customizadas para a aplicação
 */

export class HttpError extends Error {
  constructor(message, status = 500) {
    super(message);
    this.name = 'HttpError';
    this.status = status;
  }
}

export class ValidationError extends HttpError {
  constructor(message) {
    super(message, 400);
    this.name = 'ValidationError';
  }
}

export class NotFoundError extends HttpError {
  constructor(message = 'Recurso não encontrado') {
    super(message, 404);
    this.name = 'NotFoundError';
  }
}

export class ExternalServiceError extends HttpError {
  constructor(message = 'Falha ao consultar serviço externo') {
    super(message, 502);
    this.name = 'ExternalServiceError';
  }
}

export class RateLimitError extends HttpError {
  constructor(message = 'Limite de requisições excedido') {
    super(message, 429);
    this.name = 'RateLimitError';
  }
}
