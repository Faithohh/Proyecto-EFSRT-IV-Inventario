<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar Sesión</title>
    <link rel="stylesheet" href="{{ asset('css/estilos.Login.css') }}">
</head>
<body>

    <div class="login-container">
        <form class="login-form">
            <h2>Iniciar Sesión</h2>
            
            <div class="input-group">
                <label for="username">Usuario o Correo</label>
                <input type="text" id="username" placeholder="Ingresa tu usuario" required>
            </div>

            <div class="input-group">
                <label for="password">Contraseña</label>
                <input type="password" id="password" placeholder="Ingresa tu contraseña" required>
            </div>

            <div class="form-options">
                <a href="#" class="forgot-password">¿Olvidaste tu contraseña?</a>
            </div>

            <button type="submit" class="btn-submit">Entrar</button>

            <p class="register-text">
                ¿No tienes una cuenta? <a href="#">Regístrate</a>
            </p>
        </form>
    </div>

</body>
</html>