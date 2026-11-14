#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Uso: ./novo-post.sh \"Título do post\" [tag1,tag2,...]"
  exit 1
fi

TITULO="$1"
TAGS_INPUT="${2:-}"
DATA=$(date +%Y-%m-%d)

# Gera o slug: minúsculas, sem acentos, hífens no lugar de espaços
SLUG=$(echo "$TITULO" \
  | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')

ARQUIVO="content/posts/${SLUG}.md"

if [ -e "$ARQUIVO" ]; then
  echo "Erro: $ARQUIVO já existe."
  exit 1
fi

mkdir -p content/posts

# Converte "java,spring-boot" em ["java", "spring-boot"]
if [ -n "$TAGS_INPUT" ]; then
  TAGS=$(echo "$TAGS_INPUT" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/ *, */", "/g; s/^/["/; s/$/"]/')
else
  TAGS="[]"
fi

cat > "$ARQUIVO" <<EOF
---
title: "${TITULO}"
date: ${DATA}
draft: true
tags: ${TAGS}
summary: ""
---

Escreva aqui.

## Referências

EOF

echo "Post criado: $ARQUIVO"