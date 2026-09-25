# Set up Windsurf in Pulse

Pulse shows your Windsurf plan's daily and weekly quota, each as the percentage Windsurf reports, and when each resets.

> **Using Devin?** Windsurf now belongs to Cognition, and the Devin app is the former Windsurf editor. If you use the Devin app or app.devin.ai, set up **Devin** in Pulse instead — it needs nothing pasted. This Windsurf entry reads windsurf.com's own page, for accounts still managed there.

## What you need

A Windsurf account, signed in at [windsurf.com](https://windsurf.com) in Chrome, Edge, Brave or another Chromium browser. Windsurf keeps its sign-in in the page's storage rather than in a cookie, so Pulse can't read it from the browser for you: you copy it once.

## Steps

1. Open [windsurf.com/profile](https://windsurf.com/profile) and make sure you're signed in.
2. Open the developer tools (**⌥⌘I**) and choose the **Console** tab.
3. Paste this and press Return. It copies one line of text to the clipboard:

   ```javascript
   copy(JSON.stringify(Object.fromEntries(["devin_session_token", "devin_auth1_token", "devin_account_id", "devin_primary_org_id"].map(k => { const v = localStorage.getItem(k); try { return [k, JSON.parse(v)]; } catch { return [k, v]; } }))))
   ```

4. In Pulse: **Settings → Accounts → Windsurf**. Turn on **Show in panel**. Under **Connection**, paste what you copied into **API key** and click **Save**.
5. Within a few seconds the ring appears, and the account's pane lists the daily and weekly quota.

## If it doesn't work

| Pulse says | What to do |
|---|---|
| Add an API key in Settings. | Copy the session as in the steps above and paste it. |
| That key was refused. Check it in Settings. | Either what you pasted isn't the four values (run the snippet again and paste all of it), or windsurf.com signed you out. Sign in again, copy it again, and paste it. |
| The service didn't respond. / Checking too often — easing off. / The service returned an error. | A temporary network or server problem. Wait a moment and try again. |
| Couldn't read the reply. / No limits reported. | Windsurf sent something Pulse doesn't recognize, or the plan has no quota. A quota that is fully spent may also be missing — Windsurf doesn't send a figure of zero. |

## What Pulse reads

What you paste is stored encrypted on this Mac and sent only to windsurf.com when Pulse checks your usage. Pulse reads your plan's name and the two quota figures; it doesn't read anything else on the account or change it. Signing out of windsurf.com ends the session you pasted.
