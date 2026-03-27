# Registro Mis Gastos Mobile

Mobile app para registrar y gestionar gastos personales con soporte multi-plataforma (iOS y Android).

## Funcionalidades

- Autenticación con Google
- Registro con email/password
- Agregar, editar y eliminar gastos
- Listado de transacciones con filtros
- Resumen mensual
- Soporte offline básico

## Requisitos

- Flutter 3.x
- Dart 3.x
- Xcode (para iOS)
- Android Studio / Android SDK (para Android)

## Instalación

1. Clonar el repositorio:
```bash
git clone https://github.com/elrosti/registro-mis-gastos-mobile.git
cd registro-mis-gastos-mobile
```

2. Instalar dependencias:
```bash
flutter pub get
```

3. Configurar variables de entorno:
```bash
cp .env.example .env
# Editar .env con tu configuración
```

4. Crear proyecto plataformas:
```bash
flutter create --platforms=ios,android .
```

5. Ejecutar:
```bash
flutter run
```

## Configuración

### Android

1. Agregar credenciales de Google en `android/app/google-services.json`
2. Configurar OAuth redirect URI en Google Cloud Console

### iOS

1. Agregar credenciales de Google en `ios/Runner/GoogleService-Info.plist`
2. Configurar URL Schemes en Xcode

## Arquitectura

El proyecto sigue **Clean Architecture** con 3 capas:

- **Presentation**: BLoC, Pages, Widgets
- **Domain**: Entities, Repositories (abstract), UseCases
- **Data**: Models, DataSources, Repository implementations

## Licencia

MIT
