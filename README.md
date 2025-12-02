# Webhook Cloudflare Worker para ChatbotBuilder

Este proyecto implementa un webhook usando Cloudflare Workers que recibe eventos y envía mensajes a través de la API de ChatbotBuilder.

## Características

- ✅ Verificación de firma HMAC SHA1 para seguridad
- ✅ Manejo de eventos de verificación de webhook
- ✅ Búsqueda de usuarios por custom field en ChatbotBuilder
- ✅ Envío automático de mensajes a usuarios encontrados
- ✅ Logs detallados para debugging
- ✅ Manejo de errores robusto

## Estructura del Proyecto

```
.
├── src/
│   └── index.js          # Código principal del Worker
├── wrangler.toml         # Configuración de Cloudflare
├── package.json          # Dependencias del proyecto
└── README.md            # Este archivo
```

## Configuración

### 1. Instalación de dependencias

```bash
npm install
```

### 2. Autenticación con Cloudflare

Configura tu API token de Cloudflare:

```bash
export CLOUDFLARE_API_TOKEN=668df0f71f0e8c41deb0e3275e409c3e70c0b
```

O usa wrangler login:

```bash
npx wrangler login
```

### 3. Configuración de secretos (Opcional)

Si prefieres usar variables de entorno en lugar de valores hardcodeados, configura los secretos:

```bash
npx wrangler secret put SECRET_KEY
# Ingresa: ezZTysNfNDUZgIgl

npx wrangler secret put CHATBOT_ACCESS_TOKEN
# Ingresa: 1001822.QkjoMFJNpiJ6rOBbVRTcrEP1oj5VejJyY5VIDUmO8HdlT
```

## Despliegue

### Desplegar a producción

```bash
npm run deploy
```

O directamente con wrangler:

```bash
npx wrangler deploy
```

### Desarrollo local

Para probar localmente:

```bash
npm run dev
```

Esto iniciará un servidor local en `http://localhost:8787`

## Uso

Una vez desplegado, el Worker estará disponible en una URL como:

```
https://webhook-chatbot.<tu-subdomain>.workers.dev
```

### Endpoint

**POST /** - Recibe eventos del webhook

#### Headers requeridos:
- `x-passslot-signature`: Firma HMAC SHA1 del body

#### Body esperado:

```json
{
  "type": "webhook.verify",
  "data": {
    "token": "verification_token"
  }
}
```

O para eventos normales:

```json
{
  "type": "event.type",
  "data": {
    "passSerialNumber": "ABC123"
  }
}
```

## Flujo de Funcionamiento

1. **Recepción del webhook**: El Worker recibe una petición POST
2. **Verificación de firma**: Valida la firma HMAC SHA1 usando el SECRET_KEY
3. **Verificación de webhook**: Si es un evento `webhook.verify`, responde con el token
4. **Búsqueda de usuario**: Busca el usuario en ChatbotBuilder usando el `passSerialNumber`
5. **Envío de mensaje**: Si encuentra el usuario, envía el mensaje configurado
6. **Respuesta**: Devuelve el resultado de la operación

## Configuración Personalizada

Puedes modificar los siguientes valores en `src/index.js`:

- `SECRET_KEY`: Clave secreta para verificar la firma
- `CHATBOT_ACCESS_TOKEN`: Token de acceso a la API de ChatbotBuilder
- `FIELD_ID`: ID del custom field en ChatbotBuilder
- `MESSAGE_FLOW_ID`: ID del flujo de mensaje a enviar

## Logs y Debugging

Para ver los logs del Worker:

```bash
npx wrangler tail
```

Esto mostrará los logs en tiempo real.

## Troubleshooting

### Error: "Invalid signature"
- Verifica que el `SECRET_KEY` sea correcto
- Asegúrate de que el webhook esté enviando el header `x-passslot-signature`

### Error: "Usuario no encontrado"
- Verifica que el `FIELD_ID` sea correcto
- Confirma que el usuario tenga el custom field configurado con el valor del `passSerialNumber`

### Error: "Error enviando mensaje"
- Verifica que el `CHATBOT_ACCESS_TOKEN` sea válido
- Confirma que el `MESSAGE_FLOW_ID` exista en tu cuenta de ChatbotBuilder

## API de ChatbotBuilder

Este Worker utiliza los siguientes endpoints:

- **GET** `https://app.chatgptbuilder.io/api/users/find_by_custom_field`
  - Busca usuarios por custom field

- **POST** `https://app.chatgptbuilder.io/api/users/{userId}/send/{flowId}`
  - Envía un mensaje a un usuario específico

## Seguridad

- ✅ Verificación de firma HMAC para prevenir webhooks falsificados
- ✅ Validación de datos de entrada
- ✅ Manejo seguro de errores sin exponer información sensible
- ⚠️ **Importante**: No compartas tu `SECRET_KEY` ni `CHATBOT_ACCESS_TOKEN` públicamente

## Licencia

MIT
