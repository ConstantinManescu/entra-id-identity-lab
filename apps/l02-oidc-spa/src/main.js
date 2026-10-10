import "./style.css";
import {
  msalInstance,
  loginRequest,
  graphRequest,
} from "./authConfig";

const app = document.querySelector("#app");

const clientId = import.meta.env.VITE_CLIENT_ID;
const tenantId = import.meta.env.VITE_TENANT_ID;

function escapeHtml(value = "") {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function getActiveAccount() {
  return (
    msalInstance.getActiveAccount() ||
    msalInstance.getAllAccounts()[0] ||
    null
  );
}

function render(message = "") {
  const account = getActiveAccount();

  app.innerHTML = `
    <main class="container">
      <section class="card">
        <p class="label">Microsoft Entra ID Lab</p>
        <h1>OIDC Authentication</h1>
        <p>
          Local Single-page Application using Authorization Code with PKCE.
        </p>

        ${
          message
            ? `<p class="message">${escapeHtml(message)}</p>`
            : ""
        }

        ${
          account
            ? `
              <div class="success">
                <h2>Authenticated</h2>
                <p><strong>Name:</strong> ${escapeHtml(
                  account.name || "Not provided"
                )}</p>
                <p><strong>Username:</strong> ${escapeHtml(
                  account.username || "Not provided"
                )}</p>
                <p><strong>Account ID:</strong> ${escapeHtml(
                  account.homeAccountId || "Not displayed"
                )}</p>
              </div>

              <div class="actions">
                <button id="profile-button">
                  Read profile with Microsoft Graph
                </button>
                <button id="logout-button" class="secondary">
                  Sign out
                </button>
              </div>

              <pre id="profile-output"></pre>
            `
            : `
              <button id="login-button">
                Sign in with Microsoft Entra ID
              </button>
            `
        }
      </section>
    </main>
  `;

  document
    .querySelector("#login-button")
    ?.addEventListener("click", () => {
      msalInstance.loginRedirect(loginRequest);
    });

  document
    .querySelector("#logout-button")
    ?.addEventListener("click", () => {
      msalInstance.logoutRedirect();
    });

  document
    .querySelector("#profile-button")
    ?.addEventListener("click", loadGraphProfile);
}

async function loadGraphProfile() {
  const account = getActiveAccount();
  const output = document.querySelector("#profile-output");
  const button = document.querySelector("#profile-button");

  if (!account || !output || !button) {
    return;
  }

  button.disabled = true;
  output.textContent = "Requesting an access token and calling Microsoft Graph...";

  try {
    const tokenResponse = await msalInstance.acquireTokenSilent({
      ...graphRequest,
      account,
    });

    const response = await fetch("https://graph.microsoft.com/v1.0/me", {
      headers: {
        Authorization: `Bearer ${tokenResponse.accessToken}`,
      },
    });

    if (!response.ok) {
      throw new Error(`Microsoft Graph returned HTTP ${response.status}`);
    }

    const profile = await response.json();

    output.textContent = JSON.stringify(
      {
        displayName: profile.displayName,
        userPrincipalName: profile.userPrincipalName,
        id: profile.id,
      },
      null,
      2
    );
  } catch (error) {
    output.textContent = `Graph request failed: ${error.message}`;
  } finally {
    button.disabled = false;
  }
}

async function startApplication() {
  if (!clientId || !tenantId) {
    render(
      "Missing VITE_CLIENT_ID or VITE_TENANT_ID in .env.local."
    );
    return;
  }

  try {
    await msalInstance.initialize();

    const redirectResponse =
      await msalInstance.handleRedirectPromise();

    if (redirectResponse?.account) {
      msalInstance.setActiveAccount(redirectResponse.account);
    }

    const existingAccount = getActiveAccount();

    if (existingAccount) {
      msalInstance.setActiveAccount(existingAccount);
      render("OIDC sign-in completed successfully.");
    } else {
      render("Application ready. No user is signed in.");
    }
  } catch (error) {
    render(`MSAL initialization failed: ${error.message}`);
  }
}

startApplication();