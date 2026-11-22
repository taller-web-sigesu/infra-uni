import { sleep } from 'k6';
import { defaults, request, thresholds } from './common.js';

const staging = 'https://uniservice-backend-staging.onrender.com';
if (__ENV.PERF_STAGING !== 'authorized' || (__ENV.PERF_BASE_URL && __ENV.PERF_BASE_URL !== staging)) {
  throw new Error('El smoke requiere PERF_STAGING=authorized y el destino fijo de staging.');
}

export { summarize as handleSummary } from './common.js';
export const options = {
  ...defaults,
  scenarios: {
    staging_smoke: { executor: 'shared-iterations', vus: 1, iterations: 3, maxDuration: '40s', gracefulStop: '0s' },
  },
  thresholds: {
    ...thresholds('scenario:staging_smoke', 'max<5000', 'rate==0', 'rate==1'),
    ...thresholds('scenario:staging_smoke,flow:health', 'max<5000', 'rate==0', 'rate==1'),
    ...thresholds('scenario:staging_smoke,flow:status', 'max<5000', 'rate==0', 'rate==1'),
    http_reqs: ['count==6'],
  },
};

export default function () {
  const isUp = (body) => body.status === 'UP';
  request(staging, 'GET', '/actuator/health', 'health', 200, isUp);
  request(staging, 'GET', '/api/v1/status', 'status', 200, isUp);
  sleep(2);
}
