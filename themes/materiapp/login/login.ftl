<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>${msg("loginTitle",(realm.displayName!''))}</title>
    <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css" />
</head>
<body>
<div class="auth-page">
    <div class="auth-card">

        <header class="auth-header">
            <h1 class="auth-title">Sign in</h1>
            <p class="auth-subtitle">Sign in to your account</p>
        </header>

        <#-- Mensaje global (errores, etc.) -->
        <#if message?has_content>
            <div class="auth-alert">
                ${kcSanitize(message.summary)?no_esc}
            </div>
        </#if>

        <form id="kc-form-login"
              class="auth-form"
              action="${url.loginAction}"
              method="post">

            <input type="hidden"
                   name="credentialId"
                   value="${auth.selectedCredential?if_exists}" />

            <div class="field">
                <label for="username">${msg("usernameOrEmail")}</label>
                <input id="username"
                       name="username"
                       type="text"
                       autofocus
                       autocomplete="username"
                       value="${login.username!''}" />
            </div>

            <div class="field">
                <label for="password">${msg("password")}</label>
                <input id="password"
                       name="password"
                       type="password"
                       autocomplete="current-password" />
            </div>

            <div class="form-row">
                <#if realm.rememberMe && !usernameEditDisabled??>
                    <label class="checkbox" for="rememberMe">
                        <input type="checkbox"
                               id="rememberMe"
                               name="rememberMe"
                               <#if login.rememberMe?? && login.rememberMe>checked</#if> />
                        ${msg("rememberMe")}
                    </label>
                </#if>

                <#if realm.resetPasswordAllowed>
                    <a class="link subtle" href="${url.loginResetCredentialsUrl}">
                        ${msg("doForgotPassword")}
                    </a>
                </#if>
            </div>

            <button type="submit"
                    id="kc-login"
                    class="btn-primary">
                ${msg("doLogIn")}
            </button>
        </form>

        <#if realm.registrationAllowed>
            <p class="auth-footer">
                ${msg("noAccount")}
                <a class="link" href="${url.registrationUrl}">
                    ${msg("doRegister")}
                </a>
            </p>
        </#if>

    </div>
</div>
</body>
</html>
