import { check } from 'k6';
import execution from 'k6/execution';
import http from 'k6/http';
import { Rate } from 'k6/metrics';

const serverErrors = new Rate('api_5xx');

export const defaults = {
  discardResponseBodies: true,
  maxRedirects: 0,
  systemTags: ['scenario', 'name', 'method', 'status', 'check', 'expected_response'],
  summaryTrendStats: ['med', 'p(95)', 'p(99)', 'max'],
};

export function request(base, method, path, flow, status, validate, token, body) {
  const headers = { Accept: 'application/json' };
  if (token) headers.Authorization = `Bearer ${token}`;
  if (body) headers['Content-Type'] = 'application/json';
  const res = http.request(method, base + path, body ? JSON.stringify(body) : null, {
    headers,
    tags: { name: flow, flow },
    redirects: 0,
    timeout: '5s',
    responseType: 'text',
    responseCallback: http.expectedStatuses(status),
  });
  let data;
  try {
    data = res.json();
  } catch {
    // Un cuerpo vacío o ajeno al contrato se registra como check fallido.
  }
  const ok = check(res, {
    'estado HTTP esperado': (response) => response.status === status,
    'contrato JSON esperado': () => !!data && validate(data),
  }, { flow });
  serverErrors.add(res.status >= 500 && res.status < 600, { flow });
  return { ok, data };
}

export function requireFixture(result, flow) {
  if (!result.ok) execution.test.abort(`Falló la preparación local: ${flow}`);
  return result.data;
}

export function thresholds(selector, duration = 'max>=0', errors = 'rate<=1', checks = 'rate>=0') {
  return {
    [`http_reqs{${selector}}`]: ['count>0'],
    [`http_req_duration{${selector}}`]: [duration],
    [`http_req_failed{${selector}}`]: [errors],
    [`checks{${selector}}`]: [checks],
    [`api_5xx{${selector}}`]: ['rate<=1'],
  };
}

export function summarize(data) {
  const json = JSON.stringify(data, null, 2) + '\n';
  const output = { stdout: json };
  if (__ENV.PERF_SUMMARY) output[__ENV.PERF_SUMMARY] = json;
  return output;
}
