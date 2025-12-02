/**
 * Cloudflare Worker para manejar webhooks y enviar mensajes a ChatbotBuilder
 */

// Configuración - Estos valores se pueden configurar como variables de entorno en Cloudflare
const SECRET_KEY = 'ezZTysNfNDUZgIgl';
const CHATBOT_ACCESS_TOKEN = '1001822.QkjoMFJNpiJ6rOBbVRTcrEP1oj5VejJyY5VIDUmO8HdlT';
const FIELD_ID = '480449';
const MESSAGE_FLOW_ID = '1709878531050';

/**
 * Verifica la firma HMAC SHA1 del webhook
 */
async function verifySignature(signature, body) {
  if (!signature) {
    return false;
  }

  // Importar la clave para HMAC
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(SECRET_KEY),
    { name: 'HMAC', hash: 'SHA-1' },
    false,
    ['sign']
  );

  // Calcular el HMAC
  const signatureBuffer = await crypto.subtle.sign(
    'HMAC',
    key,
    encoder.encode(body)
  );

  // Convertir a hex
  const hashArray = Array.from(new Uint8Array(signatureBuffer));
  const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
  const calculatedSignature = `sha1=${hashHex}`;

  // Comparación timing-safe
  return signature === calculatedSignature;
}

/**
 * Busca un usuario por custom field en ChatbotBuilder
 */
async function findUserByCustomField(passSerialNumber) {
  const url = `https://app.chatgptbuilder.io/api/users/find_by_custom_field?field_id=${FIELD_ID}&value=${passSerialNumber}`;

  const response = await fetch(url, {
    method: 'GET',
    headers: {
      'accept': 'application/json',
      'X-ACCESS-TOKEN': CHATBOT_ACCESS_TOKEN
    }
  });

  if (!response.ok) {
    throw new Error(`Error buscando usuario: ${response.status} ${response.statusText}`);
  }

  const data = await response.json();
  return data;
}

/**
 * Envía un mensaje a un usuario en ChatbotBuilder
 */
async function sendMessageToUser(userId) {
  const url = `https://app.chatgptbuilder.io/api/users/${userId}/send/${MESSAGE_FLOW_ID}`;

  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'accept': 'application/json',
      'X-ACCESS-TOKEN': CHATBOT_ACCESS_TOKEN,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({})
  });

  if (!response.ok) {
    throw new Error(`Error enviando mensaje: ${response.status} ${response.statusText}`);
  }

  const data = await response.json();
  return data;
}

/**
 * Maneja las peticiones al webhook
 */
async function handleRequest(request) {
  // Solo acepta POST
  if (request.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  try {
    // Leer el body como texto para verificar la firma
    const bodyText = await request.text();
    const signature = request.headers.get('x-passslot-signature');

    // Verificar la firma
    const isValid = await verifySignature(signature, bodyText);
    if (!isValid) {
      console.error('Firma inválida');
      return new Response('Invalid signature', { status: 403 });
    }

    // Parse el JSON
    const body = JSON.parse(bodyText);
    const { type, data } = body;

    console.log('Evento recibido:', JSON.stringify(body, null, 2));

    // Manejar verificación del webhook
    if (type === 'webhook.verify') {
      console.log('Manejando verificación del webhook con token:', data.token);
      return new Response(JSON.stringify({ token: data.token }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // Obtener el passSerialNumber
    const passSerialNumber = data?.passSerialNumber;
    if (!passSerialNumber) {
      console.error('passSerialNumber no encontrado en el evento');
      return new Response('passSerialNumber no encontrado', { status: 400 });
    }

    // Buscar el usuario en ChatbotBuilder
    const userResponse = await findUserByCustomField(passSerialNumber);

    if (!userResponse.data || userResponse.data.length === 0) {
      console.error('Usuario no encontrado con el passSerialNumber proporcionado');
      return new Response('Usuario no encontrado', { status: 404 });
    }

    const userId = userResponse.data[0].id;
    console.log(`Usuario encontrado con ID: ${userId}`);

    // Enviar el mensaje al usuario
    const messageResponse = await sendMessageToUser(userId);
    console.log('Mensaje enviado exitosamente al usuario:', messageResponse);

    return new Response('Evento procesado con éxito y mensaje enviado.', {
      status: 200,
      headers: { 'Content-Type': 'text/plain' }
    });

  } catch (error) {
    console.error('Error al procesar el evento:', error.message);
    return new Response(`Error al procesar el evento: ${error.message}`, {
      status: 500,
      headers: { 'Content-Type': 'text/plain' }
    });
  }
}

/**
 * Entry point del Worker
 */
export default {
  async fetch(request, env, ctx) {
    // Puedes sobrescribir las configuraciones con variables de entorno si están definidas
    if (env.SECRET_KEY) SECRET_KEY = env.SECRET_KEY;
    if (env.CHATBOT_ACCESS_TOKEN) CHATBOT_ACCESS_TOKEN = env.CHATBOT_ACCESS_TOKEN;
    if (env.FIELD_ID) FIELD_ID = env.FIELD_ID;
    if (env.MESSAGE_FLOW_ID) MESSAGE_FLOW_ID = env.MESSAGE_FLOW_ID;

    return handleRequest(request);
  }
};
