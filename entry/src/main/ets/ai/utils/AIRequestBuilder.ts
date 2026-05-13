import { AIRequest, AIRequestInput, InputType } from '../models/AITypes';

export class AIRequestBuilder {
  static createSimpleRequest(
    content: string,
    userId: string = 'default-user',
    inputType: InputType = 'text'
  ): AIRequest {
    const input: AIRequestInput = {
      type: inputType,
      content: content
    };

    return {
      requestId: `req-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      userId: userId,
      input: input
    };
  }

  static createDataRequest(
    data: string | object,
    intent: string,
    userId: string = 'default-user'
  ): AIRequest {
    const content = typeof data === 'string' ? data : JSON.stringify(data);

    const input: AIRequestInput = {
      type: 'text',
      content: content,
      metadata: {
        context: intent
      }
    };

    return {
      requestId: `req-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      userId: userId,
      input: input
    };
  }

  static createWithIntent(
    content: string,
    intent: string,
    userId: string = 'default-user'
  ): AIRequest {
    const input: AIRequestInput = {
      type: 'text',
      content: content,
      metadata: {
        context: intent
      }
    };

    return {
      requestId: `req-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      userId: userId,
      input: input
    };
  }

  static createWithMetadata(
    content: string,
    metadata: object,
    userId: string = 'default-user'
  ): AIRequest {
    const input: AIRequestInput = {
      type: 'text',
      content: content,
      metadata: metadata
    };

    return {
      requestId: `req-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      userId: userId,
      input: input
    };
  }
}
