// Prints Claude plan rate-limit utilization for the noctalia bar widget.
// usage: node claude-usage.mjs <claude-agent-sdk/sdk.mjs> <claude-binary>
// stdout: line 1 bar text, line 2 tooltip, line 3 severity (normal|warning|critical)
import { tmpdir } from "node:os";

const [sdkPath, claudeBin] = process.argv.slice(2);
const { query } = await import(sdkPath);

// Keep the input stream open without ever sending a prompt, so no model call is made.
let release;
const idle = new Promise((resolve) => (release = resolve));
async function* noPrompt() {
  await idle;
}

function fail(message) {
  console.log(`Claude ?\n${message}\ncritical`);
  process.exit(1);
}

const timer = setTimeout(() => fail("usage request timed out"), 30000);

const q = query({
  prompt: noPrompt(),
  options: {
    pathToClaudeCodeExecutable: claudeBin,
    cwd: tmpdir(),
    settingSources: [], // no user hooks (squeez, buddy) for this probe
    persistSession: false,
    strictMcpConfig: true,
  },
});

function resetText(resetsAt) {
  if (!resetsAt) return "unknown";
  return new Date(resetsAt).toLocaleString("en-GB", {
    weekday: "short",
    hour: "2-digit",
    minute: "2-digit",
  });
}

try {
  const usage = await q.usage_EXPERIMENTAL_MAY_CHANGE_DO_NOT_RELY_ON_THIS_API_YET({ skipBehaviors: true });
  if (!usage.rate_limits_available || !usage.rate_limits) fail("no plan rate limits for this login");

  const { five_hour: fiveHour, seven_day: sevenDay } = usage.rate_limits;
  const fivePct = Math.round(fiveHour?.utilization ?? 0);
  const sevenPct = Math.round(sevenDay?.utilization ?? 0);
  const peak = Math.max(fivePct, sevenPct);
  const severity = peak >= 90 ? "critical" : peak >= 70 ? "warning" : "normal";

  console.log(
    `5h ${fivePct}% · 7d ${sevenPct}%\n` +
      `5h resets ${resetText(fiveHour?.resets_at)} · 7d resets ${resetText(sevenDay?.resets_at)}\n` +
      severity,
  );
} catch (error) {
  fail(String(error?.message ?? error));
} finally {
  clearTimeout(timer);
  release();
  q.close();
}
