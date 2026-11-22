import execution from 'k6/execution';
import { request, requireFixture } from './common.js';

const base = __ENV.PERF_BASE_URL || 'http://127.0.0.1:18080';
if (!/^http:\/\/127\.0\.0\.1:(?:18080|18081)$/.test(base) || __ENV.PERF_LOCAL !== 'isolated-compose') {
  throw new Error('Se requiere PERF_LOCAL=isolated-compose y loopback 127.0.0.1 en el puerto 18080 o 18081.');
}

const api = '/api/v1';
const availabilityDate = __ENV.PERF_AVAILABILITY_DATE || '2026-11-23';
if (!/^\d{4}-\d{2}-\d{2}$/.test(availabilityDate)) {
  throw new Error('PERF_AVAILABILITY_DATE debe usar el formato YYYY-MM-DD.');
}
const isList = (data) => Array.isArray(data.items);
const hasId = (data) => typeof data.id === 'string' && /^\d+$/.test(data.id);

function login(email, password) {
  return requireFixture(request(base, 'POST', api + '/auth/login', 'setup_login', 200,
    (data) => typeof data.tokenAcceso === 'string' && !!data.tokenAcceso && !!data.usuario,
    null, { correo: email, contrasena: password }), 'login');
}

function create(token, categoryId, flow) {
  return request(base, 'POST', api + '/requests', flow, 201,
    (data) => hasId(data) && typeof data.codigo === 'string', token, {
      categoriaId: categoryId,
      ubicacion: 'Local ficticio k6',
      descripcion: 'Solicitud ficticia de la prueba de rendimiento local.',
    });
}

export function prepare(includeWrites) {
  const { PERF_READER_EMAIL, PERF_READER_PASSWORD, PERF_WRITER_EMAIL, PERF_WRITER_PASSWORD } = __ENV;
  if (!PERF_READER_EMAIL || !PERF_READER_PASSWORD || !PERF_WRITER_EMAIL || !PERF_WRITER_PASSWORD ||
      PERF_READER_EMAIL.toLowerCase() === PERF_WRITER_EMAIL.toLowerCase() ||
      ![PERF_READER_EMAIL, PERF_WRITER_EMAIL].every((email) => email.endsWith('@universidad.example'))) {
    execution.test.abort('Configura dos cuentas demo distintas con dominio universidad.example.');
  }
  const reader = login(PERF_READER_EMAIL, PERF_READER_PASSWORD);
  const readerToken = reader.tokenAcceso;
  const existing = requireFixture(request(base, 'GET', api + '/requests?page=0&size=20',
    'setup_list', 200, isList, readerToken), 'listado');
  const spaces = requireFixture(request(base, 'GET', api + '/spaces?page=0&size=20',
    'setup_spaces', 200, (data) => isList(data) && data.items.some(hasId), readerToken), 'ambientes');
  let requestId = existing.items.find(hasId)?.id;
  let writerToken;
  let categoryId;
  if (includeWrites || !requestId) {
    writerToken = login(PERF_WRITER_EMAIL, PERF_WRITER_PASSWORD).tokenAcceso;
    const categories = requireFixture(request(base, 'GET', api + '/catalogs/categories',
      'setup_categories', 200, isList, writerToken), 'categorías');
    categoryId = categories.items.find((item) => hasId(item) && item.areaId === reader.usuario.areaId)?.id;
    if (!categoryId) execution.test.abort('La cuenta supervisora demo debe tener una categoría activa en su área.');
    if (!requestId) requestId = requireFixture(create(writerToken, categoryId, 'setup_create'), 'alta inicial').id;
  }
  requireFixture(request(base, 'GET', api + '/requests/' + requestId, 'setup_detail', 200,
    (data) => data.id === requestId, readerToken), 'detalle visible al supervisor');
  const spaceId = spaces.items.find(hasId).id;
  requireFixture(availability(readerToken, spaceId, 'setup_availability'), 'disponibilidad');
  return { readerToken, requestId, spaceId, writerToken, categoryId };
}

function availability(token, spaceId, flow) {
  return request(base, 'GET', `${api}/spaces/${spaceId}/availability?fecha=${availabilityDate}`, flow, 200,
    (data) => data.espacioId === spaceId && data.fecha === availabilityDate &&
      !!data.horario && Array.isArray(data.libres) && Array.isArray(data.ocupadas), token);
}

export const readFlows = ['requests_list', 'request_detail', 'space_availability', 'categories'];

export function read(data) {
  const position = execution.scenario.iterationInTest % 10;
  if (position < 4) {
    request(base, 'GET', api + '/requests?page=0&size=20', 'requests_list', 200, isList, data.readerToken);
  } else if (position < 7) {
    request(base, 'GET', api + '/requests/' + data.requestId, 'request_detail', 200,
      (body) => body.id === data.requestId, data.readerToken);
  } else if (position < 9) {
    availability(data.readerToken, data.spaceId, 'space_availability');
  } else {
    request(base, 'GET', api + '/catalogs/categories', 'categories', 200, isList, data.readerToken);
  }
}

export function write(data) {
  create(data.writerToken, data.categoryId, 'request_create');
}

export function arrivals(rate, duration, startTime, exec, vus) {
  return {
    executor: 'constant-arrival-rate',
    rate,
    timeUnit: '1s',
    duration,
    startTime,
    exec,
    preAllocatedVUs: vus,
    gracefulStop: '6s',
  };
}
