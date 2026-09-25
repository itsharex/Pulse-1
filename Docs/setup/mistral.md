# Set up Mistral in Pulse

Pulse shows your Mistral subscription's included allowances — API and Vibe — each as the percentage Mistral reports, and the credit available on your account.

## What you need

A Mistral account you can sign in to at [admin.mistral.ai](https://admin.mistral.ai). Allowances appear only if your subscription includes them; the credit balance appears either way.

## Steps

1. In your browser, sign in at [admin.mistral.ai](https://admin.mistral.ai/organization/usage).
2. Open the browser's developer tools, go to the **Network** tab, reload the page, select any request to `admin.mistral.ai`, and copy the value of its **Cookie** request header.
3. In Pulse: **Settings → Accounts → Mistral**. Turn on **Show in panel**. Under **Connection**, paste it into **Session cookie** and click **Save**.
4. Within a few seconds the account appears, with a ring for each allowance and the available credit.

**Read from browser** can't find Mistral's session yet: its cookie name ends in a part that differs per deployment, and Pulse's import only looks for exact names. Paste the header instead.

## If it doesn't work

| Pulse says | What to do |
|---|---|
| Read a browser session in Settings. | Paste the Cookie header. It must contain a cookie whose name starts with `ory_session_`. |
| The browser session expired. Sign in on the website, then read it again in Settings. | Sign in at admin.mistral.ai again and paste a fresh Cookie header. |
| No session found. Sign in at mistral.ai first. | The Read button can't find this session (see above). Paste the header instead. |
| The service didn't respond. / Checking too often — easing off. / The service returned an error. | A temporary network or server problem. Wait a moment and try again. |
| No limits reported. | Mistral reported neither an allowance nor a credit balance for this account. |

## What Pulse reads

The pasted header is stored encrypted on this Mac. Of its cookies, only the `ory_session_…` and `csrftoken` ones are ever sent, and only to Mistral's own sites — `admin.mistral.ai`, and `console.mistral.ai` for the Vibe figure when the subscription page doesn't have it.
