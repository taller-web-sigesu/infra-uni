import { defaults, thresholds } from './common.js';
import { arrivals, prepare, read, readFlows } from './local.js';

export { read };
export { summarize as handleSummary } from './common.js';
export function setup() { return prepare(false); }

const scenarios = { warmup: arrivals(5, '30s', '0s', 'read', 20) };
const checks = { ...thresholds('scenario:warmup') };
for (const [index, rate] of [10, 20, 30, 40].entries()) {
  const name = `stress_${rate}`;
  const start = 36 + index * 51;
  const stop = (threshold, delay = 15) => ({ threshold, abortOnFail: true, delayAbortEval: `${start + delay}s` });
  scenarios[name] = arrivals(rate, '45s', `${start}s`, 'read', Math.min(rate * 3, 100));
  Object.assign(checks, thresholds(`scenario:${name}`, stop('p(95)<3000'), stop('rate<0.05')));
  checks[`api_5xx{scenario:${name}}`] = [stop('rate<0.05')];
  checks[`dropped_iterations{scenario:${name}}`] = [stop('count==0', 0)];
  for (const flow of readFlows) {
    Object.assign(checks, thresholds(`scenario:${name},flow:${flow}`));
  }
}

export const options = { ...defaults, scenarios, thresholds: checks };
