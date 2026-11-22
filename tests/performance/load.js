import { defaults, thresholds } from './common.js';
import { arrivals, prepare, read, readFlows, write } from './local.js';

export { read, write };
export { summarize as handleSummary } from './common.js';
export function setup() { return prepare(true); }

const scenarios = {
  warmup: arrivals(5, '30s', '0s', 'read', 20),
  load_reads: arrivals(10, '120s', '36s', 'read', 30),
  load_writes: arrivals(1, '120s', '36s', 'write', 1),
};

const checks = { dropped_iterations: ['count==0'], ...thresholds('scenario:warmup') };
for (const [scenario, flows] of [['load_reads', readFlows], ['load_writes', ['request_create']]]) {
  Object.assign(checks, thresholds(`scenario:${scenario}`, 'p(95)<2000', 'rate<0.01', 'rate==1'));
  for (const flow of flows) {
    Object.assign(checks, thresholds(`scenario:${scenario},flow:${flow}`, 'p(95)<2000', 'rate<0.01', 'rate==1'));
  }
}

export const options = { ...defaults, scenarios, thresholds: checks };
