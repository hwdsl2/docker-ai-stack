# AI 工具

本地 LLM 搭配 MCP 工具访问，适用于 AI 编程助手（Cline、Claude、Cursor 等）。

**服务：** Ollama (LLM) + LiteLLM (网关) + MCP Gateway

**内存：** ~3 GB RAM（使用 3B 模型）

## 快速开始

```bash
git clone https://github.com/hwdsl2/docker-ai-stack
cd docker-ai-stack/stacks/ai-tools
docker compose up -d
```

**拉取模型**（发出 LLM 请求前必须执行）：

```bash
docker exec ollama ollama_manage --pull llama3.2:3b
```

## 使用方法

```bash
# 获取 API 密钥
LITELLM_KEY=$(docker exec litellm litellm_manage --getkey)
MCP_KEY=$(docker exec mcp mcp_manage --getkey)

# 将 MCP Gateway 连接到 LiteLLM，在 LiteLLM 配置中添加：
# mcp_servers:
#   - url: http://mcp:3000/mcp
#     transport: sse
#     headers:
#       Authorization: "Bearer <mcp_api_key>"

# 在 AI 客户端中使用（例如 VS Code 中的 Cline）：
# LLM 端点：http://localhost:4000（使用 LITELLM_KEY）
# MCP 端点：http://localhost:3000/mcp（使用 MCP_KEY）