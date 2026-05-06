# RAG 管道

嵌入文档用于语义搜索，并使用本地 LLM 回答问题。

**服务：** Ollama (LLM) + LiteLLM (网关) + Embeddings

**内存：** ~3 GB RAM（使用 3B 模型）

## 快速开始

```bash
git clone https://github.com/hwdsl2/docker-ai-stack
cd docker-ai-stack/stacks/rag-pipeline
docker compose up -d
```

**拉取模型**（发出 LLM 请求前必须执行）：

```bash
docker exec ollama ollama_manage --pull llama3.2:3b
```

## 示例

```bash
LITELLM_KEY=$(docker exec litellm litellm_manage --getkey)

# 嵌入文档片段
curl -s http://localhost:8000/v1/embeddings \
    -H "Content-Type: application/json" \
    -d '{"input": "Docker simplifies deployment by packaging apps in containers.", "model": "text-embedding-ada-002"}' \
    | jq '.data[0].embedding'
# → 将向量存储到向量数据库（Qdrant、Chroma、pgvector 等）

# 查询：嵌入问题，从向量数据库检索上下文，然后向 LLM 提问
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