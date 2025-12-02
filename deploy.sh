#!/bin/bash

# Script de despliegue para el Webhook de Cloudflare Worker

echo "🚀 Iniciando despliegue del Webhook Cloudflare Worker..."

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar si wrangler está instalado
if ! command -v wrangler &> /dev/null; then
    echo -e "${YELLOW}⚠️  Wrangler no está instalado. Instalando...${NC}"
    npm install
fi

# Configurar el API token si está en variable de entorno
if [ -n "$CLOUDFLARE_API_TOKEN" ]; then
    echo -e "${GREEN}✅ API Token de Cloudflare configurado${NC}"
else
    echo -e "${YELLOW}⚠️  CLOUDFLARE_API_TOKEN no está configurado${NC}"
    echo "Puedes configurarlo con:"
    echo "export CLOUDFLARE_API_TOKEN=668df0f71f0e8c41deb0e3275e409c3e70c0b"
fi

# Desplegar
echo -e "\n${GREEN}📦 Desplegando Worker...${NC}"
npx wrangler deploy

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✅ ¡Despliegue exitoso!${NC}"
    echo -e "\n${YELLOW}📋 Próximos pasos:${NC}"
    echo "1. Tu Worker está disponible en: https://webhook-chatbot.<tu-subdomain>.workers.dev"
    echo "2. Configura la URL del webhook en tu servicio"
    echo "3. Verifica los logs con: npx wrangler tail"
    echo ""
    echo -e "${YELLOW}💡 Tip: Para configurar secretos (opcional):${NC}"
    echo "   npx wrangler secret put SECRET_KEY"
    echo "   npx wrangler secret put CHATBOT_ACCESS_TOKEN"
else
    echo -e "\n${RED}❌ Error en el despliegue${NC}"
    echo "Verifica tu configuración y vuelve a intentar"
    exit 1
fi
