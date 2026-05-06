# RAG Pipeline

Embed documents for semantic search and answer questions with a local LLM.

**Services:** Ollama (LLM) + LiteLLM (gateway) + Embeddings

**Memory:** ~3 GB RAM (with a 3B model)

## Quick start

```bash
git clone https://github.com/hwdsl2/docker-ai-stack
cd docker-ai-stack/stacks/rag-pipeline
docker compose up -d
```

**Pull a model** (required before making LLM requests):

```bash
docker exec ollama ollama_manage --pull llama3.2:3b
```

## Example

```bash
LITELLM_KEY=$(docker exec litellm litellm_manage --getkey)

# Embed a document chunk
curl -s http://localhost:8000/v1/embeddings \
    -H "Content-Type: application/json" \
    -d '{"input": "Docker simplifies deployment by packaging apps in containers.", "model": "text-embedding-ada-002"}' \
    | jq '.data[0].embedding'
# → Store the vector in your vector DB (Qdrant, Chroma, pgvector, etc.)

# Query: embed the question, retrieve context from vector DB, then ask the LLM
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