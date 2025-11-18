<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>${msg("registerTitle",(realm.displayName!''))}</title>
    <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css" />
</head>
<body>
<div class="auth-page">
    <div class="auth-card">

        <header class="auth-header">
            <h1 class="auth-title">Create an account</h1>
            <p class="auth-subtitle">Enter your details to get started</p>
        </header>

        <#-- Mensaje global (errores de validación, etc.) -->
        <#if message?has_content>
            <div class="auth-alert">
                ${kcSanitize(message.summary)?no_esc}
            </div>
        </#if>

        <form id="kc-register-form"
              class="auth-form auth-register"
              action="${url.registrationAction}"
              method="post">

            <div class="field">
                <label for="username">${msg("username")}</label>
                <input id="username"
                       name="username"
                       type="text"
                       value="${(register.formData.username!'')}" />
            </div>

            <div class="field">
                <label for="password">${msg("password")}</label>
                <input id="password"
                       name="password"
                       type="password" />
            </div>

            <div class="field">
                <label for="password-confirm">${msg("passwordConfirm")}</label>
                <input id="password-confirm"
                       name="password-confirm"
                       type="password" />
            </div>

            <div class="field">
                <label for="email">${msg("email")}</label>
                <input id="email"
                       name="email"
                       type="email"
                       value="${(register.formData.email!'')}" />
            </div>

            <div class="field">
                <label for="firstName">${msg("firstName")}</label>
                <input id="firstName"
                       name="firstName"
                       type="text"
                       value="${(register.formData.firstName!'')}" />
            </div>

            <div class="field">
                <label for="lastName">${msg("lastName")}</label>
                <input id="lastName"
                       name="lastName"
                       type="text"
                       value="${(register.formData.lastName!'')}" />
            </div>

            <button type="submit"
                    id="kc-register"
                    class="btn-primary">
                ${msg("doRegister")}
            </button>
        </form>

        <p class="auth-footer">
            ${msg("backToLogin")} 
            <a class="link" href="${url.loginUrl}">
                ${msg("doLogIn")}
            </a>
        </p>

    </div>
</div>
</body>
</html>
