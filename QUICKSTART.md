# 🚀 Guía Rápida de Despliegue

Esta guía te ayudará a desplegar el webhook en Cloudflare Workers en minutos.

## ⚡ Despliegue Rápido

### Opción 1: Usando el script de despliegue (Recomendado)

```bash
# 1. Instalar dependencias
npm install

# 2. Configurar el API token de Cloudflare
export CLOUDFLARE_API_TOKEN=668df0f71f0e8c41deb0e3275e409c3e70c0b

# 3. Desplegar
./deploy.sh
```

### Opción 2: Despliegue manual

```bash
# 1. Instalar dependencias
npm install

# 2. Configurar el API token
export CLOUDFLARE_API_TOKEN=668df0f71f0e8c41deb0e3275e409c3e70c0b

# 3. Desplegar con wrangler
npx wrangler deploy
```

## 🧪 Pruebas

### Probar localmente

```bash
# Terminal 1: Iniciar el worker localmente
npm run dev

# Terminal 2: Ejecutar tests
./test-webhook.sh http://localhost:8787
```

### Probar en producción

```bash
# Reemplaza con tu URL del worker
./test-webhook.sh https://webhook-chatbot.tu-subdomain.workers.dev
```

## 📊 Ver logs en tiempo real

```bash
npx wrangler tail
```

Esto mostrará todos los logs del Worker en tiempo real, útil para debugging.

## 🔧 Configuración

### Valores actuales (hardcodeados en `src/index.js`):

- **SECRET_KEY**: `ezZTysNfNDUZgIgl`
- **CHATBOT_ACCESS_TOKEN**: `1001822.QkjoMFJNpiJ6rOBbVRTcrEP1oj5VejJyY5VIDUmO8HdlT`
- **FIELD_ID**: `480449`
- **MESSAGE_FLOW_ID**: `1709878531050`

### Cambiar a variables de entorno (Opcional):

Si prefieres usar secretos de Cloudflare en lugar de valores hardcodeados:

```bash
# Configurar secretos
npx wrangler secret put SECRET_KEY
# Ingresa: ezZTysNfNDUZgIgl

npx wrangler secret put CHATBOT_ACCESS_TOKEN
# Ingresa: 1001822.QkjoMFJNpiJ6rOBbVRTcrEP1oj5VejJyY5VIDUmO8HdlT

# Desplegar nuevamente
npx wrangler deploy
```

## 📋 URL del Worker

Después del despliegue, tu Worker estará disponible en una URL como:

```
https://webhook-chatbot.<tu-account>.workers.dev
```

Copia esta URL y configúrala en tu servicio de webhooks.

## ✅ Verificar que funciona

1. **Desplegar el Worker**:
   ```bash
   ./deploy.sh
   ```

2. **Obtener la URL**: Wrangler mostrará la URL después del despliegue

3. **Configurar el webhook**: Usa la URL en tu servicio

4. **Ver logs**:
   ```bash
   npx wrangler tail
   ```

5. **Enviar un evento de prueba** y verificar que aparece en los logs

## 🆘 Problemas Comunes

### "Authentication error"
```bash
# Verificar que el token esté configurado
echo $CLOUDFLARE_API_TOKEN

# Si no está configurado, configurarlo:
export CLOUDFLARE_API_TOKEN=668df0f71f0e8c41deb0e3275e409c3e70c0b
```

### "Invalid signature" en logs
- Verifica que el `SECRET_KEY` en el código coincida con el configurado en el servicio de webhooks

### "Usuario no encontrado" en logs
- Verifica que el `FIELD_ID` sea correcto (`480449`)
- Confirma que el usuario tenga el custom field con el valor correcto

### "Error enviando mensaje" en logs
- Verifica que el `CHATBOT_ACCESS_TOKEN` sea válido
- Confirma que el `MESSAGE_FLOW_ID` (`1709878531050`) exista

## 📚 Documentación Completa

Para más detalles, consulta el [README.md](README.md) completo.

## 🎯 Resumen de Comandos

```bash
# Instalación
npm install

# Desarrollo local
npm run dev

# Desplegar
./deploy.sh

# Ver logs
npx wrangler tail

# Probar
./test-webhook.sh http://localhost:8787
```

## 🔗 Enlaces Útiles

- [Cloudflare Workers Docs](https://developers.cloudflare.com/workers/)
- [Wrangler CLI Docs](https://developers.cloudflare.com/workers/wrangler/)
- [ChatbotBuilder API Docs](https://app.chatgptbuilder.io/api/docs)

---

¿Problemas? Revisa los logs con `npx wrangler tail` o consulta el README.md completo.
