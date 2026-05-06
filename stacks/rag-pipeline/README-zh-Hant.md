# RAG 管道

嵌入文件用於語意搜尋，並使用本機 LLM 回答問題。

**服務：** Ollama (LLM) + LiteLLM (閘道) + Embeddings

**記憶體：** ~3 GB RAM（使用 3B 模型）

## 快速開始

```bash
git clone https://github.com/hwdsl2/docker-ai-stack
cd docker-ai-stack/stacks/rag-pipeline
docker compose up -d
```

**拉取模型**（發出 LLM 請求前必須執行）：

```bash
docker exec ollama ollama_manage --pull llama3.2:3b
```

## 範例

```bash
LITELLM_KEY=$(docker exec litellm litellm_manage --getkey)

# 嵌入文件片段
curl -s http://localhost:8000/v1/embeddings \
    -H "Content-Type: application/json" \
    -d '{"input": "Docker simplifies deployment by packaging apps in containers.", "model": "text-embedding-ada-002"}' \
    | jq '.data[0].embedding'
# → 將向量儲存到向量資料庫（Qdrant、Chroma、pgvector 等）

# 查詢：嵌入問題，從向量資料庫擷取上下文，然後向 LLM 提問
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