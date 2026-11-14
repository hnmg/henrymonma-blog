#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Uso: ./renomear-post.sh <slug-atual> \"Novo título\""
  echo "Exemplo: ./renomear-post.sh como-funciona-o-spring-boot \"Como o Spring Boot funciona por dentro\""
  exit 1
fi

SLUG_ATUAL="${1%.md}"
NOVO_TITULO="$2"

ORIGEM="content/posts/${SLUG_ATUAL}.md"

if [ ! -f "$ORIGEM" ]; then
  echo "Erro: $ORIGEM não existe."
  exit 1
fi

# Gera o novo slug: minúsculas, sem acentos, hífens no lugar de espaços
NOVO_SLUG=$(echo "$NOVO_TITULO" \
  | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')

DESTINO="content/posts/${NOVO_SLUG}.md"

if [ "$ORIGEM" != "$DESTINO" ] && [ -e "$DESTINO" ]; then
  echo "Erro: $DESTINO já existe."
  exit 1
fi

# Escapa aspas e barras para uso seguro no sed
TITULO_ESCAPADO=$(printf '%s' "$NOVO_TITULO" | sed -e 's/[\/&|]/\\&/g' -e 's/"/\\"/g')

# Atualiza a primeira linha "title:" do front matter
sed -E -i.bak "0,/^title:.*/s||title: \"${TITULO_ESCAPADO}\"|" "$ORIGEM"
rm -f "${ORIGEM}.bak"

# Renomeia usando git mv quando o arquivo está versionado (preserva o histórico)
if [ "$ORIGEM" != "$DESTINO" ]; then
  if git ls-files --error-unmatch "$ORIGEM" >/dev/null 2>&1; then
    git mv "$ORIGEM" "$DESTINO"
  else
    mv "$ORIGEM" "$DESTINO"
  fi
fi

echo "Título atualizado e arquivo renomeado:"
echo "  de: $ORIGEM"
echo "  para: $DESTINO"
echo
echo "Atenção: a URL do post mudou para /posts/${NOVO_SLUG}/"