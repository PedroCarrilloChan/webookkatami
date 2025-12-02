#!/bin/bash

# Script para probar el webhook localmente o en producción

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# URL del webhook (cambiar si es necesario)
WEBHOOK_URL="${1:-http://localhost:8787}"

echo -e "${GREEN}🧪 Probando webhook en: $WEBHOOK_URL${NC}\n"

# Secret key para generar la firma
SECRET_KEY="ezZTysNfNDUZgIgl"

# Test 1: Verificación del webhook
echo -e "${YELLOW}📋 Test 1: Verificación del webhook${NC}"
BODY='{"type":"webhook.verify","data":{"token":"test-token-123"}}'
SIGNATURE=$(echo -n "$BODY" | openssl dgst -sha1 -hmac "$SECRET_KEY" | sed 's/^.* //')
SIGNATURE_HEADER="sha1=$SIGNATURE"

RESPONSE=$(curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -H "x-passslot-signature: $SIGNATURE_HEADER" \
  -d "$BODY" \
  -w "\n%{http_code}")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Test 1 exitoso (HTTP $HTTP_CODE)${NC}"
    echo "Response: $RESPONSE_BODY"
else
    echo -e "${RED}❌ Test 1 falló (HTTP $HTTP_CODE)${NC}"
    echo "Response: $RESPONSE_BODY"
fi

echo ""

# Test 2: Evento con passSerialNumber
echo -e "${YELLOW}📋 Test 2: Evento con passSerialNumber${NC}"
BODY2='{"type":"event.test","data":{"passSerialNumber":"TEST-123"}}'
SIGNATURE2=$(echo -n "$BODY2" | openssl dgst -sha1 -hmac "$SECRET_KEY" | sed 's/^.* //')
SIGNATURE_HEADER2="sha1=$SIGNATURE2"

RESPONSE2=$(curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -H "x-passslot-signature: $SIGNATURE_HEADER2" \
  -d "$BODY2" \
  -w "\n%{http_code}")

HTTP_CODE2=$(echo "$RESPONSE2" | tail -n1)
RESPONSE_BODY2=$(echo "$RESPONSE2" | sed '$d')

if [ "$HTTP_CODE2" = "200" ] || [ "$HTTP_CODE2" = "404" ]; then
    echo -e "${GREEN}✅ Test 2 completado (HTTP $HTTP_CODE2)${NC}"
    echo "Response: $RESPONSE_BODY2"
else
    echo -e "${RED}❌ Test 2 falló (HTTP $HTTP_CODE2)${NC}"
    echo "Response: $RESPONSE_BODY2"
fi

echo ""

# Test 3: Firma inválida (debe fallar)
echo -e "${YELLOW}📋 Test 3: Firma inválida (debe fallar)${NC}"
RESPONSE3=$(curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -H "x-passslot-signature: sha1=invalidsignature" \
  -d "$BODY" \
  -w "\n%{http_code}")

HTTP_CODE3=$(echo "$RESPONSE3" | tail -n1)
RESPONSE_BODY3=$(echo "$RESPONSE3" | sed '$d')

if [ "$HTTP_CODE3" = "403" ]; then
    echo -e "${GREEN}✅ Test 3 exitoso - Firma rechazada correctamente (HTTP $HTTP_CODE3)${NC}"
else
    echo -e "${RED}❌ Test 3 falló - Debería rechazar firma inválida (HTTP $HTTP_CODE3)${NC}"
fi

echo ""
echo -e "${GREEN}🏁 Tests completados${NC}"
