# RAG-конвейер

Создание эмбеддингов документов для семантического поиска и ответы на вопросы с помощью локальной LLM.

**Сервисы:** Ollama (LLM) + LiteLLM (шлюз) + Embeddings

**Память:** ~3 ГБ RAM (с моделью 3B)

## Быстрый старт

```bash
git clone https://github.com/hwdsl2/docker-ai-stack
cd docker-ai-stack/stacks/rag-pipeline
docker compose up -d
```

**Загрузка модели** (обязательно перед отправкой LLM-запросов):

```bash
docker exec ollama ollama_manage --pull llama3.2:3b
```

## Пример

```bash
LITELLM_KEY=$(docker exec litellm litellm_manage --getkey)

# Создание эмбеддинга фрагмента документа
curl -s http://localhost:8000/v1/embeddings \
    -H "Content-Type: application/json" \
    -d '{"input": "Docker simplifies deployment by packaging apps in containers.", "model": "text-embedding-ada-002"}' \
    | jq '.data[0].embedding'
# → Сохраните вектор в векторной БД (Qdrant, Chroma, pgvector и т.д.)

# Запрос: создайте эмбеддинг вопроса, извлеките контекст из векторной БД, затем спросите LLM
curl -s http://localhost:4000/v1/chat/completions \
    -H "Authorization: Bearer $LITELLM_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "ollama/llama3.2:3b",
      "messages": [
        {"role": "system", "content": "Answer using only the provided context."},
        {"role": "user", "content": "What does Docker do?\n\nContext: Docker simplifies deployment by packaging apps in containers."}
      ]
    }' \
    | jq -r '.choices[0].message.content'