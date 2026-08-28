# AgentscriptUI

Prototype Agentforce **Employee Agent** (authored in Agent Script) proving this chain:

1. The user asks a question about a sensitive operation.
2. The agent answers that a **mandatory 30-second security delay** is required and renders a **countdown timer LWC** inline in the conversation.
3. Once the delay elapses, the user validates and an action returns the **full answer**.

> Built as a Salesforce SE demo/POC. Mock Apex (no DML) — safe for demos.

## How the interactive UI works (the important part)

On an Employee Agent (`lightningDesktopGenAi` surface), the reliable way to render an
**interactive** LWC that triggers an action is the **Custom Lightning Type (CLT) "editor"**
pattern — a LWC bound to an action **input** via `is_user_input: True`:

- `configuration.util.sendTextMessage` (renderer → post-render callback) is a
  **messaging-web / MIAW-only** API and is **not** available in the Employee LEX panel.
- The **platform** renders the **Submit** button below the LWC; the LWC only emits
  `valuechange` to sync its data. Here the timer keeps its `required` token blank while
  counting down, then sets it to `CONFIRMED` at 0s.
- A CLT renders **only on a published + activated agent** — never in Draft or in headless
  `sf agent preview` (`__supports_result_display__: false` is expected there).

Reference: official recipe
[`trailheadapps/agent-script-recipes` → `02_actionConfiguration/customLightningTypes`](https://github.com/trailheadapps/agent-script-recipes).

## Components

| Path | Role |
|------|------|
| `force-app/main/default/aiAuthoringBundles/AgentscriptUI/` | Agent Script bundle (`.agent`) — router + `validation` subagent + `complete_validation` action |
| `force-app/main/default/classes/ValidationService.cls` | Invocable Apex action + CLT data shapes (inner classes) |
| `force-app/main/default/lightningTypes/validationTimer/` | Custom Lightning Type — `schema.json` (Apex-backed) + `editor.json` |
| `force-app/main/default/lwc/timerButton/` | 30s countdown timer LWC (CLT editor, `lightning__AgentforceInput`) |
| `force-app/main/default/permissionsets/AgentscriptUI_Access.permissionset-meta.xml` | Access to the agent + the Apex class |

## Deploy to a fresh org

Requires an org on **API 64.0+** with Agentforce Employee Agents enabled.

```bash
# 1. Deploy metadata (Apex + CLT + LWC + permission set)
sf project deploy start --metadata \
  ApexClass:ValidationService \
  LightningComponentBundle:timerButton \
  LightningTypeBundle:validationTimer \
  PermissionSet:AgentscriptUI_Access

# 2. Publish + activate the agent (required for the CLT to render)
sf agent validate authoring-bundle --api-name AgentscriptUI
sf agent publish authoring-bundle  --api-name AgentscriptUI
sf agent activate                  --api-name AgentscriptUI

# 3. Grant yourself access, then test in Agent Builder Preview
sf org assign permset --name AgentscriptUI_Access
```

## Try it

In **Setup → Agentforce Studio → AgentscriptUI → Preview**, send:

> Puis-je valider cette opération sensible ?

Expected: the agent announces the security delay and shows the timer card. At 0s the
platform Submit button becomes actionable → validate → full answer with a `VAL-xxxxxx`
reference.

## Known limitation to verify live

Gating the platform Submit button for the full 30s relies on the empty `required` token —
confirm visually whether the platform greys out Submit until the delay elapses.
