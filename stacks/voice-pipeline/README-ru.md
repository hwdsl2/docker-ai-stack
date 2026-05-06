# Голосовой конвейер

Речь в текст → LLM → текст в речь. Транскрибируйте аудио, получите ответ AI и прослушайте его.

**Сервисы:** Whisper (STT) + Ollama (LLM) + LiteLLM (шлюз) + Kokoro (TTS)

**Память:** ~5 ГБ RAM (с моделью 3B)

## Быстрый старт

```bash
git clone https://github.com/hwdsl2/docker-ai-stack
cd docker-ai-stack/stacks/voice-pipeline
docker compose up -d
```

**Загрузка модели** (обязательно перед отправкой LLM-запросов):

```bash
docker exec ollama ollama_manage --pull llama3.2:3b
```

## Пример

```bash
LITELLM_KEY=$(docker exec litellm litellm_manage --getkey)

# Транскрибация аудио в текст
TEXT=$(curl -s http://localhost:9000/v1/audio/transcriptions \
    -F file=@question.mp3 -F model=whisper-1 | jq -r .text)

# Получение ответа LLM
RESPONSE=$(curl -s http://localhost:4000/v1/chat/completions \
    -H "Authorization: Bearer $LITELLM_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"ollama/llama3.2:3b\",\"messages\":[{\"role\":\"user\",\"content\":\"$TEXT\"}]}" \
    | jq -r '.choices[0].message.content')

# Преобразование ответа в речь
curl -s http://localhost:8880/v1/audio/speech \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"tts-1\",\"input\":\"$RESPONSE\",\"voice\":\"af_heart\"}" \
    --output response.mp3